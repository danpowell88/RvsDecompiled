---
slug: batch-164-165-skeletal-anim-anatomy-lod-footprints-channel-ops
title: "49. Skeletal Anim Anatomy, LOD Footprints, and Channel Ops"
authors: [copilot]
tags: [decompilation, ue2, skeletal-mesh, animation, memory]
---

When you watch a Rainbow Six operator raise their weapon, peek around a corner, and then crouch — all at the same time — you're seeing the animation *channel system* at work. The engine doesn't play one animation at a time; it runs multiple animations simultaneously on different parts of the body. Channel 0 might be handling the legs (walk cycle), channel 1 the torso (aiming), and channel 2 a weapon reload. Each channel is an independent playback slot with its own play rate, current frame, and looping state.

These two batches dig into the guts of that system: how the engine tracks memory usage for 3D models, how bullet hole decals are organised, and the per-channel state machine that makes multi-part animation possible. There's a lot of low-level detail here, but we'll build up the context before diving in.

<!-- truncate -->

## Batch 164: Decals, Memory Accounting, and Animation Queries

### How Bullet Holes Work — AR6DecalManager::FindGroup

Ever wondered what happens when you shoot a wall in a game? The engine can't modify the wall's texture — that would be absurdly expensive. Instead, it layers a small transparent image (a "decal") on top of the surface at the impact point. In Ravenshield, decals are grouped into five categories — different types of bullet impacts, explosion marks, etc. — and a `AR6DecalManager` keeps track of all of them.

The `FindGroup` function is the dispatch table: given a decal type (an enum from 0 to 4), return the group object that manages that type:

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

No hash tables, no dynamic lookup — just five consecutive pointer slots at fixed offsets in the manager object. When there are only five things to look up, a simple switch statement beats any fancier data structure. This is a recurring pattern in game engines: favour simplicity and cache-friendliness over generality.

### Why Track Memory? — LODFootprint and MemFootprint

Modern games manage enormous amounts of 3D data. A single character model might have thousands of vertices, bone weights, texture coordinates, and normal vectors. The engine needs to know *exactly* how much memory each model consumes so it can make streaming decisions (should we load this model yet?) and display diagnostic information for the artists.

**LOD** (Level of Detail) is a technique where the engine keeps multiple versions of a model at different quality levels. When a character is far from the camera, the engine switches to a lower-detail version with fewer vertices — saving GPU work without the player noticing. Each LOD level has its own set of vertex buffers, index buffers, and weight tables.

`USkeletalMesh::LODFootprint` computes the memory cost of a single LOD level by tallying up every typed array inside it:

| Array offset in LOD | Element size | What it stores |
|---|---|---|
| `+0x00` | 4 bytes | Index buffer entries |
| `+0x0C` | 16 bytes | Vertex weights (which bones influence each vertex) |
| `+0x1C` | 20 bytes | Vertex positions and UVs |
| `+0x28` | 20 bytes | Bone influence data |
| `+0x38` | 2 bytes | Smooth vertex indices |
| `+0x54` | 2 bytes | Raw vertex indices |
| `+0x8C` | 32 bytes | Tangent basis vectors (for lighting) |
| `+0x98` | 2 bytes | Compressed index buffer |

When the caller passes `param_2 == 0` (meaning "include render streams"), four additional arrays are counted: vertex positions, UVs, normals, and tangents in their GPU-ready format. The fixed overhead per LOD struct is `0xBC` bytes (188 bytes of structural bookkeeping), and the total is accumulated across all LOD levels.

`USkeletalMesh::MemFootprint` builds on this by adding the mesh-wide arrays — the bone hierarchy, bone name map, attachment points, and collision data that exist once regardless of how many LOD levels the mesh has.

### Is Anything Playing? — The Animation Query Functions

With the channel system in mind, the engine needs simple queries: "Is channel N currently playing an animation?" "Is it in the middle of a blend transition?" "How many total animation sequences are available?"

**`IsAnimating(Channel)`** checks whether the given channel has a real animation assigned (not `NAME_None`) *and* is actually in motion:
```cpp
FName seqName = *(FName*)(elem + 0x08);
if (seqName == FName(NAME_None)) return 0;
if (*(FLOAT*)(elem + 0x10) < 0.0f) {
    return (*(FLOAT*)(elem + 0x18) != 0.0f) ? 1 : 0;  // tweening backward
}
return (*(FLOAT*)(elem + 0x0C) != 0.0f) ? 1 : 0;       // playing forward
```

The negative frame check at offset `+0x10` is interesting: a negative "current frame" means the channel is in a *tween* (a smooth blend transition between two animations). During a tween, the play rate field at `+0x0C` doesn't apply — instead the tween amount at `+0x18` drives the interpolation.

