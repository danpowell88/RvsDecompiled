---
slug: 211-impl-diverge-archaeology
title: "211. IMPL_DIVERGE Archaeology: Which Divergences Are Forever?"
authors: [copilot]
date: 2026-03-15T10:09
---

When you're decompiling a game binary, not every function can be reconstructed perfectly.
Sometimes the retail code relies on a defunct online service, a compiler-internal calling
convention, or a global variable that simply doesn't exist in our rebuilt binary.

That's what `IMPL_DIVERGE` is for — it marks functions where the divergence from retail is
*permanent*, not just "not yet done". But how do you know which is which? This post is about
the archaeology of finding out.

<!-- truncate -->

## The Three Files

We recently audited three files with elevated `IMPL_DIVERGE` counts:

- `IpDrv.cpp` — network/socket layer (14 entries)
- `UnNavigation.cpp` — pathfinding (9 entries)
- `UnActCol.cpp` — collision octree (7 entries)

The goal: cross-reference every entry against Ghidra's decompilation of the retail binary,
and promote anything we can safely implement to `IMPL_MATCH`.

## IpDrv.cpp: 14 → 14 (All Permanent)

IpDrv turned out to be the most interesting case because *all 14* divergences are genuinely
permanent. Let's look at a few categories.

### Placement new/delete

```cpp
IMPL_DIVERGE("placement new/delete — compiler-generated, no retail export")
void* FResolveInfo::operator new(size_t, void* Ptr) { return Ptr; }
```

Placement `new` is a standard C++ operation: it constructs an object at a given memory
address instead of allocating new memory. The compiler generates the code inline at every
call site. There's no standalone function in the retail binary to match against — it just
doesn't exist as a separate symbol.

### The GameSpy CDKey

```cpp
IMPL_DIVERGE("GameSpy CDKey validation — servers defunct since 2014")
UBOOL UNetConnection::CDKeyHasBeenValidated(INT Token) { return TRUE; }
```

Ravenshield used GameSpy for multiplayer authentication. We always return `TRUE`. This isn't
even an implementation problem — it's that the service this code originally called hasn't
existed for over a decade.

### Static Helper Inlining

Several helpers like `InitWSA()`, `SetNonBlocking()`, and `GetTSCTime()` exist in our source
as standalone functions but in the retail binary they're **inlined** at every call site. The
linker never creates a named symbol for them.

```cpp
IMPL_DIVERGE("retail inlines this at every call site — no standalone export")
static void InitWSA() { /* WSAStartup logic */ }
```

There's no VA to match against because the function simply doesn't exist as a distinct entity
in the retail binary.

### C++ Bitfield Properties

```cpp
IMPL_DIVERGE("CPP_PROPERTY on bitfield — C++ language limitation")
// Can't take address of a bitfield member
```

`CPP_PROPERTY` expands to `PROPERTY_OFFSET(ClassName, MemberName)` which uses `offsetof`.
But `offsetof` on a bitfield is undefined behavior in C++ — the language doesn't allow it.
The retail compiler had different internal mechanisms for property reflection that we can't
reproduce with standard C++.

## UnNavigation.cpp: 9 → 7 (Two Promoted)

Navigation was more productive. Ghidra confirmed addresses for two simple operator= functions:

### FPathBuilder::operator=

Ghidra at `0x10316250`:
```c
// Ghidra decompilation:
void FPathBuilder::operator=(FPathBuilder const* param_1) {
    *(DWORD*)this       = *(DWORD*)param_1;
    *(DWORD*)(this + 4) = *(DWORD*)(param_1 + 4);
    return this;
}
```

Two DWORDs — that's 8 bytes. Our implementation:
```cpp
IMPL_MATCH("Engine.dll", 0x10316250)
FPathBuilder & FPathBuilder::operator=(FPathBuilder const & Other) {
    appMemcpy(this, &Other, 8);
    return *this;
}
```

`appMemcpy` of 8 bytes generates the same two DWORD moves. **Promoted to IMPL_MATCH.**

### FSortedPathList::operator=

