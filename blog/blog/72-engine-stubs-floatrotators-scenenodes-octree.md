---
slug: 72-engine-stubs-floatrotators-scenenodes-octree
title: "72. Float Rotators, Scene Nodes, and Octree Debug Methods"
date: 2026-03-13T22:11
authors: [rvs-team]
tags: [decompilation, engine, math, networking]
---

Today's session tackled a focused set of stubs in `EngineStubs.cpp`, turning several
empty or approximated bodies into accurate implementations verified against the Ghidra
decompilation of the retail `Engine.dll`.

<!-- truncate -->

## What We Were Working With

`EngineStubs.cpp` is the workhorse file of the decompilation project. It provides
compiled bodies for every Engine symbol that's exported from the DLL but hasn't been
fully reverse-engineered yet. Without it, the linker would fail to resolve ordinals
and the DLL simply wouldn't build. As the project matures, stubs migrate out of this
file into proper per-class source files. For now, it's our scaffolding.

## FRotatorF — Floating-Point Rotators

Unreal Engine uses `FRotator` for actor orientations, but the values are stored as
**integers** (0–65535 representing a full rotation). For situations where you need
fractional precision — interpolating rotations in cinematics, for instance — there's
a sibling type `FRotatorF` with `float Pitch`, `float Yaw`, `float Roll`.

The operators were already in the file, but `Rotator()` (which converts back to the
integer `FRotator`) had a subtle bug:

```cpp
// Wrong — C cast truncates toward zero
FRotator FRotatorF::Rotator() { return FRotator((INT)Pitch, (INT)Yaw, (INT)Roll); }

// Correct — appRound uses the x87 FISTP instruction (round-to-nearest)
FRotator FRotatorF::Rotator() { return FRotator(appRound(Pitch), appRound(Yaw), appRound(Roll)); }
```

The difference matters. The retail binary uses `FUN_1050557c`, which Ghidra shows
consuming values off the x87 FPU stack via the `fistp` instruction. That instruction
respects the FPU rounding mode (round-to-nearest by default). A C-style `(INT)` cast
truncates toward zero — for a value like `32767.6` that's a difference of a whole
integer unit.

`appRound` is defined in `UnVcWin32.h` as:

```cpp
inline INT appRound( FLOAT F ) {
    INT I;
    __asm fld [F]
    __asm fistp [I]
    return I;
}
```

Pure x87 assembly — no surprises, matches the retail behaviour exactly.

## FSceneNode Subclass Getters — The Cheapest Virtual Methods

The `FSceneNode` hierarchy has several typed "downcast" getters:

```cpp
virtual FActorSceneNode*    GetActorSceneNode()    { return this; }
virtual FCameraSceneNode*   GetCameraSceneNode()   { return this; }
virtual FMirrorSceneNode*   GetMirrorSceneNode()   { return this; }
virtual FSkySceneNode*      GetSkySceneNode()      { return this; }
virtual FWarpZoneSceneNode* GetWarpZoneSceneNode() { return this; }
```

These are already correct in the stubs. Ghidra confirms: all five subclass overrides
share address `0x1a90` in the DLL — a single three-byte function that just returns
`this`. The base `FSceneNode` versions return `NULL` (they share a different shared
stub address).

This is a common UE2 pattern for avoiding RTTI overhead: instead of `dynamic_cast`,
call a virtual method and check for null.

## FVertexStream Constructors — Already Done

The vertex stream classes (`UVertexBuffer`, `UVertexStreamCOLOR`, `UVertexStreamUV`,
etc.) all had correctly sized constructors from a previous session. Ghidra confirmed
the `ElementSize`, `StreamFlags`, and `StreamType` values we were already using.

## FInBunch / FOutBunch — Networking Bunches

Unreal's networking layer packages data in "bunches" — `FInBunch` for received data
and `FOutBunch` for data being sent. Both inherit from the bit-packing classes
`FBitReader` and `FBitWriter`.

The constructors in the stubs use `appMemcpy`/`appMemzero` rather than calling the
proper base-class copy constructors. This is a known divergence — we can't call
`FBitReader(const FBitReader&)` or `FBitWriter(INT MaxBits)` from `EngineStubs.cpp`
because `FBitReader`/`FBitWriter` come from `Core.dll` and aren't fully exposed in
the headers we have available. Each divergence is now documented with a comment:

