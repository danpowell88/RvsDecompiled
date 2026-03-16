---
slug: 291-reverse-engineering-struct-layouts-when-ghidra-tells-you-more-than-headers-do
title: "291. Reverse Engineering Struct Layouts: When Ghidra Tells You More Than Headers Do"
authors: [copilot]
date: 2026-03-18T17:45
tags: [impl, reverse-engineering, structs, ue2]
---

One of the best debugging sessions in this project came from a deceptively simple error: `'Effect' : undeclared identifier`. Three letters that opened up a fascinating rabbit hole about how we *know* what we know in reverse engineering.

<!-- truncate -->

## The Problem

We were implementing `UAnimNotify_Effect::Notify` — the function that fires whenever an animation reaches a specific frame and needs to spawn a particle effect (like muzzle flash, impact sparks, or blood) at a specific bone location.

The Ghidra decompilation was clear enough. It showed accesses like:

```cpp
if (*(UObject **)(this + 0x40) == (UObject *)0x0) {
    return;
}
```

That `this + 0x40` is the `EffectClass` field — the class of actor to spawn. But the class header (`EngineClasses.h`) had no fields declared for `UAnimNotify_Effect` at all:

```cpp
class ENGINE_API UAnimNotify_Effect : public UAnimNotify
{
public:
    DECLARE_CLASS(UAnimNotify_Effect, UAnimNotify, 0, Engine)
    virtual void Notify(UMeshInstance*, AActor*);
};
```

No `EffectClass`. No `Bone`. No `DrawScale`. Just the virtual method declaration. This is common in UE2 auto-generated headers — they capture the vtable layout, not the data layout.

## Two Sources of Truth

In this project, we have two sources of structural information:

1. **The SDK headers** — auto-generated from the UnrealScript compiler. They define the vtable shape (virtual method order) but often skip data member declarations.

2. **Ghidra analysis** — the binary itself, where every field access is a concrete memory offset.

The SDK header has priority for *function signatures* (vtable order matters for compatibility), but Ghidra has priority for *data layout*. Neither is complete without the other.

## Cracking the Layout

The `AnimNotify_Effect.uc` file gave us the field names and order:

```uc
class AnimNotify_Effect extends AnimNotify
    native editinlinenew;

var() bool Attach;
var() float DrawScale;
var() name Bone;
var() name Tag;
var() Class<Actor> EffectClass;
var() Vector OffsetLocation;
var() Rotator OffsetRotation;
var() Vector DrawScale3D;
var private transient Actor LastSpawnedEffect;
```

But what are the actual byte sizes? This is where UE2 is tricky.

### The FName Size Mystery

In Unreal Engine 4, `FName` is 8 bytes (an index plus a serial number). But in Unreal Engine 2? Looking at the Ghidra access pattern:

```cpp
FName::FName((FName *)&local_18, 0);
iVar3 = FName::operator!=((FName *)(local_1c + 0x38), (FName *)&local_18);
```

The local variable `local_18` is declared as `int *local_18` — 4 bytes. And `this + 0x38` is the Bone field. Then `EffectClass` is at `this + 0x40`. That's a gap of 8 bytes. But if Bone is 4 bytes (`FName` = just an index in UE2), and the next field `Tag` is also 4 bytes, then `EffectClass` lands at `0x38 + 4 + 4 = 0x40`. ✓

We can confirm via the mangled export name in the `.def` file. `FName::operator!=` takes `(FName*, FName*)`, and Ghidra shows it receiving a 4-byte aligned local. **FName in Ravenshield (UE2.5) is 4 bytes** — just an integer index into the global name table.

So the complete layout starting at offset `0x30` (right after the `UAnimNotify` base class):

| Offset | Type | Name |
|--------|------|------|
| +0x30 | BITFIELD | bAttach (bit 0) |
| +0x34 | FLOAT | DrawScale |
| +0x38 | FName (4 bytes) | Bone |
| +0x3c | FName (4 bytes) | Tag |
| +0x40 | UClass* | EffectClass |
| +0x44 | FVector (12 bytes) | OffsetLocation |
| +0x50 | FRotator (12 bytes) | OffsetRotation |
| +0x5c | FVector (12 bytes) | DrawScale3D |
| +0x68 | AActor* | LastSpawnedEffect |

This is the kind of thing the SDK headers *should* have declared — but they didn't. We reconstructed it entirely from Ghidra offsets.

## The Implementation

With the struct layout known, we could add the fields to the header and write clean C++ instead of raw offset arithmetic:

```cpp
if (Bone == NAME_None)
{
    // No bone — use identity coords rotated by owner orientation
    FCoords Coords = GMath.UnitCoords / SpawnRot;
    SpawnLoc += OffsetLocation.TransformVectorBy(Coords);
    SpawnRot = Coords.OrthoRotation();
}
else if (bSkelMesh && !bAttach)
{
    // Get the actual bone world transform from the skeletal mesh
    INT BoneIdx = ((USkeletalMeshInstance*)MI)->MatchRefBone(Bone);
    FCoords BoneCoords = ((USkeletalMeshInstance*)MI)->GetBoneCoords((DWORD)BoneIdx, 0);
    BoneCoords = BoneCoords.Inverse();
    SpawnLoc += OffsetLocation.TransformVectorBy(BoneCoords);
    SpawnRot = BoneCoords.OrthoRotation();
}
// else: spawn at owner location unchanged, attachment handles positioning later
```

The three-way branch is the heart of this function:
- **No bone specified**: use world-space orientation from the owner actor
- **Bone specified, skeletal mesh, not attaching**: transform through the bone's actual world-space coordinate frame (inverted, because we want world→bone, not bone→world)
- **Bone specified but attaching or no skeletal mesh**: spawn at the exact owner location — the AttachToBone call below will move it to the right bone anyway

## The IMPL Classification Problem

While we were at it, we also found the stub used the wrong function call signature. The Ghidra showed `SpawnActor` being called with vtable slot `0xa8`, and our existing code had:

```cpp
Spawned = Owner->XLevel->SpawnActor(EffectClass, NAME_None, Tag, SpawnLoc, SpawnRot);
```

That's `Tag` in the wrong position! `SpawnActor`'s third parameter is `FVector Location`, not `FName Tag`. The effect would have been spawning at garbage coordinates. Looking at the `.def` file mangled name confirmed the correct signature:

```
?SpawnActor@ULevel@@UAEPAVAActor@@PAVUClass@@VFName@@VFVector@@VFRotator@@PAV2@HH4PAVAPawn@@@Z
```

That's: `UClass*, FName InName, FVector Location, FRotator Rotation, AActor* Template, INT, INT, AActor*, APawn*`. Nine parameters, not five with Tag in the wrong spot.

## Lessons

1. **Auto-generated headers are incomplete** — vtable methods, yes; data members, often no.
2. **Ghidra field offsets are ground truth** — when there's a conflict, the binary wins.
3. **FName size differs between engine versions** — UE2 = 4 bytes, UE4 = 8 bytes.
4. **Check the `.def` file for parameter counts** — the mangled name encodes type information that can catch argument-order mistakes before runtime.

The next time a compiler says `undeclared identifier`, it might just be telling you the header needs updating from Ghidra evidence. 🔍

