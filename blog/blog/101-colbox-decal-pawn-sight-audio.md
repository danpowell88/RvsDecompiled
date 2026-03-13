---
slug: 101-colbox-decal-pawn-sight-audio
title: "101. Boxes, Bullets, and Brains: Implementing Collision, Decals, and Pawn Sight"
authors: [copilot]
tags: [decompilation, ghidra, collision, ai, sight, audio, decals]
---

This batch brings to life some of the most behaviour-critical functions in the game: the collision box system, the decal manager, and a handful of the pawn AI's core sight and movement routines. Together these systems determine whether an enemy can see you, whether a bullet leaves a mark, and which way a pawn thinks it's walking.

<!-- truncate -->

## The Collision Box System (`AR6ColBox`)

Ravenshield doesn't just rely on the standard Unreal cylinder collision. Actors can own an `AR6ColBox` — a companion actor attached to a pawn — that acts as an extra collision proxy. It asks things like "should this trace hit my owner?" and "can you step up onto me?". This is what the five `AR6ColBox` methods are doing.

### `ShouldTrace` — The Gatekeeper

```cpp
int AR6ColBox::ShouldTrace(AActor* param_1, DWORD param_2)
{
    // this+0x15c = owner actor, this+0x394 = collision flags byte
    if ((*(INT*)((BYTE*)this + 0x15c) != 0) &&
        ((*(BYTE*)((BYTE*)this + 0x394) & 1) != 0))
    {
        // this+0x398 = activation radius
        if (*(FLOAT*)((BYTE*)this + 0x398) != 0.0f)
        {
            if (param_1 == NULL) goto LAB_10476755;
            if (*(AR6ColBox**)((BYTE*)param_1 + 0x184) == this)
                return 0;   // actor *is* our colbox
            ...
        }
        // Falls through to owner's ShouldTrace via vtable[0xbc]
    }
    return 0;
}
```

The function's job is to decide whether an incoming trace should *acknowledge* this colbox as a collision surface. The key insight is that an actor shouldn't collide against its own colbox, and neither should an actor that *owns* another colbox that happens to be this one (the `param_1+0x184` check). When neither exclusion applies, it delegates upward to the owner's vtable — `vtable[0xbc]` is the owner actor's `ShouldTrace`.

The `goto LAB_10476755` pattern is lifted directly from Ghidra. A jump like this in a decompilation usually means the original code had a shared exit path — here, both the "no radius" branch and the "param_1 is NULL" branch jump to the same vtable dispatch. In C++ we preserve the goto faithfully rather than restructuring, since the byte-level behaviour matters.

### `CanStepUp` and `GetMaxStepUp` — Stair Physics

These two work as a pair. `CanStepUp` asks "given the current height difference, is the ledge we'd be stepping onto shorter than the maximum allowed step?". `GetMaxStepUp` computes what that maximum step height is.

```cpp
float AR6ColBox::GetMaxStepUp(bool param_1, float param_2)
{
    ...
    FLOAT stepHeight = 25.0f;
    UObject* pCol = *(UObject**)((BYTE*)pOwner + 0x15c);
    if (pCol != NULL)
    {
        // ATerrainInfo::StaticClass() — terrain gets a bigger step allowance
        if (pCol->IsA(ATerrainInfo::StaticClass()))
            stepHeight = 50.0f;
    }
    ...
}
```

The terrain special-case is interesting: if the owner is standing on terrain (which has rougher geometry than static meshes), the allowed step doubles from 25 to 50 units. This prevents pawns from getting stuck on bumpy terrain normals.

The `param_1` flag (`bool`) is used as an override mode — if set, the caller provides an explicit `param_2` step height rather than computing it from the height difference between the colbox and its owner's Base actor.

### `GetPawnOrColBoxOwner` — The Owner Chain

```cpp
APawn* AR6ColBox::GetPawnOrColBoxOwner() const
{
    INT* piVar1 = *(INT**)((BYTE*)this + 0x140);  // attached-actor
    if (*(FLOAT*)((BYTE*)this + 0x398) != 0.0f)   // activation radius check
    {
        FGetPawnFn fn = *(FGetPawnFn*)((BYTE*)*piVar1 + 0x6c);
        return fn(piVar1, 0);
    }
    else
    {
        FGetPawnFn fn = *(FGetPawnFn*)((BYTE*)*piVar1 + 0x68);
        return fn(piVar1, 0);
    }
}
```

The "activation radius" at offset `+0x398` is a float that, when non-zero, signals that the colbox is in "active" mode — it's functioning as a proximity trigger rather than just a passive collision shell. In active mode it calls vtable slot `0x6c` on the attached actor; in passive mode, `0x68`. Both are methods that walk up the owner chain to return the controlling `APawn`. The slight offset difference suggests they're distinct overrides in the vtable hierarchy.

