---
slug: batch-164-165-skeletal-anim-anatomy-lod-footprints-channel-ops
title: "Batches 164–165: Skeletal Anim Anatomy, LOD Footprints, and Channel Ops"
authors: [dan]
tags: [decompilation, ue2, skeletal-mesh, animation, memory]
---

Batches 164 and 165 dive deep into the skeletal mesh animation subsystem — memory accounting, decal management, and the per-channel state machine that drives every weapon raise, crouch, and reload in Rainbow Six 3.

<!-- truncate -->

## Batch 164: AR6DecalGroup, LOD/MemFootprint, and Anim Queries

### `AR6DecalManager::FindGroup` — Decal Dispatch Table

Rainbow Six 3's decal system organises bullet holes and scorch marks into five groups (`eDecalType` 0–4).  The manager holds a raw pointer to each group at fixed offsets in its own body:

```cpp
AR6DecalGroup * AR6DecalManager::FindGroup(eDecalType type)
{
    switch (type) {
        case 0: return *(AR6DecalGroup**)((BYTE*)this + 0x398);
        case 1: return *(AR6DecalGroup**)((BYTE*)this + 0x39C);
        case 2: return *(AR6DecalGroup**)((BYTE*)this + 0x3A0);
        case 3: return *(AR6DecalGroup**)((BYTE*)this + 0x3A4);
        case 4: return *(AR6DecalGroup**)((BYTE*)this + 0x3A8);
        default: return NULL;
    }
}
```

Classic enum-indexed pointer table.  No runtime lookup structures — just five consecutive `DWORD` slots in the manager at `+0x398`.

### `USkeletalMesh::LODFootprint` — Per-LOD Memory Accounting

The engine needs to know how much GPU/CPU memory each LOD model occupies, both for streaming decisions and for diagnostic display.  The function tallies up every typed array inside an LOD struct (`stride = 0x11C` bytes, stored in `TArray` at `this+0x1AC`):

| Array offset in LOD element | Element size | Field |
|---|---|---|
| `+0x00` | 4 | Index buffer (WORD pairs?) |
| `+0x0C` | 16 | Vertex weights |
| `+0x1C` | 20 | Vertex data |
| `+0x28` | 20 | Influence data |
| `+0x38` | 2 | Smooth indices |
| `+0x54` | 2 | Raw vertex indices |
| `+0x8C` | 32 | Tangent basis |
| `+0x98` | 2 | Compressed indices |

When `param_2 == 0` (include render streams), four additional arrays are counted: vertex position (`+0xB0`), vertex UV (`+0xC8`), normal (`+0xE0`), and tangent (`+0xF8`).

The base fixed cost per LOD struct is **0xBC bytes** (structural overhead), and the total is accumulated across all LODs.

### `USkeletalMesh::MemFootprint` — Full Mesh Footprint

`MemFootprint` builds on `LODFootprint` logic by adding the mesh-global arrays:

| Offset | Element size | Field |
|---|---|---|
| `this+0x100` | 12 | Bone hierarchy |
| `this+0x118` | 4 | Bone name map |
| `this+0x130` | 12 | Attach point positions |
| `this+0x148` | 12 | Attach point orientations |
| `this+0x160` | 8 | Bone refs |
| `this+0x178` | 2 | LOD mapping |
| `this+0x190` | 2 | Bone-to-LOD table |

Plus four extra animation/collision arrays at `+0x2B8`, `+0x2D0`, `+0x2DC`, `+0x2E8` rounded up to multiples of 48 bytes (`0x30`).

### Anim Query Triad: `IsAnimating`, `IsAnimTweening`, `GetAnimCount`

All three functions operate on the channel `TArray` at `this+0x10C` (stride 0x74 bytes per slot).

**`IsAnimating(Channel)`** — Returns 1 if the channel has a non-`None` sequence name AND non-zero playback:
```cpp
FName seqName = *(FName*)(elem + 0x08);
if (seqName == FName(NAME_None)) return 0;
if (*(FLOAT*)(elem + 0x10) < 0.0f) {
    return (*(FLOAT*)(elem + 0x18) != 0.0f) ? 1 : 0;  // tweening backward
}
return (*(FLOAT*)(elem + 0x0C) != 0.0f) ? 1 : 0;       // playing forward
```

**`IsAnimTweening(Channel)`** — A subset of the above: frame `< 0` (negative = tween start) AND the vtable `IsAnimating` check confirms motion:
```cpp
if (*(FLOAT*)(elem + 0x10) >= 0.0f) return 0;
// call vtbl[0xD8/4](this, Channel)
```

