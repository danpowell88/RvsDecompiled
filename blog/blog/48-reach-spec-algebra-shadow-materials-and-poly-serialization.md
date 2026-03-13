---
slug: batch-163-reach-spec-algebra-shadow-materials-and-poly-serialization
title: "48. Reach Spec Algebra, Shadow Material Cleanup, and Polygon Serialization"
authors: [dan]
tags: [decompilation, ue2, pathfinding, materials, serialization]
---

In real life, if you want to walk from your kitchen to your car, you mentally chain together sub-paths: kitchen → hallway → front door → driveway. Each segment has its own constraints — the hallway might be narrow, the front door requires you to duck if you're tall. The overall path is only as permissive as its *tightest* segment.

Game AI does the same thing, but with math. This batch finishes the AI pathfinding "algebra" — the operators that let the engine combine and compare path segments — then switches gears to shadow rendering cleanup and the level editor's polygon save format. Three completely different subsystems, but each one reveals how Unreal Engine 2 manages complexity through simple, composable primitives.

<!-- truncate -->

## The Reach Spec Algebra: Combining and Comparing Paths

[Last time](/blog/batch-162-pathfinding-network-render) we introduced `UReachSpec` — the edge type in the AI navigation graph. Each reach spec describes a single traversable connection between two navigation points, carrying information about how wide and tall the corridor is, what movement types are required, and how fast you'd be going at the end.

But a single edge isn't very useful on its own. To plan a route, the AI needs to ask two questions:
1. **"If I chain these two paths together, what are the combined constraints?"** (Can I walk through corridor A *and then* corridor B?)
2. **"Is this path at least as good as that one?"** (Could I replace path A with path B without losing access?)

That's what `operator+` and `operator<=` provide.

### `operator<=` — "Is This Path Dominated by That One?"

```cpp
int UReachSpec::operator<=(UReachSpec const& other)
```

Returns 1 when `other` is at least as permissive as `this` — meaning `other` *dominates* `this`. Think of it like comparing hotel rooms: if room B has everything room A has and more, room B dominates. Three conditions must all hold:

| Field | Condition | Plain English |
|---|---|---|
| `CollisionRadius` | `other.CollisionRadius >= this.CollisionRadius` | Other path is at least as wide |
| `CollisionHeight` | `other.CollisionHeight >= this.CollisionHeight` | Other path is at least as tall |
| `reachFlags` | `(this.reachFlags \| other.reachFlags) == other.reachFlags` | Other path supports all the same movement types (superset check) |
| `MaxLandingVelocity` | `this.MaxLandingVelocity <= max(other.MaxLandingVelocity, 590)` | Other path can handle at least as hard a landing |

The constant **590 (`0x24E`)** is the threshold below which a landing velocity is treated as "effectively safe." If both specs have velocities below this, the velocity dimension is irrelevant — neither path involves a dangerous drop.

### `operator+` — "What If I Walk Both Paths Back to Back?"

```cpp
UReachSpec* UReachSpec::operator+(UReachSpec const& other) const
```

This allocates a brand new `UReachSpec` and fills it with the *worst-case* combined constraints of both paths:

```
new->CollisionRadius     = min(a, b)    // narrowest passage wins
new->CollisionHeight     = min(a, b)    // shortest ceiling wins
new->reachFlags          = a | b        // union of all movement requirements
new->Distance            = a + b        // total distance adds up
new->MaxLandingVelocity  = max(a, b)    // harshest landing wins
```

This matches physical intuition perfectly. If you walk through a wide hallway and then a narrow doorway, the combined path width is the doorway's width. If one segment requires swimming and another requires jumping, the combined path requires both. The distance is just the sum. Clean, composable, and exactly what the AI pathfinder needs to evaluate multi-hop routes.

---

## UShadowBitmapMaterial::Destroy — GPU Buffer Cleanup

Shadows in Ravenshield are rendered by projecting darkness onto surfaces using special "shadow bitmap materials." Each shadow material holds two heap-allocated buffers: one for the rendered shadow map (the actual shadow image) and one for an accumulation buffer used during the multi-pass shadow rendering.

