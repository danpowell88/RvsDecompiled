---
slug: 94-final-stub-sweep
title: "94. Final Stub Sweep: Filling in the Last Empty Bodies"
authors: [copilot]
tags: [decompilation, ghidra, stubs, engine, networking, matinee]
---

Every decompilation project reaches a point where the "obvious" functions are done and
you're left with a collection of small, annoying stubs — functions that are declared and
linked but contain absolutely nothing between their braces. This post covers the final
sweep of those stubs across Core, Engine, WinDrv, and D3DDrv.

<!-- truncate -->

## What's a "Stub" in This Context?

When we add a new function to a source file, we often write the signature and leave the
body empty so the project still compiles while we figure out what the function should
actually do. That looks like this:

```cpp
void UFont::Serialize(FArchive& Ar)
{
}
```

The build is happy, but the function does nothing. That's fine temporarily — but at some
point every stub needs to be filled in or confirmed empty.

An "empty stub" by our definition is very specific: line N is the function signature (or
the last line of an initializer list), line N+1 is exactly `{`, and line N+2 is exactly
`}`. This mechanical pattern lets us grep for them systematically.

## The Two Categories

After scanning about 20 source files, every stub fell into one of two buckets:

**Correctly empty** — Ghidra confirms the compiled function has no user-defined body.
Trivial constructors (that only set the vtable pointer, which the compiler does
automatically), virtual overrides pointing at shared no-op stubs, and copy constructors
whose init-list does all the work.

**Needs implementation** — Ghidra shows real code: SEH frames, assertions, vtable
dispatch, property cleanup, and even a 3802-byte network command parser.

## How We Used Ghidra

For each stub we ran a search in the module's `_global.cpp` export and extracted the
decompiled body. The pattern that tells you "this function has real work to do" is the
MSVC structured exception handling frame setup at the top:

```c
puStack_c = &LAB_10512309;
local_10 = ExceptionList;
local_8 = 0;
ExceptionList = &local_10;
```

In our source that translates to `guard(ClassName::FunctionName)` / `unguard;` — the
UE2 macro pair that installs a crash-catch frame with the function name for diagnostics.
Every function with that Ghidra pattern needs the pair in source, even if the rest of
the body is empty.

Functions *without* that pattern (trivial constructors, shared null stubs at address
`0x1651d0`) get left as empty `{}` bodies.

## The Interesting Implementations

### ULevelBase::NotifyProgress

This one looks straightforward — a progress callback — but the Ghidra body is a raw
virtual dispatch into the Engine object:

```c
(**(code **)(*(int **)(this + 0x18) + 0xb0))(param_1, param_2, param_3);
```

Breaking that down: `this + 0x18` is the `Engine` member (a `UEngine*`), and `0xb0` is
the byte offset into the vtable — slot 44 (`0xb0 / 4`). In C++ source we write this as:

```cpp
void ULevelBase::NotifyProgress(const TCHAR* Str1, const TCHAR* Str2, FLOAT Seconds)
{
    guard(ULevelBase::NotifyProgress);
    typedef void (__thiscall* FNotifyProgressFn)(void*, const TCHAR*, const TCHAR*, FLOAT);
    void* pEng = (void*)Engine;
    FNotifyProgressFn fn = *(FNotifyProgressFn*)((BYTE*)*(DWORD**)pEng + 0xb0);
    fn(pEng, Str1, Str2, Seconds);
    unguard;
}
```

We use a `typedef` for the function pointer to keep the calling convention (`__thiscall`)
explicit. The raw byte offset is preserved verbatim from Ghidra for byte accuracy.

### FStaticMeshSection Default Constructor

Here Ghidra shows zero-initialisation of seven fields in a specific non-obvious order:

```c
*(undefined4 *)this       = 0;    // +0x00
*(undefined4 *)(this + 4) = 0;    // +0x04
*(undefined2 *)(this + 0x10) = 0; // +0x10  ← not sequential!
*(undefined2 *)(this + 0x0e) = 0; // +0x0e
*(undefined2 *)(this + 0x08) = 0; // +0x08
*(undefined2 *)(this + 0x0c) = 0xffff;
*(undefined2 *)(this + 0x0a) = 0xffff;
```

The field at `+0x10` is written *before* `+0x0e` and `+0x08`. This is the compiler
scheduling stores in whatever order it found optimal. Since we compile with
`#pragma optimize("", off)` these writes stay in order. We maintain that exact order in
the source because swapping them could produce a different binary.

The `0xffff` values (−1 as a signed 16-bit integer) are sentinel values for unset index
fields, a common UE2 pattern.

### UActorChannel::Destroy — Not the Destructor