**`GetAnimCount()`** — Iterates `UMeshAnimation*` slots at `this+0xAC` (stride 0x18) and sums the sequence counts of each non-null animation object:
```cpp
FArray* arr = (FArray*)((BYTE*)this + 0xAC);
for (INT i = 0; i < arr->Num(); i++) {
    UMeshAnimation* anim = *(UMeshAnimation**)((BYTE*)(*(INT*)arr) + i*0x18);
    if (anim) total += ((FArray*)((BYTE*)anim + 0x48))->Num();
}
```

### `USkeletalMeshInstance::StopAnimating` — Full Channel Flush

`StopAnimating(bClearAll)` zeros the playback state on every channel, and when `bClearAll` is set it also:
- Empties both blend-shape arrays (`this+0x124`, `this+0x130`)
- Optionally clears the morph weight array (`this+0x118`) — spared only for Pawn objects in a special state (magic constant `0xB14E` at owner `+0x3A4`)
- Resets sequence names on channels 1+ to `NAME_None`

---

## Batch 165: Base No-Ops and Channel State Machine

### `UMeshInstance` Base Virtual No-Ops

Five `UMeshInstance` virtuals compile to a single `ret N` instruction — three bytes.  They exist purely as base-class default implementations:

| Function | Stack clean (N) |
|---|---|
| `ClearChannel(int)` | 4 |
| `SetActor(AActor*)` | 4 |
| `SetAnimFrame(int, float)` | 8 |
| `SetMesh(UMesh*)` | 4 |
| `SetScale(FVector)` | 12 |

Subclasses (`USkeletalMeshInstance`, `UVertMeshInstance`) override all of these with real logic.

### `USkeletalMeshInstance::ValidateAnimChannel` — Demand-Growth Channel Array

The most interesting piece in this batch: `ValidateAnimChannel` ensures that the channel TArray can accommodate the requested channel index, growing it on demand:

```cpp
int USkeletalMeshInstance::ValidateAnimChannel(INT Channel)
{
    if (Channel > 255 || Channel < 0) return 1;
    FArray* arr = (FArray*)((BYTE*)this + 0x10C);
    while (arr->Num() <= Channel)
        arr->Add(1, 0x74);  // add one 116-byte slot
    return 1;
}
```

The ceiling of 255 prevents unbounded growth — the channel index space is a byte.  Note that the function **always returns 1**, including for out-of-range inputs: callers treat the return value as "was the channel in a usable state?" not as "was the channel index valid?".

### `USkeletalMeshInstance::ClearChannel` — Slot Reset

`ClearChannel(Channel)` resets all mutable fields in one animation channel slot back to their default states:

| Offset | Field | Reset value |
|---|---|---|
| `+0x08` | Sequence name | `NAME_None` |
| `+0x0C` | Play rate | 0.0 |
| `+0x10` | Current frame | 0.0 |
| `+0x18` | Tween amount | 0.0 |
| `+0x38` | Loop flag | 0 |
| `+0x50` | Notifier state | 0 |
| `+0x5C` | (internal) | 0 |
| `+0x60` | (internal) | 0 |

Unlike `StopAnimating`, this targets a single channel rather than all channels.

### `USkeletalMeshInstance::ForceAnimRate` — Rate Override

A lightweight sibling of `SetAnimRate`: writes the new rate directly into the channel element without any blend or transition logic:

```cpp
// elem+0x0C = rate float
*(FLOAT*)(elem + 0x0C) = Rate;
```

The "Force" prefix distinguishes it from `SetAnimRate`, which the retail binary shows also handles tween state — whereas `ForceAnimRate` is a raw slot write.

### `SetBoneDirection / SetBoneLocation / SetBoneRotation` — Capacity Guards

Three bone transform setters share the same structural pattern: check whether the respective bone override array is at maximum capacity (256 entries), return 0 if so.  The actual bone override push logic lives in the unimplemented Ghidra sections that reference complex FCoords manipulation — those are deferred to a future batch.

| Function | Override array offset |
|---|---|
| `SetBoneRotation`, `SetBoneLocation` | `this+0x124` |
| `SetBoneDirection` | `this+0x130` |

---

## What's Next

The channel state machine still has several missing pieces: `SetAnimRate` (164b, involves tween-rate logic), `SetAnimSequence` (241b), `BlendToAlpha` (130b), and `PlayAnim` (153b).  These involve more complex blend-tree state transitions and will form the core of Batch 166.
