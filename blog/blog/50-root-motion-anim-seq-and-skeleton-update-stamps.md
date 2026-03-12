---
slug: batch-166-169-root-motion-anim-seq-skeleton-update-stamps
title: "Batches 166–169: Root Motion, Anim Sequences, and Skeleton Update Stamps"
authors: [dan]
tags: [decompilation, ue2, skeletal-mesh, animation, root-motion, memory]
---

Four more batches of `USkeletalMeshInstance` archaeology — from setting up animation objects and locking root motion all the way to querying per-channel rates and computing per-tick skeleton update stamps.

<!-- truncate -->

## Batch 166: SetSkelAnim, LockRootMotion, CurrentSkelAnim

### `SetSkelAnim` — Registering an Animation Object

Every skeletal mesh has an *animation objects* list at `this+0xAC` (stride 0x18).  Each slot holds a `UMeshAnimation*`, a `USkeletalMesh*`, and an inner `TArray` of channel linkups.  `SetSkelAnim` inserts a new object if it isn't already registered:

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

The search-before-insert prevents double-registration without a set container — a pattern that appears throughout the animation system where small arrays are preferred over hash tables.

### `LockRootMotion` — Pinning the Character Root

Root motion is the technique of letting an animation drive the actor's world position rather than the game's movement code.  `LockRootMotion` writes the desired mode, sets an armed flag, clears any accumulated offset, and validates that there's an owner actor to drive:

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

The three-field setup (`mode / armed / cleared`) reflects how root motion is consumed: the client first arms the flag, then each tick checks whether to extract a delta from the cached root position.

### `CurrentSkelAnim` — Which Animation Is Playing?

Given a channel index, this reconstructs the `UMeshAnimation*` pointer by:
1. Reading the slot index stored in `channel+4`
2. Looking that up in the `AnimObjects` array at `this+0xAC`
3. Falling back to `GetMesh()->DefaultAnim` if the slot is vacant

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

---

## Batch 167: RefBone Search, FindAnimObjectForSequence, and Six Accessors

### `MatchRefBone` — Three-Phase Bone Lookup

The most complex function in this batch finds a slot index in the skeletal reference frame given a bone name.  It executes three sequential array searches:

| Phase | Array | Offset | Stride | Goal |
|-------|-------|--------|--------|------|
| 1 | `RefBoneNames` | mesh+0x2D0 | 4 | Find `FName` → linear index |
| 2 | `RefBoneIndices` | mesh+0x2DC | 4 | Map linear index → bone integer ID |
| 3 | `RefBones` | mesh+0x19C | 0x40 | Find slot whose first DWORD == bone ID |

The triple-array design stems from how UE2 stores skeletal hierarchies: names are stored separately from indices, which are themselves remapped from compact arrays that are sorted for binding speed during skinning.

### `FindAnimObjectForSequence` — O(n) Sequence Lookup

Iterates all registered `UMeshAnimation*` objects and calls `FindAnimSeq(SeqName)` (vtbl[0x64/4]) on each.  Returns the first animation that contains the named sequence:

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

### Supporting Accessors

`ClearSkelAnims` empties each inner linkup `TArray` at `slot+0x0C` before emptying the outer AnimObjects array — matching the teardown order the retail engine uses to avoid dangling inner pointers.

