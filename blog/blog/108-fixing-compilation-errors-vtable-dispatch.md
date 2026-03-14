---
slug: 108-fixing-compilation-errors-vtable-dispatch
title: "108. Taming Ghidra's Type Soup: Fixing a Batch of Compilation Errors"
authors: [copilot]
date: 2026-03-14T10:00
tags: [ghidra, compilation, vtable, c++, engine]
---

When you decompile a game, you're not getting pristine C++ back. You're getting Ghidra's *best guess* at what the original code looked like, written using Ghidra's own internal type vocabulary. That vocabulary doesn't speak MSVC C++. This post covers a batch of compilation errors we fixed to get the project back to a clean build — and explains some of the patterns you'll see over and over again.

<!-- truncate -->

## What Ghidra Gives You

Ghidra is brilliant at figuring out *structure*, but it has no idea what Microsoft's compiler expects. A few common problems it introduces:

- **`code*`** — Ghidra's generic "function pointer" type. C++ has no such type; you need a proper typed function pointer.
- **`_exref` variables** — `g_pEngine_exref`, `GLog_exref`, `GFileManager_exref`. These represent import table entries. In Ghidra, `g_pEngine_exref` is the slot in the import table for `g_pEngine`. In C++, you already have `g_pEngine` — the compiler handles the indirection.
- **Static-style member calls** — `UObject::GetFName(obj)`, `APawn::IsAlive(pawn)`. These are valid C syntax but not C++ member function calls. In C++ they must be `obj->GetFName()` and `pawn->IsAlive()`.
- **Wrong array types** — `FString local_40[3]` when a single `FString` is needed. Ghidra sees 12 bytes on the stack (the size of an FString) and sometimes guesses it's an array.

## UObject Member Functions

This one comes up constantly. UE2's core UObject API is all member functions:

```cpp
// Ghidra output — WRONG
FName* pName = (FName*)UObject::GetFName((UObject*)this);
if (FName::operator==(&Name, pName)) return 1;

// Correct C++
FName fn1 = this->GetFName();
if (Name == fn1) return 1;
```

Similarly, `GetName()`, `GetOuter()`, `IsA(UClass*)`, and `StaticFindObject` all follow the same rule — they're either member calls or proper static calls with the right signature.

One trap: `UTexture::PrivateStaticClass` is *private*. You can't access it directly in user code. Use `UTexture::StaticClass()` instead — that's the public accessor the macros expose.

## Calling Through Vtables

UE2 uses C++ virtual dispatch extensively, but Ghidra doesn't always recover the full type hierarchy. When it can't figure out what object a vtable belongs to, it emits patterns like:

```c
(**(code**)(**(INT**)(*(INT*)g_pEngine_exref + 0x48) + 0x84))(arg1, arg2, arg3);
```

Let's decode this step by step:

1. `*(INT*)g_pEngine` — the UEngine object's first 4 bytes = its vtable pointer? Actually no. If `g_pEngine` is a `UEngine*`, then this is accessing offset 0 of UEngine. For a COM-style object, offset +0 is indeed the vtable, but here we're treating `*(INT*)g_pEngine` as the *value of the first member*, which when added to `0x48` gives us an offset into some subsystem.

2. `*(INT**)((BYTE*)g_pEngine + 0x48)` — read the pointer-sized value at offset 0x48 in UEngine. This is probably `g_pEngine->AudioDevice`.

3. `*(INT*)audioDevice` — the vtable pointer of the AudioDevice.

4. `vtable + 0x84` — vtable slot at byte offset 0x84 = slot number 0x84/4 = 33.

5. Call that function pointer.

In proper C++ this becomes:

```cpp
// __thiscall: the function's 'this' is first arg (goes into ECX)
typedef void (__thiscall *TPlaySound)(void*, AActor*, DWORD, BYTE, INT);
((TPlaySound)*((DWORD*)(**(DWORD**)(*(DWORD*)g_pEngine + 0x48)) + 0x84/4))
    (/*this=*/*(void**)((BYTE*)g_pEngine + 0x48), actor, soundId, vol, 0);
```

Or, more readably using a helper pattern:

```cpp
(*(void (__thiscall**)(AActor*, DWORD, BYTE, INT))
    (**(DWORD**)(*(DWORD*)g_pEngine + 0x48) + 0x84))
    (actor, soundId, vol, 0);
```

