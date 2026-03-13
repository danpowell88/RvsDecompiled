---
slug: batch-166-169-root-motion-anim-seq-skeleton-update-stamps
title: "50. Root Motion, Anim Sequences, and Skeleton Update Stamps"
authors: [copilot]
date: 2025-02-19
tags: [decompilation, ue2, skeletal-mesh, animation, root-motion, memory]
---

Imagine you're watching a Rainbow Six operator vault through a window. The animation itself — the artist-created sequence of bone poses — doesn't just make the character *look* like they're moving; it actually *drives* the character's position in the world. That's **root motion**: the animation file says "move the character 2 metres forward," and the engine obeys. Without it, the character would vault in place while the game's physics system tried to slide them through separately, and the two would never quite agree.

This post covers four batches of decompilation work that build out the core animation plumbing: how animations get registered, how root motion is armed and consumed each frame, how the engine knows which animation is playing on which channel, and how playback rates get normalised so that "play at 1x speed" means the same thing regardless of how many frames the animator authored.

<!-- truncate -->

## What's an "Animation Object" and Why Register It?

Before diving into the code, it helps to understand the data model. In Unreal Engine 2, animation data lives in `UMeshAnimation` objects — think of them as containers that each hold a collection of named animation sequences ("WalkForward", "ReloadRifle", "CrouchIdle", etc.). A skeletal mesh can have *multiple* animation objects registered to it: one for locomotion, another for weapon-specific animations, another for facial expressions. The engine searches all registered objects when you ask it to play a sequence by name.

## Batch 166: SetSkelAnim, LockRootMotion, CurrentSkelAnim

### `SetSkelAnim` — Registering an Animation Object

Every skeletal mesh instance has an animation objects list at `this+0xAC` (stride `0x18` per slot). Each slot holds a `UMeshAnimation*`, a `USkeletalMesh*`, and an inner `TArray` of channel linkups. `SetSkelAnim` inserts a new animation object into this list — but only if it isn't already there:

```cpp
INT USkeletalMeshInstance::SetSkelAnim(UMeshAnimation* Anim, USkeletalMesh* Mesh)
{
    if (!Anim) return 0;
    FArray* arr = (FArray*)((BYTE*)this + 0xAC);
    INT count = arr->Num();
    for (INT i = 0; i < count; i++) {
        BYTE* slot = (BYTE*)(*(BYTE**)arr) + i * 0x18;
        if (*(UMeshAnimation**)slot == Anim) return 1; // already present
    }
    INT idx = arr->Add(1, 0x18);
    BYTE* slot = (BYTE*)(*(BYTE**)arr) + idx * 0x18;
    *(UMeshAnimation**)slot = Anim;
    *(USkeletalMesh**)(slot + 4) = Mesh;
    // vtbl[0x128/4] — notify subsystems of a new animation object
    (*(void(__thiscall**)(USkeletalMeshInstance*))((*(BYTE**)this) + 0x128))(this);
    return 1;
}
```

The linear scan before insertion prevents double-registration. This is a recurring pattern in gamedev: when your list is small (a character rarely has more than 3–5 animation objects), a simple array with linear search beats a hash table in both memory and cache performance.

### `LockRootMotion` — Pinning the Character Root

Root motion is the technique of letting the animation itself drive the actor's world position rather than the game's movement code. Think of it as saying: "Hey engine, don't move this character with physics — the animation knows where they should go."

`LockRootMotion` prepares the system for this by writing the desired mode, setting an "armed" flag, and clearing any accumulated motion offset:

```cpp
INT USkeletalMeshInstance::LockRootMotion(INT Mode, INT)
{
    *(INT*)((BYTE*)this + 0x1C4) = Mode;   // lock mode enum
    *(INT*)((BYTE*)this + 0x228) = 1;       // armed
    *(INT*)((BYTE*)this + 0x188) = 0;       // clear accumulated offset
    void* Owner = vtbl[0x84/4](this);
    if (!Owner) return 0;
    return 1;
}
```

The three-field setup (mode / armed / cleared) reflects how root motion is consumed each frame: first the flag is armed, then each tick the engine checks whether to extract a position delta from the cached root bone. We'll see the delta extraction functions in Batch 168.

### `CurrentSkelAnim` — Which Animation Is Playing?

Given a channel index, this reconstructs the `UMeshAnimation*` pointer by following a chain of indirection:

1. Read the slot index stored in the channel element at `channel+4`
2. Look up that slot in the animation objects array at `this+0xAC`
3. Fall back to `GetMesh()->DefaultAnim` if the slot is vacant

```cpp
UMeshAnimation* USkeletalMeshInstance::CurrentSkelAnim(INT Channel)
{
    // ... validate channel bounds ...
    INT slotIdx = *(INT*)(channelElem + 4);  // -1 if none
    if (slotIdx >= 0 && slotIdx < animArr->Num()) {
        UMeshAnimation* anim = *(UMeshAnimation**)(animData + slotIdx * 0x18);
        if (anim) return anim;
    }
    return *(UMeshAnimation**)(Mesh + 0x1DC); // DefaultAnim
}
```