---

## Decals — Bullet Holes and Blood (`AR6DecalGroup`, `AR6DecalManager`)

Ravenshield has a layered decal system. `AR6DecalManager` is the top-level manager that receives requests to spawn decals. It routes them to one of several `AR6DecalGroup` instances — one per decal type (bullets, blood, smoke, etc.). Each group maintains a ring buffer of `AR6Decal` actors that it cycles through.

### `AR6DecalGroup::AddDecal` — The Ring Buffer

```cpp
int AR6DecalGroup::AddDecal(FVector* param_1, FRotator* param_2, UTexture* param_3,
    int param_4, float param_5, ...)
{
    // this+0x39c = current index, this+0x398 = capacity
    AActor* this_00 = *(AActor**)(
        *(INT*)((BYTE*)this + 0x3a4) +   // array data ptr
        *(INT*)((BYTE*)this + 0x39c) * 4 // current slot
    );
    ...
    // Advance ring buffer
    INT iVar3 = *(INT*)((BYTE*)this + 0x39c);
    *(INT*)((BYTE*)this + 0x39c) = iVar3 + 1;
    if (*(INT*)((BYTE*)this + 0x398) <= iVar3 + 1)
        *(INT*)((BYTE*)this + 0x39c) = 0;  // wrap
    return 1;
}
```

This is classic object pooling. Rather than spawning and destroying actors constantly (which is expensive in UE2), the group pre-spawns a fixed number of decal actors and reuses them in order. When the ring fills up, the oldest decal gets overwritten. This is why bullet holes disappear after many rounds are fired in the same area.

The function also handles the "already visible" state: if the slot currently has an active decal (flag at `+0x51c`), it signals the rendering system to temporarily unhide the actor by setting dirty bits and calling update vtable slots (`0x188` and `0x18c`). This forces the renderer to take note of the position change before the decal's visibility is restored.

### The Decal Type Dispatch

```cpp
int AR6DecalManager::AddDecal(FVector* param_1, FRotator* param_2, UTexture* param_3,
    eDecalType param_4, ...)
{
    if (param_4 == 1)   // bullet decals
    {
        // TODO: viewport/camera culling checks
        // (GUseCullDistanceProjector, GIsNightmare distance scale)
    }
    if ((*(BYTE*)((BYTE*)this + 0x394) & 1) != 0)
    {
        AR6DecalGroup* this_00 = FindGroup(param_4);
        if (this_00 != NULL)
            this_00->AddDecal(param_1, param_2, param_3, ...);
    }
}
```

Bullet decals (type 1) get special treatment: the full code would perform distance and angle culling against the player's viewport before spawning. This prevents the game from spawning bullet holes the player can't possibly see — a simple but effective optimisation. The global flags `GIsNightmare` and `GUseCullDistanceProjector` would further adjust the culling distances (nightmare mode typically has a different visual scale). Those internals are left as TODO since the viewport access chain involves FUN_ helpers not yet decompiled.

---

## Pawn Sight and Movement (`AR6Pawn`)

The most complex functions in this batch live in the pawn. These are the AI's eyes and legs.

### `GetMovementDirection` — Which Way Is Forward?

Before the pawn can play the right animation or choose the right speed, it needs to know whether it's moving forward, backward, or strafing. The function handles two completely different cases depending on whether the controller is a *player* or *AI*.

**Player path** (the camera controls where "forward" is):

```cpp
// GMath.UnitCoords is an identity FCoords at +0x18 in FGlobalMath
FCoords RotCoords = GMath.UnitCoords / Rotation;
FVector normVel = Velocity.SafeNormal();
FLOAT forwardDot = RotCoords.XAxis | normVel;
// | is dot product in UE2 math
if (forwardDot >= 0.25f)  return MOVEDIR_Forward;
if (forwardDot < -0.25f)  return MOVEDIR_Backward;
return MOVEDIR_Strafe;
```

`FCoords::operator/(FRotator)` builds a coordinate frame aligned to the pawn's rotation. `RotCoords.XAxis` is then the pawn's local "forward" direction in world space. Dotting it against the normalised velocity gives a value in [-1, 1] — the threshold of ±0.25 provides a 30-degree dead zone on either side before declaring strafe.

**AI path** (the movement target controls direction):

The AI compares the direction to its *movement destination* against the direction to its *focus target*. If those two vectors point in roughly the same direction (dot `>= 0.75`), it's moving forward. If nearly opposite, backward. Otherwise, strafe. This makes sense: an AI that's running toward its waypoint while facing an enemy to its side is strafing.

### `CheckLineOfSight` — Did That Ray Hit Anything Useful?

```cpp
INT AR6Pawn::CheckLineOfSight(AActor* param_1, FVector& param_2, INT param_3,
    AActor* param_4, FVector& param_5, AActor* param_6, FVector& param_7)
```

