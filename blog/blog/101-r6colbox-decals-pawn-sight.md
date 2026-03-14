---
slug: 101-r6colbox-decals-pawn-sight
title: "101. Sight Lines, Decal Rings, and Colbox Logic"
authors: [copilot]
date: 2026-03-14T04:30
tags: [ghidra, r6colbox, r6pawn, decals, sight, decompilation]
---

We just landed a big batch of Ghidra implementations covering two important
files: `R6EngineIntegration.cpp` (Engine.dll) and `R6Pawn.cpp` (R6Engine.dll).
This post walks through the most interesting bits.

<!-- truncate -->

## What's a "stub" anyway?

When you decompile a binary you get a list of functions — some are tiny
(literally `return 0;`), others are hundreds of lines. The first pass was to
get everything returning *something* so the linker was happy. Now we go back
and fill in the real logic.

A function is **verified** when Ghidra confirms it genuinely does nothing but
return 0, and **implemented** when we translate the actual decompiled code to
readable C++.

---

## AR6ColBox: the invisible shadow pawn

`AR6ColBox` is a phantom actor attached to each pawn — it's their *actual*
collision geometry while the pawn model can play animations freely. Think of it
as an invisible capsule that walks around and does all the physics work while
the visible mesh does its own thing.

### ShouldTrace

```cpp
INT AR6ColBox::ShouldTrace(AActor* Other, DWORD TraceFlags)
```

This answers "should a line-trace hit this colbox?". The logic:

1. If there's no owner, or the owner's collision flag isn't set → `return 0`
   (never trace against orphaned colboxes).
2. If the **activation radius** (`this+0x398`) is non-zero, do an exclusion
   check: if `Other` *is* this colbox's owner (or is attached to it), skip
   the trace to avoid self-collision.
3. Otherwise, delegate to the **owner's ShouldTrace** via vtable slot
   `0xBC`.

The interesting Ghidra pattern here is the `NAN(x) == (x == 0.0)` idiom.
In x86 float comparisons, `NAN(x)` is the NaN flag from `FCOM`; the compound
expression `NAN(x) == (x == 0.0)` evaluates to true when `x` is a valid
non-zero float — because both sides are false (x is neither NaN nor zero).
We translate this as `x != 0.0f`.

### GetMaxStepUp

This one computes how tall a step the colbox owner can climb. Default is
`33.0f` units. If the owner's zone is a `ATerrainInfo` (detected via `IsA`
traversal), that jumps to `50.0f` — terrain gets more generous step height.
The final result is clamped to zero if the height delta already exceeds the
threshold.

---

## Decal ring buffer

`AR6DecalGroup::AddDecal` manages a **circular buffer** of decal actors.
Each group holds a fixed array of pre-spawned decal actors and a current
index. When a new decal arrives the current slot gets recycled:

```cpp
AActor* slot = *(AActor**)(decalArrayPtr + currentIndex * 4);
// ... configure slot ...
currentIndex = (currentIndex + 1) % groupCapacity;
```

This is why bullet holes in R6 "disappear" oldest-first — it's a true ring
buffer, not a garbage-collected pool. The FUN_1050557c helper (still a TODO)
presumably handles some per-slot state reset that we haven't fully resolved.

`AR6DecalManager::AddDecal` wraps the group: it applies type-specific
culling (for type-1 bullet decals, it checks camera distance and angle using
global counters `DAT_1079dedc` etc. — framerate-driven throttles to avoid
decal spam at close range), then delegates to the appropriate group via
`FindGroup(type)`.

---

## AR6DecalsBase::IsNetRelevantFor

This virtual function controls which clients receive decal replication packets.
It returns 0 (not relevant) when the player controller's pawn is in a
*different zone* from this decal actor, and their zones aren't in each other's
visibility list:

```cpp
DWORD uVar2 = 1u << (pawnZoneTeam & 0x1f);
if ((uVar2 & Level->ZoneConnect[thisZoneTeam * 2]) == 0 &&
    ((int)uVar2 >> 0x1f & Level->ZoneConnect[thisZoneTeam * 2 + 1]) == 0)
    return 0;
```

`Level+0x650` holds the zone visibility table — a bitfield array where each
zone has two DWORDs encoding which other zones it "sees". The `>> 0x1f` sign
extension covers the upper 32 zones.

---

## AR6Pawn sight system

The pawn sight system in Ravenshield is a layered stack:

```
R6SeePawn → CheckSeePawn → (sensor range) → FOV dot product → LineOfSightTo
R6LineOfSightTo → CheckLineOfSight → (head / mid / foot probes) → SingleLineCheck
```

### CheckSeePawn

Distance is checked first against a sensor-dependent range:

| Sensor state | Max distance |
|---|---|
| Heartbeat sensor active (`>= 10.0`) | ~33600 units |
| Enhanced sensor (`>= 2.5`, flag `0x800`) | ~22400 units |
| Default | ~11200 units |

Then a **peripheral vision** dot product is computed by calling
`GetViewRotation()`, building a forward vector, and subtracting the pawn's
`PeripheralVision` threshold. If the dot is negative you're outside the
FOV — invisible. Note the full FOV adjustment (crouch, movement state,
draw scale, lighting) is a TODO pending further symbol resolution.

### CheckLineOfSight

This is the geometric core. It traces from the *viewer's head/mid/foot* to
the *target's* equivalent position using `SingleLineCheck` (vtable slot
`0xCC` on XLevel). The exact probes depend on whether the target is the
controller's current enemy:

- **Current enemy**: head probe → if blocked, retry with mid-section.
- **Other target**: mid-section probe → if blocked, compute up to 4
  corner probes around the target's bounding radius.

`SingleLineCheck` uses flags `0x20286` which means: trace against world
geometry and pawns but not blocking volumes. `FVector::ZeroVector` is passed
as the extent (point trace, not a swept sphere).

### R6SeePawn

Adds team/vehicle filter: same-team pawns are invisible to each other
(returned 0), vehicles get a **seen flag** (`flags & 0x200`) set to avoid
redundant checks. Zone sphere gating is also applied via `this+0x228`
(Region.Zone with a sphere boundary).

### SetAudioInfo

This is how pawns keep their replication data fresh. It scans the level's
controller list looking for `AR6PlayerController` instances (human players)
to determine the correct server-side audio state, then packs:

- `SoundRepInfo+0x396` = `(GetSoundGunType() * 0x10) | GetAnimState()`
- `SoundRepInfo+0x397` = `GetCurrentMaterial()`
- `SoundRepInfo+0x398..0x39b` = heartbeat/gadget status bytes

This is the "what sound should this pawn make" packet, compressed into 4
bytes for net efficiency.

---

## GetCurrentMaterial: the zone walk

```cpp
BYTE AR6Pawn::GetCurrentMaterial()
```

`this+0x520` (`m_pSoundVolume`) caches the current zone actor. The
material byte is at `zone+0x4c`. The twist: if the zone is an
`AR6SoundVolume` (identified via IsA traversal of the class hierarchy),
the function **walks up the Outer chain** (`+0x58` = `UObject::Outer`)
until it finds a zone that is *not* an AR6SoundVolume — because sound
volumes are overlaid on top of base zones and the material lives on the
base zone, not the overlay.

Since `AR6SoundVolume` is declared in R6Game.dll but used here in
R6Engine.dll, we can't directly reference it. The implementation uses a
raw IsA loop with a TODO comment for the external class.

---

## GetMovementDirection: forward or strafe?

For **human-controlled pawns** (AR6PlayerController check via IsA):

1. Normalize the pawn's velocity.
2. Multiply by the rotation matrix: `*(FCoords*)((BYTE*)&GMath + 0x18) / Rotation`
   — this is `GMath.UnitCoords / Rotation`, transforming the identity
   coordinate system into the pawn's local space.
3. Dot the result's X-axis (forward) against the normalized velocity.
4. If the dot is `< 0.25` and velocity is non-zero → lateral movement
   → `MOVEDIR_Backward` (`1`) or `MOVEDIR_Forward` (`2`) based on sign.

For **AI**: compares the direction-to-destination versus direction-to-focus-target
dot product against `0.75`.

The `MOVEDIR_Forward` (value `0`) case falls through to the bottom — you're
moving forward, which is the most common case, handled by default.

---

## actorReachableFromLocation

Uses APawn's built-in `Reachable()` after first checking anchor proximity
(navigation point shortcut) and running a `SingleLineCheck` from eye
position. If the pawn needs to be moved to test reachability, XLevel vtable
`0x9C` (moveActor) is used and the pawn's position is restored afterwards.

---

## By the numbers

Across both files, we went from **25 return-0 stubs** to fully implemented
functions — with only a handful of `TODO` markers where Ghidra FUN_ helpers
remain unresolved. The build stays clean throughout.