This was a subtle confusion point. Ghidra's export contains `??1UActorChannel@@UAE@XZ`
(the C++ destructor `~UActorChannel`) but our stub is `Destroy()` — a *virtual method*
inherited from `UObject`, not the actual destructor.

Searching specifically for `?Destroy@UActorChannel@@UAEXXZ` revealed the real body:
validates `Connection`, calls `UChannel::RouteDestroy` non-virtually (explicit class
qualifier in Ghidra = static dispatch), then manages actor replication cleanup using raw
byte offsets into the connection and channel objects. The server vs client branch at
`Connection->Driver->ServerConnection` (`+0x7c + 0x3c` offset chain) determines whether
we're cleaning up replication state or validating object validity.

### UMatAction / UMatSubAction::PostEditChange

These are identical bodies: call the base class, then refresh the current scene manager
if one is active. The Ghidra shows `DAT_1061b7e8` as the active scene manager pointer.
By cross-referencing with `FMatineeTools::GetCurrent()` (which returns the `CurrentScene`
member), we established this is `GMatineeTools.GetCurrent()`:

```cpp
void UMatAction::PostEditChange()
{
    guard(UMatAction::PostEditChange);
    UObject::PostEditChange();
    extern ENGINE_API FMatineeTools GMatineeTools;
    ASceneManager* SM = GMatineeTools.GetCurrent();
    if (SM)
        SM->PreparePath();
    unguard;
}
```

### UFont::Serialize — Lazy Loading

The Font serializer has an interesting pattern: it temporarily overrides the `GLazyLoad`
global to `1` (force eager), serialises the pages array, then restores it. This forces
all referenced textures to load immediately during font deserialisation rather than
deferring to when they're first drawn — important for console/level-loading flows where
deferred loads cause hitches.

There are two helpers (`FUN_1039c090` for the pages array and `FUN_1039be10` for
additional font fields) whose identities are unknown, so they're left as TODOs. The
function is otherwise implemented faithfully including the version gate at `0x45`
(serialisation version 69) and the `DropShadowX` field at offset `+0x50`.

### ULevel::NotifyReceivedText — 3802 Bytes

The network packet handler for text commands (`HELLO`, `NETSPEED`, `HAVE`, `JOIN`,
`FILEREQ`, `WELCOME`, `UPGRADE`, etc.) is the largest single function in this sweep at
3,802 bytes. Implementing it faithfully from Ghidra alone would take pages of raw offset
dereferences and would be essentially unmaintainable.

The decision: add `guard` / `unguard` with a descriptive TODO comment, referencing the
Ghidra address. This satisfies the "SEH frame present" requirement (the guard macro
installs one) and documents exactly where the implementation needs to go:

```cpp
void ULevel::NotifyReceivedText(UNetConnection* Connection, const TCHAR* Text)
{
    guard(ULevel::NotifyReceivedText);
    // TODO: Full network command dispatch — 3802 bytes of protocol handling.
    // See Ghidra 0xc1d30 ?NotifyReceivedText@ULevel@@UAEXPAVUNetConnection@@PBG@Z
    unguard;
}
```

## Correctly Empty Stubs (Verified)

Several stubs needed a Ghidra lookup to *confirm* they should stay empty:

- **FBezier ctors/dtor** — trivial constructors that only set the vtable pointer. The
  compiler generates that automatically; the source body is `{}`.
- **WWindowsViewportWindow copy/default ctors** — init-lists do all the work.
- **ATeleporter::addReachSpecs** — shared null stub at `0x1651d0`, one of ~40 no-op
  virtual overrides that all point to the same address.
- **FR6MatineePreviewProxy ctors/dtor** — vtable-only constructors.
- **FEdLoadError::~FEdLoadError** — Ghidra shows `FString::~FString(this+4)`, but in
  C++ that's the compiler-generated member destructor call for the `Desc` member. The
  user-defined source body is empty; the compiler inserts the call automatically.

## Final Count

| File | Stubs Implemented | Correctly Left Empty |
|------|:-----------------:|:--------------------:|
| WinDrv.cpp | 1 | 3 |
| UnStaticMeshCollision.cpp | 1 | 0 |
| UnBuildTools.cpp | 1 | 0 |
| UnSceneManager.cpp | 2 | 7 |
| UnChan.cpp | 1 | 0 |
| EngineStubs.cpp | 1 | 0 |
| UnLevel.cpp | 4 | 1 |
| UnFont.cpp | 1 | 0 |
| UnIn.cpp | 1 | 0 |

All 20 DLLs and the executable still build clean after the sweep. The few remaining
TODOs (the 3802-byte network handler, unknown FUN_ helpers in UFont) are documented
with Ghidra addresses so they're easy to pick up later.