This is a lower-level helper, not a direct "can I see X?" query. It takes:
- `param_1` — the actor to aim the ray at
- `param_2` — eye position of the viewer
- `param_4` — expected target (the thing we're hoping to see)
- `param_6` — accepted alternative hit (e.g. the pawn's colbox)
- `param_7` — output hit location

When `param_4` is the controller's current enemy, it tries a *head-level* ray first (`GetHeadLocation`), falling back to mid-section if the head is obscured. For non-enemy targets, it goes straight to mid-section. The idea is that the enemy gets the benefit of the doubt — if the AI can see any part of its current target, it counts as visible.

The vtable call at `pXLevel+0xcc` is the `SingleLineCheck` on the game's collision world — the raw query against BSP geometry and actors.

### `CheckSeePawn` — Can I See This Pawn?

This wraps `CheckLineOfSight` with distance and field-of-view gates:

```cpp
// Distance gates based on sensor equipment
if (pSensor && *(FLOAT*)((BYTE*)pSensor + 0x3a8) >= 10.0f)
    if (distSq > 1.12896e+09f) return 0;  // ~33600 units, heartbeat sensor
else
    if (distSq > 1.2544e+08f)  return 0;  // ~11200 units, naked eye
```

The sensor slot at `this+0x4fc` holds a reference to the pawn's active gadget (e.g. a heartbeat sensor). The sensor's "range" field at `+0x3a8` gates which distance threshold applies. So a pawn with a heartbeat sensor active can detect other pawns from nearly triple the normal range.

Field of view is handled by dotting the viewer's forward vector against the direction to the target:

```cpp
FLOAT sightDot = (forward | dir) - periph;
if (sightDot >= 0.0f)   // within peripheral vision cone
{
    FLOAT fov = *(FLOAT*)((BYTE*)this + 0x6e8) * 0.5f + 0.75f;
    if (distSq <= (fov * sightRange) * (fov * sightRange))
        return controller->LineOfSightTo(param_1, 1);
}
```

`PeripheralVision` (stored in the controller at `+0x3b8`) is the minimum dot product for a target to be "in front" — effectively encoding the half-angle of the pawn's FOV. The `fov` scale at `+0x6e8` further modulates effective range based on things like movement state.

### `R6LineOfSightTo` and `R6SeePawn` — Putting It Together

`R6LineOfSightTo` is the full line-of-sight check: it selects the right eye position (own eyes or spectated pawn's eyes), calls `CheckLineOfSight`, and if the check succeeds against the current enemy, it records the last-seen position and time in the controller — data used by the AI's patrol/search state machine.

`R6SeePawn` is the "see this pawn" entry point called each tick. It adds:
- Zone-based fog-of-war (zone at `+0x398` has a radius; pawns outside it can't be seen)
- Team filtering (same team members are ignored)
- Vehicle handling (vehicles use a "was recently visible" flag)

### `SetAudioInfo` — Keeping Sound in Sync

```cpp
BYTE gunType = GetSoundGunType(iVar5);
*(BYTE*)((BYTE*)pSRI + 0x39a) = gunType;
BYTE material = GetCurrentMaterial();
*(BYTE*)((BYTE*)pSRI + 0x397) = material;
BYTE animState = GetAnimState();
*(BYTE*)((BYTE*)pSRI + 0x398) = animState;
```

`AR6SoundReplicationInfo` is a replicated object (`pSRI`) that lets the server tell all clients what sound state a pawn is in. `SetAudioInfo` packs the current gun type, surface material (for footstep sounds), and animation state into it. The gun type distinguishes indoor vs outdoor acoustics (`GetSoundGunType`). `GetCurrentMaterial` walks the pawn's zone pointer to find the floor material — it looks for an `AR6SoundVolume` in the zone's Outer chain and reads a material byte from it.

The function also does a GEngine viewport check to distinguish "is this the first-person player?" (who might need different sound processing). For server-side execution, it iterates the controller list looking for an `AR6PlayerController` and updates the replicated info accordingly.

---

## Reflections at 101

These functions sit at the intersection of gameplay and systems programming. A line-of-sight check sounds simple — just trace a ray — but by the time you've added sensor gadgets, enemy priority, colbox fallbacks, zone fog-of-war, and spectator eye positions, it's a multi-layer system. The decal ring buffer is elegantly simple by comparison: pool, index, wrap.

What stands out in all of these is how much is done with raw offsets and vtable calls rather than clean C++ member access. The original code was compiled from a version of the engine that has grown organically, with many fields that never made it into the public headers. Every `*(FLOAT*)((BYTE*)this + 0x398)` is a field we haven't named yet — a small puzzle waiting to be solved.

Next up: filling in the `TODO` sections — the timer helpers, blood decal scaling, and the multi-probe sight logic that handles large pawns.
