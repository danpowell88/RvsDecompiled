---
slug: finding-your-way
title: "Finding Your Way — Implementing the Path Builder"
authors: [default]
date: 2025-01-29
tags: [decompilation, pathfinding, bsp, unreal-engine, reverse-engineering]
---

Every game that has NPCs that move around the level needs a way to tell them where they *can* go. Rainbow Six Ravenshield uses Unreal Engine 2's navigation system — a graph of `ANavigationPoint` actors (called "path nodes") connected by `UReachSpec` edges. Before the AI can use these paths, they need to be *built* — a process that involves a dedicated pawn, a lot of line checks, and considerable geometry maths.

This week we tackled the core of that system: the `FPathBuilder` class. Getting here required understanding BSP geometry, vtable archaeology, and some genuinely elegant data structure design. Let's dig in.

<!-- truncate -->

## A Quick Primer: BSP Trees

Before we get into path building, it helps to understand what a BSP tree is. "BSP" stands for *Binary Space Partitioning*. It's a way of organising 3D geometry as a tree of planes.

Imagine you have a room. You pick one wall and call it a *splitting plane*. Everything on one side of that plane goes into the "front" subtree; everything on the other side goes into the "back" subtree. You keep recursively splitting until every piece of geometry lives in its own leaf node.

Why is this useful? Because answering questions like "does this ray hit anything?" or "is this point inside solid space?" becomes a tree traversal — generally much faster than checking every polygon individually.

In Unreal Engine, the world geometry is stored in a `UModel` object. That model contains:

- **Nodes** (the BSP tree nodes) — each representing a splitting plane
- **Surfaces** (the polygon faces)
- **Vertices** (the actual 3D points)
- **Vectors** (normal vectors and texture axes)
- **Verts** (links between nodes and the vertex pool)

These five arrays are the heart of the level's geometry, and they're all packed inside `UModel` with a very specific memory layout.

## Cracking UModel's Memory Layout

One function we needed to implement was `FPoly::SplitWithNode`. An `FPoly` is a convex polygon (used during BSP compilation), and `SplitWithNode` splits it along the plane of a given BSP node. The original code is just a thin wrapper around `SplitWithPlane` — but to call that, we need to extract the plane from a BSP node.

The Ghidra decompilation showed something like this:

```c
iVar1 = SplitWithPlane(this,
    (FVector*)(*(int*)(model + 0x8c) +
               *(int*)(*(int*)(model + 0x6c) +
                       *(int*)(nodeIndex * 0x90 + *(int*)(model + 0x5c) + 0x30) * 8
                      ) * 0xc),
    /* ... normal from Surfs ... */,
    front, back, precise);
```

This looks intimidating but it's actually a beautifully regular pattern. Each `*(int*)(model + offset)` reads the `.Data` pointer from one of `UModel`'s `TTransArray<T>` fields (an array type that combines a raw pointer, count, max, and owner pointer — 16 bytes total). The offsets tell us exactly where each array starts in memory:

| Offset | Field | Element type | Stride |
|--------|-------|-------------|-------|
| `+0x5c` | `Nodes.Data` | `FBspNode` | 0x90 bytes |
| `+0x6c` | `Verts.Data` | `FVert` | 8 bytes |
| `+0x7c` | `Vectors.Data` | `FVector` | 12 bytes |
| `+0x8c` | `Points.Data` | `FVector` | 12 bytes |
| `+0x9c` | `Surfs.Data` | `FBspSurf` | 0x5c bytes |

Notice that `FBspNode` has a stride of **0x90 bytes (144 bytes)** in Ravenshield, versus 64 bytes in UT99. The engine grew considerably between versions — extra fields for zones, terrain, collision bounds.

Once you know the strides, the logic reads naturally:

```cpp
// Where is the first vertex of this BSP node?
INT iVertPool  = *(INT*)(Nodes[nodeIndex] + 0x30);   // FBspNode.iVertPool
INT iVertex    = *(INT*)(Verts[iVertPool] + 0x00);   // FVert.iVertex (first field)
FVector* point = (FVector*)(Points.Data + iVertex * 12);

// What is the surface normal?
INT iSurf   = *(INT*)(Nodes[nodeIndex] + 0x34);      // FBspNode.iSurf
INT vNormal = *(INT*)(Surfs[iSurf]    + 0x0c);       // FBspSurf.vNormal
FVector* normal = (FVector*)(Vectors.Data + vNormal * 12);

return SplitWithPlane(*point, *normal, front, back, precise);
```