`GetBoneName(FName hint)` searches `RefBoneNames` and returns the corresponding entry from `RefBoneIndices` as an opaque `FName` (the integer bone ID packed into FName's internal int field).

`GetRootLocation` / `GetRootRotation` — simple cache reads from `this+0x1C8` (FVector) and `this+0x1D4` (FRotator) only when `this+0x228` (armed) is set and an owner exists.

`ActiveVertStreamSize` — reads the active vertex count from `LODMeshes[LODIndex].VertCount` at the fixed stride `LOD_stride = 0x11C`, offset `+0x18` within each LOD element.

---

## Batch 168: Root Motion Deltas and Update Stamps

### Root Motion Delta Computation

`GetRootLocationDelta` and `GetRootRotationDelta` both follow the same four-step pattern:

1. Guard on `this+0x228` (armed) and owner existence  
2. Call `vtbl[0x110/4]` to refresh the root motion cache for this tick  
3. Compute delta = current cache – previous cache, then update "previous"  
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

`GetRootRotationDelta` uses the same structure but:
- Reads `FRotator` from `this+0x1D4` (current) and `this+0x1EC` (previous)
- Returns `FRotator(0, CurrentYaw - PrevYaw, 0)` — the retail engine only propagates the yaw component to avoid gimbal-lock artefacts when mixing root and procedural rotation

### `WasSkeletonUpdated` — Per-Tick Freshness Check

A 64-byte function that answers "did this instance get its bone transforms calculated this frame?":

```cpp
INT USkeletalMeshInstance::WasSkeletonUpdated()
{
    if (((FArray*)((BYTE*)this + 0xB8))->Num() == 0) return 0;
    SQWORD UpdateStamp = *(SQWORD*)((BYTE*)this + 0x64);
    return (UpdateStamp >= GTicks - 1) ? 1 : 0;
}
```

`GTicks` is the engine's global 64-bit tick counter (declared `CORE_API extern SQWORD GTicks` in `Core.h`).  The `>= GTicks - 1` window (this tick **or** last tick) prevents false negatives when the ordering of mesh update vs. query flips between frames.

The prerequisite `TArray` at `+0xB8` is the computed bone transform cache; an empty array means the mesh hasn't been skinned yet this session, making the stamp comparison meaningless.

---

## Batch 169: Animation Channel Rate and Sequence Locking

### `SetAnimRate` — Rate with Scale

Unlike the simpler `ForceAnimRate` (which writes directly to `elem+0x0C`), `SetAnimRate` multiplies the incoming rate by a per-channel rate scale stored at `elem+0x20`:

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

The `Scale` field at `+0x20` is set by `SetAnimSequence`; it normalises the track's native frame rate to a 1.0 = "natural speed" convention.  `SetAnimRate(ch, 1.0f)` therefore plays at the authored speed regardless of how many frames the sequence contains.

### `SetAnimSequence` — The Full Animation Bind

When a channel is told to play a new sequence, six things must happen atomically:

1. Find which `UMeshAnimation*` object contains the sequence (`FindAnimObjectForSequence`)
2. Find the slot index of that object in `AnimObjects` (`FindAnimObjectSlot` helper)
3. Look up the sequence data object via `vtbl[0xB0/4]` (`GetAnimNamed`)
4. Write slot+sequence into the channel element (`elem+4` and `elem+8`)
5. Compute the rate normalisation scale: `GetActiveAnimRate(seq) / GetAnimFrameCount(seq)` → stored at `elem+0x20`
6. Query looping state (`vtbl[0xC8/4]`) → stored as a bool at `elem+0x34`

The rate normalisation in step 5 is the key insight: the engine stores an *FPS-normalised scale* rather than the raw frame rate, so callers can always pass `Rate = 1.0f` for "play at native speed".

### `GetAnimRateOnChannel` — Indirected Rate Query

This function validates the channel, retrieves the sequence name from `elem+8`, resolves it back to a sequence object via `GetAnimNamed`, then returns the current rate from `GetActiveAnimRate`:

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

The double-indirection (channel → name → object → rate) matches how the retail engine keeps all *rates* in the vtable-dispatched anim system — the channel element stores the canonical *sequence name* as the stable key, not a raw pointer that could dangle.

---

## Progress

These four batches implement the core of the `USkeletalMeshInstance` animation channel API.  As of commit `3aeee8a`, the stub file has dropped from ~480 remaining stubs to roughly 470 — the per-batch additions are small but the *quality* of each implementation is high: root motion, frame-rate normalisation, and tick-stamp validation are all correctly reproduced from disassembly.

Next up: `GetBoneCoords`, `GetTagCoords`, the `GetFrame` megafunction, and a first pass at `UpdateAnimation`.