The fallback to `DefaultAnim` means that even if a channel hasn't been explicitly assigned an animation object, it can still query the mesh's default animation set — useful during initialization before any gameplay animations have been triggered.

---

## Batch 167: Bones, Sequence Search, and Helper Accessors

### What's a "Reference Bone"?

A skeletal mesh is built around a hierarchy of bones — "Spine", "LeftUpperArm", "RightHand", "Head", etc. These bones are stored as data in three parallel arrays inside the mesh: one for bone names, one for remapped indices, and one for the full bone reference data (parent linkage, default transforms). When the engine needs to find a specific bone by name, it has to search through these arrays.

### `MatchRefBone` — Three-Phase Bone Lookup

This function takes a bone name and returns a slot index. It executes three sequential array searches, each building on the previous result:

| Phase | Array | Offset | Stride | Goal |
|-------|-------|--------|--------|------|
| 1 | `RefBoneNames` | mesh+0x2D0 | 4 | Find the `FName` → get a linear index |
| 2 | `RefBoneIndices` | mesh+0x2DC | 4 | Map that linear index → bone integer ID |
| 3 | `RefBones` | mesh+0x19C | 0x40 | Find the slot whose first DWORD matches the bone ID |

Why three arrays instead of one? UE2 stores skeletal hierarchies with names separated from indices, which are themselves remapped from compact arrays sorted for fast binding during GPU skinning. It's an optimisation for the common case (skinning) at the cost of the uncommon case (name lookup).

### `FindAnimObjectForSequence` — Finding Which Object Has a Named Sequence

When gameplay code says "play the `ReloadRifle` animation," the engine doesn't know *which* animation object contains it — it could be in any of the registered objects. This function iterates all of them until it finds a match:

```cpp
UMeshAnimation* USkeletalMeshInstance::FindAnimObjectForSequence(FName SeqName)
{
    RefreshAnimObjects();  // vtbl[0x128/4] housekeeping
    INT n = arr->Num();
    for (INT i = 0; i < n; i++) {
        UMeshAnimation* anim = *(UMeshAnimation**)(data + i * 0x18);
        if (anim && vtbl[0x64/4](anim, SeqName)) return anim;
    }
    return NULL;
}
```

This is O(n) in the number of animation objects, but n is typically 3–5, so the linear search is perfectly fine.

### Supporting Accessors

Several smaller functions round out this batch:

- **`ClearSkelAnims`** — Empties each inner linkup `TArray` at `slot+0x0C` before clearing the outer array. The specific ordering prevents dangling pointers to inner arrays.
- **`GetBoneName(FName hint)`** — Searches `RefBoneNames` and returns the corresponding entry from `RefBoneIndices` as an `FName`.
- **`GetRootLocation` / `GetRootRotation`** — Simple cache reads from `this+0x1C8` (FVector) and `this+0x1D4` (FRotator), gated on the root motion "armed" flag at `this+0x228`.
- **`ActiveVertStreamSize`** — Reads the active vertex count from `LODMeshes[LODIndex].VertCount` at stride `0x11C`, offset `+0x18` per LOD element.

---

## Batch 168: Root Motion Deltas and Update Stamps

### How Root Motion Actually Moves the Character

In the previous batch, `LockRootMotion` armed the system. Now we see how the engine actually extracts movement from the animation. The idea is simple: each frame, compare the root bone's current position to where it was last frame, and that difference is the "delta" — how far the animation wants the character to move *this tick*.

`GetRootLocationDelta` and `GetRootRotationDelta` both follow the same four-step pattern:

1. Guard on `this+0x228` (armed) and owner existence
2. Refresh the root motion cache for this tick via `vtbl[0x110/4]`
3. Compute delta = current cache – previous cache, then overwrite "previous" with "current"
4. If the auto-relock flag (`this+0x22C`) is set, re-arm root motion for next tick

```cpp
FVector USkeletalMeshInstance::GetRootLocationDelta()
{
    if (!*(INT*)((BYTE*)this + 0x228)) return FVector(0,0,0);
    if (!vtbl[0x84/4](this)) return FVector(0,0,0);
    vtbl[0x110/4](this); // refresh caches
    FLOAT dX = *(FLOAT*)(this+0x1C8) - *(FLOAT*)(this+0x1E0);
    FLOAT dY = *(FLOAT*)(this+0x1CC) - *(FLOAT*)(this+0x1E4);
    FLOAT dZ = *(FLOAT*)(this+0x1D0) - *(FLOAT*)(this+0x1E8);
    // update previous cache
    *(FLOAT*)(this+0x1E0) = *(FLOAT*)(this+0x1C8); // ... etc
    if (*(INT*)(this+0x22C)) LockRootMotion(*(INT*)(this+0x100), 1);
    return FVector(dX, dY, dZ);
}
```

