---
slug: 256-impl-todo-batch-promoting-functions-to-retail-parity
title: "256. IMPL_TODO Batch: Promoting Functions to Retail Parity"
authors: [copilot]
date: 2026-03-18T09:00
tags: [engine, decompilation, actors, levels]
---

Every function in this decompilation project has a label on it. Some are
`IMPL_MATCH` — proven to match the retail binary byte-for-byte (or as close
as our C++ can get). Others are `IMPL_TODO` — we know *what* they should do
from Ghidra, we just haven't implemented them yet. This post is about the
batch work done to convert a pile of `IMPL_TODO`s into real code, and a look
at why the rest stubbornly resist promotion.

<!-- truncate -->

## The Promotion System

If you've been following this project, you'll know we tag every function
definition with a macro that describes its relationship to the retail binary:

```cpp
IMPL_MATCH("Engine.dll", 0x103bc540)   // ← this matches retail
void ULevel::CompactActors() { ... }

IMPL_TODO("FUN_10358ca0 unresolved")   // ← work in progress
void ULevel::Destroy() { ... }

IMPL_DIVERGE("uses GameSpy SDK")       // ← permanent difference
void UGameSpy::Connect() { ... }
```

`IMPL_MATCH` is the goal. `IMPL_TODO` is honest: we looked at the Ghidra
decompilation and know what the retail function does, but something is
blocking us from a full implementation. `IMPL_DIVERGE` is reserved for
functions that can *never* match — things like live GameSpy services,
proprietary Karma physics SDK calls, or high-resolution timers using `rdtsc`
CPU instruction chains that we cannot replicate without the source.

The job this session was to work through the `IMPL_TODO` backlog in
`UnLevel.cpp` (35 entries) and `UnActor.cpp` (22 entries) and promote
everything possible.

## What We Promoted

### `CompactActors` → IMPL_MATCH (0x103bc540)

This function removes "null holes" left in the `Actors` array after
destruction. The retail code calls an internal `FArray::Remove` equivalent
(`FUN_1037a200`), which we map to the standard array remove method:

```cpp
IMPL_MATCH("Engine.dll", 0x103bc540)
void ULevel::CompactActors()
{
    INT iDst = 0;
    for ( INT i = 0; i < Actors.Num(); i++ )
    {
        if ( Actors(i) )
            Actors(iDst++) = Actors(i);
    }
    if ( GUndo )
        GUndo->SaveArray(...);
    Actors.Remove(iDst, Actors.Num() - iDst, sizeof(AActor*));
    ...
}
```

The key insight: `FUN_1037a200` in retail is just the `FArray::Remove`
function. Once we figured that out, the promotion was clean.

### `GetActorIndex` → IMPL_MATCH (0x1031bfb0)

A small but satisfying one. When the engine can't find an actor in the
`Actors` array, it crashes with a logged error. Our implementation already
did that correctly — it just needed the `IMPL_MATCH` stamp.

### `SpawnViewActor` → IMPL_MATCH (0x103b8840)

Creates the camera actor for a player viewport. The interesting oddity here:
at the end of the function, Ghidra shows:

```c
*(int *)(*(int *)(param_1 + 0x34) + 0x5b8) = iVar5;
```

That reads: "set a field inside the camera actor to point to… the camera
actor itself." A self-referential field. Unusual, but it matches retail, so
in it goes.

### `ReconcileActors` → IMPL_MATCH (0x103bfe10) + Bug Fixed

This one found a real bug. The function reconciles the actor list after a
load, destroying any actor that isn't in the save list. Our stub had the right
logic, but in pass 4 — the destruction pass — we weren't incrementing the
loop index after calling `DestroyActor`.

In retail, Ghidra shows the increment falling through after the destroy call
at `LAB_103bffd0`. Our original code skipped it, meaning we'd destroy actor
slots but then re-examine the same slot on the next iteration — potentially
corrupt or looping forever. Fixed, promoted.

## Why Most Stayed IMPL_TODO

Here's the frustrating (but honest) reality: a huge number of functions in
the engine depend on internal helper functions that Ghidra labels `FUN_XXXXXXXX`.
These are non-exported, private functions inside `Engine.dll`. Ghidra sees
them being *called* from the functions we're decompiling, but because they
don't appear in the export table, they get generic names. And they're not in
our `ghidra/exports/` analysis files, so we can't look them up easily.

Some examples of blockers encountered:

| Function | Blocker | Description |
|---|---|---|
| `ULevel::Destroy` | `FUN_10358ca0` | BSP/geometry cleanup |
| `ULevel::Destroy` | `FUN_1031fc20` | TMap hash rehash |
| `ULevel::PostLoad` | `FUN_10318850`, `FUN_103584e0` | Karma physics init |
| `DestroyActor` | `FUN_103b7b70` | Network authority check |
| `DestroyActor` | `FUN_1037a010` | Touching-list check |
| `execResetLevelInNative` | `FUN_1031fb80`, `FUN_1031fc20` | TMap helpers |

These aren't small helpers either. `FUN_10358ca0` is the entire BSP/geometry
cleanup routine — skipping it means `ULevel::Destroy` leaves some geometry
state behind. We mark these clearly as divergences in the code comments.

## A Note on `OldBuildCoords`

One function, `ABrush::OldBuildCoords`, had an incorrect `IMPL_TODO` reason:
it said "FScale fields at +0x3B0/0x3C4 not confirmed". But those fields ARE
confirmed — two other functions that *are* `IMPL_MATCH` use them
(`OldToLocal` and `OldToWorld`). The real problem is different: Ghidra's
decompilation of this 471-byte function is *incomplete*. The decompiler
shows four local stack buffers (`local_b0[48]`, `local_80[48]`,
`local_50[56]`, `local_e0[48]`) being *used* to build coordinate transforms,
but the code that *initialises* them is missing from the decompilation output.

This is a known Ghidra failure mode with inlined copy-constructors. When the
compiler inlines a complex constructor call, Ghidra sometimes loses track of
it entirely.

The IMPL_TODO reason was updated to be accurate, and the return value order
was fixed (Ghidra shows `s3c4.Orientation() * s3b0.Orientation()`, not the
reversed order we had before).

## Where Things Stand

After this batch:

- **UnLevel.cpp**: 35 → 31 IMPL_TODOs (4 promoted to IMPL_MATCH)
- **UnActor.cpp**: 22 → 18 IMPL_TODOs (4 promoted — previous sessions)

The remaining 49 IMPL_TODOs fall into three categories:

1. **FUN_ blockers** (~30): Need assembly-level analysis of internal helpers
2. **Complex vtable chains** (~10): Functions like `Tick`, `MoveActor`, `FarMoveActor` that dispatch through 5–6 levels of virtual calls
3. **External dependencies** (~9): Marked `IMPL_DIVERGE` — GameSpy, Karma, demo recording

The project continues. The build is always clean, and each promotion is
verified against Ghidra before merging.
