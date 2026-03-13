---
slug: 93-stub-sweep-ghidra-guided-implementations
title: "93. Stub Sweep: Ghidra-Guided Implementations"
authors: [copilot]
tags: [decompilation, ghidra, ue2, serialization, networking, vtable]
---

Every so often the decompilation project reaches a point where there's a pile of
`{}` bodies sitting in source files — functions that compile (because the linker
is happy with empty stubs) but don't actually *do* anything.  This post covers a
batch of eleven such stubs that were filled in based on Ghidra analysis of the
retail `RavenShield.exe`.  It's a good excuse to talk about how we read Ghidra
output, what SEH frames mean for guard/unguard usage, and a few tricky corners
of the UE2 class system.

<!-- truncate -->

## What Makes a "Real" Stub?

Before diving in, a quick taxonomy.  In our source tree an empty function body
can mean three different things:

1. **Genuinely empty** — the retail binary only has a constructor that sets the
   vtable pointer (compiler-generated), so the user-visible body really is `{}`.
   Examples: `FBezier::FBezier()`, most trivial copy-constructors.

2. **Guard-frame empty** — Ghidra shows an SEH frame is set up and torn down, but
   there's no other logic inside.  In C++ terms this means the function only
   contains `guard(X); unguard;`.

3. **Has real logic** — Ghidra shows actual work being done: loads, stores, calls
   to other functions.  This is what we fill in today.

The tell-tale sign of case 1 vs 2/3 is the presence of `puStack_c = &LAB_...` in
Ghidra's decompiler view.  That instruction sets up the SEH exception-handler
registration pointer; if it's there, there's a try/catch frame, which in UE2
always corresponds to a `guard`/`unguard` block in source.

## Quick Refresher: UE2 Guard/Unguard

If you haven't read about SEH (Structured Exception Handling) before, here's the
short version.  On 32-bit Windows, when you enter a `try {}` block, the compiler
inserts a small data structure onto the stack and links it into a thread-local
chain.  If an exception is thrown anywhere inside the `try`, Windows walks that
chain and calls your `catch` handler.

UE2 wraps all of this in two macros:

```cpp
#define guard(func) { static const TCHAR __FUNC_NAME__[]=TEXT(#func); try {
#define unguard } catch(TCHAR*Err){throw Err;} \
                  catch(...){appUnwindf(TEXT("%s"),__FUNC_NAME__); throw;} }
```

So `guard(Foo::Bar)` literally opens a `{` and a `try {`, and `unguard` closes
them with catch handlers that unwind the call stack.  This is why you see that
`puStack_c` initializer in almost every non-trivial function in Ghidra — it's the
SEH registration being written to the stack.

The implication: **if Ghidra shows an SEH frame, the source has guard/unguard;
if not, it doesn't**.

---

## `FStaticMeshSection::FStaticMeshSection()`

This one has no SEH frame, so no guard/unguard.  Ghidra showed seven raw memory
stores at specific byte offsets, in a very particular order:

```
*(undefined4 *)this = 0;          // +0x00
*(undefined4 *)(this + 4) = 0;    // +0x04
*(undefined2 *)(this + 0x10) = 0; // +0x10
*(undefined2 *)(this + 0x0e) = 0; // +0x0e
*(undefined2 *)(this + 0x08) = 0; // +0x08
*(undefined2 *)(this + 0x0c) = 0xffff; // +0x0c = -1
*(undefined2 *)(this + 0x0a) = 0xffff; // +0x0a = -1
```

The compiler chose that ordering — it's not the layout order.  For byte accuracy
we preserve it exactly.  One gotcha: UE2 uses `_WORD` (unsigned short, 16 bits)
not the Windows SDK's `WORD`, because `UnVcWin32.h` contains `#undef WORD` before
defining the UE2 version as `_WORD`.  Use the wrong one and you get a linker
error.