The rotation delta has one interesting quirk: it only propagates the **yaw** component (left/right turning), ignoring pitch and roll. This prevents gimbal-lock artefacts when mixing animation-driven rotation with procedural rotation from the movement system. In a tactical shooter, you generally want the animation to drive turning but the movement code to handle looking up and down.

### `WasSkeletonUpdated` — "Did We Already Compute Bones This Frame?"

This tiny function (64 bytes in the retail binary) answers a performance-critical question: did this mesh instance already have its bone transforms calculated this frame, or does the engine need to do it again?

```cpp
INT USkeletalMeshInstance::WasSkeletonUpdated()
{
    if (((FArray*)((BYTE*)this + 0xB8))->Num() == 0) return 0;
    SQWORD UpdateStamp = *(SQWORD*)((BYTE*)this + 0x64);
    return (UpdateStamp >= GTicks - 1) ? 1 : 0;
}
```

`GTicks` is the engine's global 64-bit tick counter (declared `CORE_API extern SQWORD GTicks` in `Core.h`). The `>= GTicks - 1` window (this tick **or** last tick) prevents false negatives when the mesh-update and query-update ordering flips between frames — a race condition that would otherwise cause bones to "lag" by one frame.

The prerequisite check on the `TArray` at `+0xB8` (the computed bone transform cache) catches the case where the mesh hasn't been skinned at all yet this session, making the timestamp meaningless.

---

## Batch 169: Making "Play at 1x Speed" Work Regardless of Frame Count

### The Problem: Different Animations Have Different Frame Counts

An animator might author a walk cycle with 30 frames at 24 FPS, a reload with 90 frames at 30 FPS, and an idle with 60 frames at 15 FPS. Gameplay code shouldn't need to know any of this — it just wants to say "play at normal speed" or "play at half speed." The rate normalisation system solves this.

### `SetAnimRate` — Rate with Scale

Unlike the simpler `ForceAnimRate` (which writes directly to the rate field), `SetAnimRate` multiplies the incoming rate by a per-channel **scale factor** stored at `elem+0x20`:

```cpp
void USkeletalMeshInstance::SetAnimRate(INT Channel, FLOAT Rate)
{
    // ... bounds check ...
    BYTE* elem = channelData + Channel * 0x74;
    FLOAT Scale = *(FLOAT*)(elem + 0x20);
    *(FLOAT*)(elem + 0x0C) = Rate * Scale;   // scaled playback rate
    *(INT*)(elem + 0x40) = (Rate > 0.0f) ? 1 : 0;  // playing flag
}
```

That scale factor is set by `SetAnimSequence` (see below). It normalises each animation's native frame rate so that `Rate = 1.0` always means "play at the speed the animator intended." `Rate = 0.5` is half speed, `Rate = 2.0` is double speed — regardless of the underlying frame count.

### `SetAnimSequence` — The Full Animation Bind

When a channel is told to play a new animation sequence, six things happen atomically:

1. **Find the animation object** — Which `UMeshAnimation*` contains this sequence name? (`FindAnimObjectForSequence`)
2. **Find its slot index** — Where is that object in our registered list? (`FindAnimObjectSlot`)
3. **Look up the sequence data** — Get the actual sequence object via `GetAnimNamed` (`vtbl[0xB0/4]`)
4. **Write to the channel** — Store the slot index and sequence name into the channel element (`elem+4` and `elem+8`)
5. **Compute the rate scale** — `GetActiveAnimRate(seq) / GetAnimFrameCount(seq)` → stored at `elem+0x20`
6. **Query looping state** — Does this sequence loop? Stored as a bool at `elem+0x34`

Step 5 is the key insight: the engine computes `FPS / FrameCount` once when binding the sequence, so that all subsequent `SetAnimRate` calls can use a simple multiply rather than doing the division every frame.

### `GetAnimRateOnChannel` — Indirected Rate Query

This function validates the channel, retrieves the sequence name from `elem+8`, resolves it back to a sequence object, and returns the authoritative playback rate:

```cpp
FLOAT USkeletalMeshInstance::GetAnimRateOnChannel(INT Channel)
{
    if (!ValidateAnimChannel(this, Channel)) return 0.0f;
    FName SeqName = *(FName*)(channelElem + 8);
    void* SeqObj = vtbl[0xB0/4](this, SeqName);  // GetAnimNamed
    if (!SeqObj) return 0.0f;
    return vtbl[0xC4/4](this, SeqObj);            // GetActiveAnimRate
}
```

The double-indirection (channel → name → object → rate) is deliberate: the channel stores the sequence *name* as its stable key, not a raw pointer that could dangle if the animation object were unloaded. Name-based lookup is slower but safe.

---

## Progress

These four batches implement the core of the `USkeletalMeshInstance` animation channel API. Root motion, frame-rate normalisation, and tick-stamp validation are all correctly reproduced from the retail binary.

Next up: `GetBoneCoords`, `GetTagCoords`, the `GetFrame` megafunction, and a first pass at `UpdateAnimation`.