```cpp
// DIVERGENCE: retail calls FBitReader copy-ctor then sets vtable + individual fields
//             (offsets 0x54-0x6e). We memcpy the whole object; FBitReader internals
//             that reference allocated memory may alias incorrectly at runtime.
FInBunch::FInBunch(const FInBunch& Other) : FBitReader() { appMemcpy(this, &Other, sizeof(*this)); }
```

For `FOutBunch(UChannel*, INT)`, the retail does something clever: it pre-calculates
how many bits the bunch needs based on `connection->MaxPacket * 8 - 81`, calls
`FBitWriter::FBitWriter(maxBits)` to pre-allocate exactly the right buffer, then
wires up the channel index, sequence number, and reliability flags. Our stub zeros
everything, which is safe for a stub but won't work when networking is actually active.

## FCollisionHash Debug Methods — Actually Empty in Retail

The `FCollisionHash` class is the grid-based spatial hash used for collision detection.
It has three debug methods: `CheckActorLocations`, `CheckActorNotReferenced`, and
`CheckIsEmpty`. These were already empty stubs — and it turns out that's exactly right.

Ghidra shows all three share the same address in the retail binary (`0x1651d0` or
`0x176d60`) — a stub that's shared by dozens of other "no-op virtual" methods across
the codebase. They genuinely do nothing in the shipping game. The comments now say so:

```cpp
// retail: empty (ordinal 2351 shares address 0x1651d0 with dozens of other no-op virtuals)
void FCollisionHash::CheckActorLocations(ULevel * p0) {}
```

## FOctreeNode Debug Methods — Actually Implemented in Retail

The octree counterparts, however, *are* implemented. `FOctreeNode::CheckIsEmpty` logs
the name of every actor still sitting in the node, then recurses into up to 8 children.
`FOctreeNode::CheckActorNotReferenced` does the same but logs to `GError` instead of
`GLog`.

To understand the implementation we need to know the `FOctreeNode` memory layout,
which Ghidra reveals clearly:

```
offset 0x00: TArray<AActor*>::Data  (pointer to the actor array)
offset 0x04: TArray<AActor*>::Num   (actor count)
offset 0x08: TArray<AActor*>::Max   (capacity)
offset 0x0c: FOctreeNode* children  (pointer to block of 8 × 0x10-byte child nodes)
```

Each node is exactly **16 bytes** in memory (`4 + 4 + 4 + 4`), which is why children
are iterated as `base + i * 0x10`. Our header placeholder `BYTE Pad[64]` is larger
than necessary but doesn't cause problems since we access everything via raw pointer
arithmetic anyway.

The implementations now look like:

```cpp
void FOctreeNode::CheckIsEmpty()
{
    void* DataPtr     = *(void**)Pad;
    INT   Count       = *(INT*)(Pad + 4);
    for (INT i = 0; i < Count; i++)
    {
        AActor* A = ((AActor**)DataPtr)[i];
        if (A) GLog->Logf(TEXT("%s"), A->GetName());
    }
    void* ChildrenBase = *(void**)(Pad + 0xc);
    if (ChildrenBase)
        for (INT i = 0; i < 8; i++)
            ((FOctreeNode*)((BYTE*)ChildrenBase + i * 0x10))->CheckIsEmpty();
}
```

One caveat: the Ghidra decompilation shows `Logf(GLog, vtable_ptr_of_GLog)` as the
format string argument, which is clearly a decompiler artefact (it misidentified a
register value). The actual call almost certainly logs the actor name. We document
this with a `// DIVERGENCE: format string approximated` comment.

`FCollisionOctree::CheckIsEmpty` is the thin wrapper that kicks off the recursion
from the root node:

```cpp
void FCollisionOctree::CheckIsEmpty()
{
    FOctreeNode* Root = *(FOctreeNode**)Pad;
    if (Root) Root->CheckIsEmpty();
}
```

This matches Ghidra exactly: `FOctreeNode::CheckIsEmpty(*(FOctreeNode**)(this + 4))`.

## What's Still a Stub

- **`FOctreeNode::Draw`** — Ghidra shows it uses `GTempLineBatcher` to draw the
  node's bounding box and recurse into children. It needs the `FTempLineBatcher`
  infrastructure to be wired up first.
- **`FCollisionOctree::CheckActorLocations`** — A complex per-frame geometry check
  that walks `Level->Actors` and tests overlap per octree node. Needs deeper analysis.
- **`FOutBunch(UChannel*, INT)` and `FInBunch(UNetConnection*)`** — Need the proper
  `FBitReader`/`FBitWriter` constructors, which requires more Core networking work.

The build passes clean (only the pre-existing vtable export warnings remain), and all
changes are committed.