When a shadow material is destroyed — maybe the light source moved, or the level is unloading — those buffers need to be explicitly freed. Unlike modern engines with automatic GPU resource tracking, Unreal Engine 2 manages these manually:

```cpp
void UShadowBitmapMaterial::Destroy()
{
    void** buf0 = (void**)((BYTE*)this + 0x9C);
    void** buf1 = (void**)((BYTE*)this + 0xA0);
    if (*buf0) { appFree(*buf0); *buf0 = NULL; }
    if (*buf1) { appFree(*buf1); *buf1 = NULL; }
    UObject::Destroy();
}
```

Note that the pointers are nulled after freeing — a defensive pattern that prevents double-free bugs if `Destroy()` were ever called twice. The pattern mirrors `UMotionBlur::Destroy` from the previous batch — a recurring idiom where render-side objects own raw CPU copies of GPU data and must clean them up manually. In 2003, there were no smart pointers or RAII wrappers for this; you allocated with `appMalloc`, you freed with `appFree`, and you hoped you didn't miss any code paths.

---

## UPolys::Serialize — Saving the Building Blocks of Level Geometry

This is probably the most interesting function in this batch, so let's start with some context.

### What Are BSP Polygons?

Unreal Engine 2 builds its level geometry using a system called BSP (Binary Space Partitioning). At its core, every wall, floor, and ceiling in a Ravenshield map starts life as a *polygon* — a flat shape with vertices, a normal vector, and texture mapping information. These polygons are stored in a `UPolys` object, which is basically a big array of `FPoly` structs.

When you save a level in Unreal Editor, these polygons need to be written to disk. When you load a level, they need to be read back. That save/load process is called *serialization*, and `UPolys::Serialize` is the function that handles it.

What makes this interesting is that Unreal has *two* serialization paths: one for saving to disk (the persistent format used in `.unr` files) and one for undo/redo (the transient format used by the editor's clipboard). They're quite different.

### Layout

The `FPoly` array lives at `this+0x2C` (right after the `UObject` base class). Each `FPoly` is a hefty 348 bytes (`0x15C`) — it contains all the vertex positions, texture coordinates, material references, and flags for one polygon.

### The Disk Path (Persistent)

When saving to a `.unr` file, the format is straightforward:

```
UObject::Serialize(Ar);           // base class data first
CountBytes(stride=0x15C);         // memory statistics tracking
[INT32 Num] [INT32 Max]           // raw array header
for each FPoly: Ar << poly        // full polygon stream
```

The array header (`Num` + `Max`) is written as raw bytes. Here's a subtlety: `FArray::ArrayNum` and `FArray::ArrayMax` are **protected** in the SDK headers, so the code can't access them through the normal API. Instead, it uses raw pointer arithmetic — `FArray`'s memory layout is `{void* Data, INT ArrayNum, INT ArrayMax}`, so `ArrayNum` lives at a known offset from the start of the array. This is a common "the SDK headers are more restrictive than the engine actually needs" workaround.

### The Transient Path (Undo/Redo)

The editor's undo/redo clipboard uses a more compact format. Instead of writing the raw `Num + Max` pair, it uses Unreal's `FCompactIndex` variable-length integer encoding for the count, and skips the `Max` field entirely (since the transient copy is always rebuilt from scratch, pre-allocated capacity doesn't matter). This saves a few bytes per undo operation — not much, but it adds up when you're editing hundreds of polygons.

---

## Build Notes

All four compile errors from the initial implementation attempt were resolved:

| Error | Fix |
|---|---|
| `C2679: operator<< for FPoly not found` | Added a forward declaration before `UPolys::Serialize` (the definition appears later in the same translation unit) |
| `C2248: FArray::ArrayNum protected` (×2) | Bypassed via raw pointer arithmetic on the known `FArray` layout |
| `C2661: StaticConstructObject takes != 6 args` | Updated to the correct 7-argument form: `(UClass*, UObject*, FName, DWORD, UObject*, FOutputDevice*, INT)` |