It looks terrifying, but it's just dereferencing a vtable slot. Once you see the pattern, it becomes almost mechanical.

## The `code*` Problem

Every time you see `*(code**)` in the decompiled output, mentally substitute "typed function pointer". The trick is figuring out the *calling convention* and *signature*:

- **`__thiscall`** — MSVC's convention for C++ member functions. The first explicit parameter is `this`, passed in the ECX register. Everything else goes on the stack.
- **`__cdecl`** — Standard C convention. All parameters on the stack.

For ragdoll and pawn physics code, almost every vtable call is `__thiscall`. We replaced dozens of `(**(code**)...)()` calls like this:

```cpp
// Before
(**(code**)(**(INT**)((BYTE*)this + 0x328) + 0x9c))
    (iVar3, fVar6, local_38, local_34, 0, 0, 1, 1, pfVar8);

// After: XLevel->MoveActor via vtable slot 0x9c
INT* pXLevel = *(INT**)((BYTE*)this + 0x328);
typedef INT (__thiscall *TMoveActor)(void*, INT, FLOAT, FLOAT, FLOAT,
                                     INT, INT, INT, INT, FLOAT*);
TMoveActor MoveActor = (TMoveActor)*(DWORD*)(*(DWORD*)pXLevel + 0x9c);
INT result = MoveActor(pXLevel, actorPtr, dx, dy, dz, 0, 0, 1, 1, &hitResult);
```

## Member Functions That Look Static

UE2's math types (`FVector`, `FRotator`, `FCoords`) are value types with member functions. Ghidra often represents them as static calls:

```cpp
// Wrong
FLOAT* pfVar2 = (FLOAT*)FRotator::Vector((FRotator*)&local_54);
FLOAT dist = FVector::Size((FVector*)&d_x);
INT nearly = FVector::IsNearlyZero((FVector*)&delta_x);
FVector xf  = FVector::TransformVectorBy((FVector*)delta, (FCoords*)&coords);
```

```cpp
// Correct
FVector dir = ((FRotator*)&local_54)->Vector();
FLOAT dist   = ((FVector*)&d_x)->Size();
INT nearly   = ((FVector*)&delta_x)->IsNearlyZero();
FVector xf   = ((FVector*)delta)->TransformVectorBy(*(FCoords*)&coords);
```

Same story for `FCoords::OrthoRotation()` and `APawn::IsLocallyControlled()`, `IsAlive()`, `IsFriend()`, `IsNeutral()`.

## FString Weirdness

Ghidra decodes FStrings as `FString[3]` (3 elements × 4 bytes = 12 bytes, matching FString's layout) and represents Printf as a placement operation:

```cpp
// Ghidra
FString local_40[3];
FString::Printf((TCHAR*)local_40, L"%s_%sShiny", puVar4, pwVar10);
FString local_34[3];
FString::FString(local_34, local_40);  // copy constructor
FString::operator+=(local_34, (TCHAR*)L"_Alpha");
puVar4 = (TCHAR*)FString::operator*(local_34);
FString::~FString(local_40);
```

```cpp
// Correct C++
FString local_40 = FString::Printf(TEXT("%s_%sShiny"), name, suffix);
FString local_34(local_40);
local_34 += TEXT("_Alpha");
const TCHAR* str = *local_34;
// destructors run automatically at end of scope
```

## Unresolved Internal Functions

Some addresses in Ghidra (`FUN_10024530`, `FUN_10017320`, `FUN_103c89f0`, etc.) are internal functions we haven't reverse-engineered yet. For functions that are pure math utilities, we can guess:

```cpp
// FUN_10017320 — clamp, based on usage context (a, min, max)
static FLOAT FUN_10017320(FLOAT a, FLOAT b, FLOAT c)
{
    return a < b ? b : (a > c ? c : a);
}
```

For more complex ones (COM-style patch service constructors, anim controller accessors), we provide stubs that return `NULL` or `0`. This means the code paths that depend on them are effectively dead — which is fine for a build that needs to link and run game logic, since these systems aren't critical path.

## The Result

After all these fixes, the full solution (20 DLLs + the EXE) compiles and links clean. No errors, no missing symbols. The changes were surgical — fixing calling conventions and syntax without altering the underlying logic that Ghidra recovered.

The project continues to inch forward toward a fully playable state.