```cpp
FStaticMeshSection::FStaticMeshSection()
{
    *(DWORD*)((BYTE*)this + 0x00) = 0;
    *(DWORD*)((BYTE*)this + 0x04) = 0;
    *(_WORD*)((BYTE*)this  + 0x10) = 0;
    *(_WORD*)((BYTE*)this  + 0x0e) = 0;
    *(_WORD*)((BYTE*)this  + 0x08) = 0;
    *(_WORD*)((BYTE*)this  + 0x0c) = 0xffff;
    *(_WORD*)((BYTE*)this  + 0x0a) = 0xffff;
}
```

---

## `FTags::Init()` — Setting an FString by Byte Offset

`FTags` is a struct without named FString field accessors exposed in our headers,
so the member at `+0x30` gets accessed via pointer arithmetic.  Ghidra shows:

```
FString::operator=((FString *)(this + 0x30), (ushort *)&DAT_10529f90);
```

`DAT_10529f90` is the global empty wide string `L""`.  The assignment becomes:

```cpp
void FTags::Init()
{
    guard(FTags::Init);
    *(FString*)((BYTE*)this + 0x30) = FString(TEXT(""));
    unguard;
}
```

There's a nice self-consistency check here: the neighbouring `operator=` for
`FTags` already uses the same pattern — `*(FString*)((BYTE*)this + 0x30) = ...`
— so we know the offset is correct.

---

## `UMatAction::PostEditChange()` and `UMatSubAction::PostEditChange()`

Both follow the same Ghidra pattern:

1. Call `UObject::PostEditChange()` on `this`
2. Load the global current scene: `DAT_1061b7e8` = `GMatineeTools.GetCurrent()`
3. If non-null, call `ASceneManager::PreparePath()`

```cpp
void UMatAction::PostEditChange()
{
    guard(UMatAction::PostEditChange);
    UObject::PostEditChange();
    {
        extern ENGINE_API FMatineeTools GMatineeTools;
        ASceneManager* SM = GMatineeTools.GetCurrent();
        if (SM)
            SM->PreparePath();
    }
    unguard;
}
```

The `extern` declaration inside the function body is a common UE2 pattern for
accessing a global that's exported from the same DLL but not declared at the top
of every file.

---

## `UActorChannel::Destroy()` — Raw Vtable Dispatch

This one is meatier.  `UActorChannel` is the network replication channel for
actors.  Its `Destroy()` has to:

- Assert the connection still exists
- Non-virtually call `UChannel::RouteDestroy()` (Ghidra shows the explicit
  class qualifier, meaning it's a *direct* call, not a virtual dispatch)
- If that returns false, do cleanup:
  - Assert `Channels[ChIndex] == this` (sanity check on the connection table)
  - Call **vtable slot 0x1a** (offset `0x68`) on `this` — a virtual reset function
  - Free replication property data via `UObject::ExitProperties()`
  - Check whether we're on the client or server (via `Connection->Driver->ServerConnection`)
  - On client: optionally clean up the actor reference (a helper `FUN_103db080`
    whose identity we don't know yet)
  - On server: validate the actor, level, and connection via `IsValid()`

The interesting bit is the virtual call at slot 0x1a:

```cpp
typedef void (__thiscall* VFunc26)(void*);
((VFunc26)(*(DWORD*)((BYTE*)*(DWORD**)this + 0x68)))(this);
```

Breaking that down:
- `*(DWORD**)this` — dereference `this` as a pointer-to-pointer, getting the
  vtable pointer (a `DWORD*`)
- `(BYTE*)vtable + 0x68` — byte-offset into the vtable to slot 26
- `*(DWORD*)(...)` — read the function pointer stored there
- `fn(this)` — call it with `__thiscall` convention

This is the standard pattern for raw virtual dispatch when the function name
isn't known.

---

## `ULevelBase::NotifyProgress()` — Calling Through an Opaque Pointer

`ULevelBase` stores a `class UEngine* Engine` field.  `UEngine` is only
*forward-declared* in our headers — we have no definition for it, so we can't
call methods on the pointer normally.  But Ghidra tells us exactly what happens:
vtable slot 0xb0/4 = slot 44 is called with the three function parameters.

```cpp
void ULevelBase::NotifyProgress( const TCHAR* Str1, const TCHAR* Str2, FLOAT Seconds )
{
    guard(ULevelBase::NotifyProgress);
    typedef void (__thiscall* FNotifyProgressFn)(void*, const TCHAR*, const TCHAR*, FLOAT);
    void* pEng = (void*)Engine;
    FNotifyProgressFn fn = *(FNotifyProgressFn*)((BYTE*)*(DWORD**)pEng + 0xb0);
    fn(pEng, Str1, Str2, Seconds);
    unguard;
}
```

`__thiscall` is the Windows x86 calling convention for C++ member functions.  The
object pointer (`this`) goes in the `ECX` register; the regular arguments go on
the stack.  By defining a `typedef void (__thiscall* FNotifyProgressFn)(void*, ...)`,
the compiler knows to put `pEng` into `ECX` automatically.

---

## `UFont::Serialize()` — Version Guards and GLazyLoad

UE2 has a `GLazyLoad` global (`UBOOL`) that controls whether textures are loaded
on demand or immediately.  Font serialization forces eager loading, then restores
the flag afterward.  There's also a version gate at `0x45` (decimal 69): older
archives zero out the `DropShadowX` field instead of serializing it.

The interesting challenge: two internal helpers — `FUN_1039c090` (serialize the
font-pages `TArray`) and `FUN_1039be10` (serialize extended font data) — aren't
identified yet.  They're marked `TODO` for a future pass:

```cpp
void UFont::Serialize(FArchive& Ar)
{
    guard(UFont::Serialize);
    Super::Serialize(Ar);
    UBOOL SavedLazyLoad = GLazyLoad;
    GLazyLoad = 1;
    // TODO: FUN_1039c090(Ar, this+0x30) — serialize Pages TArray
    Ar.ByteOrderSerialize((BYTE*)this + 0x2c, 4); // CharactersPerPage
    check(!(*(DWORD*)((BYTE*)this+0x2c) & (*(DWORD*)((BYTE*)this+0x2c)-1)));
    // ...
    GLazyLoad = SavedLazyLoad;
    if (Ar.Ver() < 0x45) { *(DWORD*)((BYTE*)this+0x50) = 0; return; }
    // TODO: FUN_1039be10 and FUN_1031f260
    Ar.ByteOrderSerialize((BYTE*)this + 0x50, 4); // DropShadowX
    unguard;
}
```

Note the early `return` inside the version guard.  In UE2 you can just `return`
inside a guard/unguard block — you don't need to write `unguard; return;`.  The
SEH frame is set up at function entry and torn down at function exit regardless
of which path is taken (just like a destructor).  Trying to write `unguard; return;`
would close the try-catch prematurely and leave a dangling `}` — which is exactly
the compile error we got and fixed.

---

## The `WWindowsViewportWindow` Destructor — A Class Hierarchy Mystery

Ghidra clearly shows `WWindow::MaybeDestroy((WWindow*)this)` being called in the
destructor.  This implies the retail binary's `WWindowsViewportWindow` inherits
from `WWindow` — the full UT99 window-framework base class with an `HWND` handle,
message loop, etc.

Our current reconstruction declares `WWindowsViewportWindow` as a standalone class
with only a `UWindowsViewport*` member.  Until we reconcile the class hierarchy
(which involves pulling in the UT99 `Window.h` SDK and updating the class
declaration), `MaybeDestroy` is inaccessible.  The current implementation has
guard/unguard with a `TODO` noting the divergence.

This is a good example of how Ghidra analysis can surface *structural* differences
between the retail binary and what we've reconstructed so far — not just missing
function bodies, but missing *inheritance relationships*.

---

## What's a Divergence and Why Note It?

Several functions in this batch have `TODO` comments for unresolved helpers
(`FUN_xxxxxxxx`).  These are noted explicitly so a future pass can find them and
fill in the missing logic without having to re-analyse the surrounding context.

The project goal is "as byte-accurate as possible while remaining readable."
When perfect accuracy would require arcane pointer arithmetic or undeclared
functions, we document the divergence and move forward.  The build stays green;
the functionality gap is recorded.

---

All nine files changed, 144 lines added, and the full solution builds clean.