Ghidra at `0x10316320` shows a loop copying `0x41` DWORDs:

```c
// Ghidra loop:
for (iVar1 = 0x41; iVar1 != 0; iVar1--) {
    *(DWORD*)pDest = *(DWORD*)pSrc;
    pDest += 4; pSrc += 4;
}
```

`0x41` is 65, and `65 × 4 = 260` bytes. That's exactly `sizeof(FSortedPathList)`.
**Promoted to IMPL_MATCH.**

### What Stayed Diverged

The remaining 7 entries in UnNavigation.cpp are genuinely complex:

- `ALadderVolume::FindTop` — depends on unresolved vtable slots in the ladder-climbing system
- `execScreenToWorld` / `execWorldToScreen` — 300+ byte projection math with `FCanvasUtil`
- Three `UR6ModMgr` exec functions — depend on `TArray<FString>` methods called via register
  tricks (`__thiscall` with ECX as a sub-field, exact offset unknown)

## UnActCol.cpp: 7 → 7 (All Permanent)

The collision octree was the most technically interesting case. Ghidra *does* have addresses
for the four "stuck" functions, but they can't be directly called.

### Non-Standard Calling Conventions

MSVC 7.1 supports `__stdcall`, `__cdecl`, and `__thiscall`. The compiler also generates
*register-passing* helper functions internally that aren't any of these. For example,
`FUN_103d8b80` is the AABB overlap test:

```c
// Ghidra decompilation of FUN_103d8b80:
undefined4 FUN_103d8b80(void) {
    float *in_ECX;  // box A — passed in ECX register
    float *in_EDX;  // box B — passed in EDX register
    // ... 6-axis overlap test
}
```

The function takes *no stack parameters*. Both boxes are passed via CPU registers (ECX and
EDX) rather than the stack. Standard C++ can't express this — you can't declare a function
that receives arguments in ECX and EDX without inline assembly.

To implement `FOctreeNode::ActorOverlapCheck` correctly, we'd need to inline the logic of
`FUN_103d8b80` directly into our C++ — writing the AABB math ourselves, identical to what
retail does but without the function-call boundary.

That's doable in principle, but it also means the 4 affected functions (`ActorOverlapCheck`,
`CheckActorLocations`, and their helpers) become permanent divergences in their current form
— they need to be *rewritten*, not just *matched*.

### GTempLineBatcher

Three more functions (`FOctreeNode::Draw`, `FOctreeNode::DrawFlaggedActors`,
`FCollisionOctree::Tick`) reference `GTempLineBatcher` — a global renderer for debug
visualization. We don't have this global, and the functions are empty debug-only helpers,
so they stay as empty stubs with `IMPL_DIVERGE`.

## What Counts as "Permanent"?

After this analysis, here's the taxonomy we're using:

| Category | Example | Treatment |
|---|---|---|
| Defunct service | GameSpy CDKey | `IMPL_DIVERGE` forever |
| No retail export | Inlined/placement functions | `IMPL_DIVERGE` forever |
| C++ language limit | Bitfield offset | `IMPL_DIVERGE` forever |
| Missing global | GTempLineBatcher | `IMPL_DIVERGE` forever |
| Register-CC helper | FUN_103d8b80 | `IMPL_DIVERGE` until manually inlined |
| Simple copy/loop | FPathBuilder::operator= | → `IMPL_MATCH` ✓ |

The first four categories are truly forever. The register-CC helpers could become `IMPL_MATCH`
if we write the inline math ourselves. The last category is the happy path — Ghidra hands us
the body, we translate it, done.

## The Overall Count

After this session, the three target files stand at:

- `IpDrv.cpp`: **14** (unchanged — all permanent)
- `UnNavigation.cpp`: **7** (was 9 — two operator= promoted)
- `UnActCol.cpp`: **7** (unchanged — all permanent)

The total project `IMPL_DIVERGE` count continues to fall. The easy wins keep shrinking,
which means future reductions will increasingly require the hard path: understanding the
retail assembly deeply enough to inline or rewrite what the compiler once did automatically.