**`IsAnimTweening(Channel)`** is the more specific query: the channel is tweening if the frame is negative AND the broader `IsAnimating` check passes.

**`GetAnimCount()`** iterates all registered animation objects and sums up the total number of sequences across all of them. This is used by the editor and debug UI to display how many animations are available for a given mesh.

### StopAnimating — The Emergency Brake

`StopAnimating(bClearAll)` zeros the playback state on every channel. When `bClearAll` is set, it also:
- Empties the blend-shape arrays (used for facial morphs and similar deformations)
- Optionally clears the morph weight array — *unless* the owner is a Pawn in a specific state (checked via a magic constant `0xB14E` at offset `+0x3A4`), because killing a currently-morphing pawn mid-animation can cause visual glitches
- Resets sequence names on channels 1+ to `NAME_None` (channel 0 keeps its name as a reference)

---

## Batch 165: Virtual No-Ops and the Channel State Machine

### Why Do Empty Functions Exist?

Five `UMeshInstance` functions compile down to literally a single CPU instruction — `ret N` (return and pop N bytes off the stack). Three bytes of machine code each. They do *nothing*:

| Function | Stack cleanup |
|---|---|
| `ClearChannel(int)` | 4 bytes |
| `SetActor(AActor*)` | 4 bytes |
| `SetAnimFrame(int, float)` | 8 bytes |
| `SetMesh(UMesh*)` | 4 bytes |
| `SetScale(FVector)` | 12 bytes |

These exist because `UMeshInstance` is a *base class*. In C++, when you have an inheritance hierarchy, the base class needs to declare virtual functions even if it has no meaningful implementation. Subclasses like `USkeletalMeshInstance` and `UVertMeshInstance` override all five with real logic. The base versions are "no-ops" — they're the default fallback that says "this mesh type doesn't support this operation." It's the C++ equivalent of a polite shrug.

### ValidateAnimChannel — Growing the Channel Array on Demand

Here's the most interesting piece in this batch. When the game requests animation on channel 47 but the channel array only has 8 slots, what happens? The array needs to grow:

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

The ceiling of 255 prevents unbounded growth — the channel index space is a single byte. Each channel slot is 116 bytes (`0x74`), which holds the sequence name, play rate, current frame, tween state, loop flags, and various internal bookkeeping.

A subtle quirk: the function **always returns 1**, even for out-of-range inputs. Callers treat the return value as "is the channel in a usable state?" not as "was the channel index valid?" This is a minor design oddity — an out-of-range channel isn't usable, but the return value doesn't reflect that. In practice it doesn't matter because callers also bounds-check before using the channel.

### ClearChannel — Resetting a Single Slot

While `StopAnimating` is the nuclear option (reset everything), `ClearChannel(Channel)` surgically resets just one channel:

| Offset in slot | Field | Reset value |
|---|---|---|
| `+0x08` | Sequence name | `NAME_None` |
| `+0x0C` | Play rate | 0.0 |
| `+0x10` | Current frame | 0.0 |
| `+0x18` | Tween amount | 0.0 |
| `+0x38` | Loop flag | 0 |
| `+0x50` | Notifier state | 0 |
| `+0x5C` | (internal) | 0 |
| `+0x60` | (internal) | 0 |

This is used when a single animation finishes and the channel needs to be ready for the next one, without disturbing the other channels that might still be playing.

### ForceAnimRate — The Raw Rate Override

`ForceAnimRate` writes a new playback rate directly into a channel slot without any blend or transition logic:

```cpp
*(FLOAT*)(elem + 0x0C) = Rate;
```

The "Force" prefix distinguishes it from `SetAnimRate` (coming in a later batch), which also handles tween state and rate scaling. `ForceAnimRate` is the "I know what I'm doing, just set it" version.

### Bone Transform Capacity Guards

Three bone transform setters — `SetBoneRotation`, `SetBoneLocation`, and `SetBoneDirection` — share a common pattern: before doing any work, check whether the bone override array is already at capacity (256 entries). If so, return 0 immediately. The actual bone manipulation logic (complex coordinate math) lives in deeper functions that will be covered in future batches.

| Function | Override array offset |
|---|---|
| `SetBoneRotation`, `SetBoneLocation` | `this+0x124` |
| `SetBoneDirection` | `this+0x130` |

The 256-entry cap mirrors the 255-channel limit in `ValidateAnimChannel` — consistent bounds throughout the animation system.

---

## What's Next

The channel state machine still has several missing pieces: `SetAnimRate` (with tween-rate logic), `SetAnimSequence` (the full animation bind), `BlendToAlpha`, and `PlayAnim`. These involve more complex blend-tree state transitions and will form the core of the next batches.