It's a chain of array lookups: node → vert → point, and node → surf → normal vector. The final split is just geometry.

## Path Building: The Scout Pattern

Most of the hard work in `FPathBuilder` revolves around a special pawn called **the Scout**. Path building is a runtime operation — to test whether a path node is *reachable* from another location, the engine needs something that can actually move through the world.

The Scout is a cylinder-shaped pawn (defined by a collision radius and half-height) that the path builder spawns, teleports around, and uses to run reachability tests. The `getScout()` function handles finding or creating this Scout:

1. Search the level's actor list for an existing `AScout` pawn
2. If none exists, spawn one via `Level->SpawnActor("Scout", ...)`
3. Spawn a companion `AIController` to drive it
4. Configure it: enable collision, set a path-building flag, initialise its physics volume

One interesting detail: the Scout is stored directly in the `FPathBuilder`'s byte buffer. `FPathBuilder` has a 128-byte pad array, and the first 8 bytes are used as two raw pointers:

```
Pad[0..3] = ULevel*    (stored by buildPaths)
Pad[4..7] = APawn*     (stored by getScout)
```

There's no named struct. No `ULevel* Level` field. Just raw byte offsets. This is typical of internal plumbing code — it predates whatever safe abstraction layers were added on top.

## Vtable Archaeology

In `getScout`, after spawning the Scout, two unnamed virtual methods are called:

```c
(**(code**)(**(int**)(scout) + 0x10c))();  // vtable slot 67
(**(code**)(**(int**)(scout) + 0x114))();  // vtable slot 69
```

No arguments. No names. Just raw vtable offsets on the Scout's class.

These are almost certainly physics or state initialisation calls — something like `SetPhysics` or `PreBeginPlay`. We implement them as typed function pointer calls:

```cpp
typedef void (__thiscall *tVoidFn)(AActor*);
tVoidFn fn1 = *(tVoidFn*)((BYTE*)(*(void**)Scout) + 0x10c);
fn1(Scout);
```

This is the kind of thing that makes decompilation tricky. Ghidra recovered the shape of the code but lost the names. We implement the *structure* faithfully, document the *meaning* as best we can, and move on.

## Collision Toggling for Path Building

`SetPathCollision` is used to temporarily disable collision on blocking actors during path tests. When you're checking if the Scout can reach a path node, you don't want locked doors or blocking volumes getting in the way. The function:

1. **Disable**: scans all actors, marks any with `bBlockPlayers + bCollideActors` set by writing a flag at `Actor+0x320 bit 3`, then calls `SetCollision(0, ...)` on them
2. **Enable**: finds those flagged actors and calls `SetCollision(1, ...)` to restore them, clearing the flag

The temporary flag (bit 3 of a field at actor offset `+0x320`) is never exposed in public headers — it's purely an internal marker used by the path builder. We write it as a raw bit operation.

## What's Next

We're now at around **162 trivial stubs remaining** in `EngineStubs.cpp`. The low-hanging fruit (simple math, serialization, flag manipulation) has largely been picked. What remains falls into a few categories:

- **Path builder internals** — `Pass2From`, `testPathsFrom`, `createPaths`, `buildPaths`. These are 100-250 line algorithms that call everything we've just implemented.
- **Octree collision** — `FCollisionOctree` and `FOctreeNode` — a spatial acceleration structure for collision queries. Separate from the FCollisionHash we've already done.
- **Scene nodes** — `FLevelSceneNode`, `FActorSceneNode` and friends — the rendering pipeline's abstraction over what to draw.
- **Stats and graph** — `FStatGraph`, `FStats` — profiling and debug visualisation tools.

Most of the complex ones depend on each other, so we'll likely tackle them in reverse dependency order — getting the building blocks in place before assembling the larger algorithms.

The path is getting clearer. Appropriate, given what we just built.
