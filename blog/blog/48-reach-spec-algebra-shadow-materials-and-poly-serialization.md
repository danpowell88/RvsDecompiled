---
slug: batch-163-reach-spec-algebra-shadow-materials-and-poly-serialization
title: "Batch 163: Reach Spec Algebra, Shadow Material Cleanup, and Polygon Serialization"
authors: [dan]
tags: [decompilation, ue2, pathfinding, materials, serialization]
---

Batch 163 rounds out the `UReachSpec` graph manipulation interface, cleans up `UShadowBitmapMaterial`'s GPU buffers, and brings `UPolys::Serialize` back to life — the foundation of the BSP polygon workflow.

<!-- truncate -->

## The Reach Spec Algebra: `operator+` and `operator<=`

`UReachSpec` objects represent directed edges in the AI navigation graph.  Two operators let the engine compose and compare them.

### `operator<=` — Dominance Check

```cpp
int UReachSpec::operator<=(UReachSpec const& other)
```

Returns 1 when `other` is at least as permissive as `this` — i.e. `other` dominates `this`.  Three conditions must all hold:

| Field | Condition |
|---|---|
| `CollisionRadius` | `other.CollisionRadius >= this.CollisionRadius` |
| `CollisionHeight` | `other.CollisionHeight >= this.CollisionHeight` |
| `reachFlags` | `(this.reachFlags \| other.reachFlags) == other.reachFlags` (other is a superset) |
| `MaxLandingVelocity` | `this.MaxLandingVelocity <= max(other.MaxLandingVelocity, 590)` |

The constant **590 (0x24E)** is the threshold below which a landing velocity is treated as "effectively unlimited".  If both specs have velocities below that threshold the velocity dimension is irrelevant.

### `operator+` — Path Composition

```cpp
UReachSpec* UReachSpec::operator+(UReachSpec const& other) const
```

Allocates a fresh `UReachSpec` in the same outer package via `UObject::StaticConstructObject`, then fills it with the *worst-case* capabilities of the two combined hops:

```
new->CollisionRadius     = min(a, b)    // narrowest passage wins
new->CollisionHeight     = min(a, b)    // shortest ceiling wins
new->reachFlags          = a | b        // union of all constraints
new->Distance            = a + b        // paths add
new->MaxLandingVelocity  = max(a, b)    // harshest landing wins
```

The semantics match physical intuition: concatenating two paths means a bot must satisfy every constraint encountered along the way.

---

## `UShadowBitmapMaterial::Destroy`

Shadow bitmap materials hold two heap-allocated rasterisation buffers at fixed offsets:

```
+0x9C  → buffer A (rendered shadow map)
+0xA0  → buffer B (working accumulation buffer)
```

`Destroy()` calls `GMalloc->Free()` on both pointers (if non-null), then delegates to `UObject::Destroy()`:

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

The pattern mirrors `UMotionBlur::Destroy` from Batch 162 — a recurring idiom where render-side objects own raw CPU copies of GPU data and must clean them up manually.

---

## `UPolys::Serialize` — BSP Polygon Packing

`UPolys` holds the BSP polygon list used throughout the editor and level-build pipeline.  Its `Serialize` implementation covers two paths: **transient** (undo/redo clipboard) and **persistent** (`.unr` disk format).

### Layout

The `FPoly` `TArray` lives at `this+0x2C` (first field after the `UObject` base).  `sizeof(FPoly) == 0x15C` (348 bytes).

### Disk path (non-transient)

```
UObject::Serialize(Ar);
CountBytes(stride=0x15C);   // memory statistics
[INT32 Num] [INT32 Max]     // raw array header
for each FPoly: Ar << poly  // full polygon stream
```

The array header (`Num` + `Max`) is written raw via `ByteOrderSerialize`.  `FArray::ArrayNum` and `FArray::ArrayMax` are **protected** in the SDK headers, so they are accessed via a raw pointer offset — `FArray` layout is `{void* Data, INT ArrayNum, INT ArrayMax}`, making `ArrayNum` trivially reachable at `&array + sizeof(void*)`.

### Transient path

The transient path uses `FCompactIndex` variable-length encoding for the count (Unreal's compact int), and skips the explicit `Max` field since the transient copy is always rebuilt from scratch.

---

## Build Notes

All four compile errors from the initial implementation attempt were resolved:

| Error | Fix |
|---|---|
| `C2679: operator<< for FPoly not found` | Added a forward declaration before `UPolys::Serialize` (the definition appears later in the same TU) |
| `C2248: FArray::ArrayNum protected` (×2) | Bypassed via raw pointer arithmetic on the known `FArray` layout |
| `C2661: StaticConstructObject takes != 6 args` | Updated to the correct 7-argument form: `(UClass*, UObject*, FName, DWORD, UObject*, FOutputDevice*, INT)` |

