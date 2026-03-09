---
slug: weapons-walls-and-doors
title: "12. Weapons, Walls, and Doors — What Makes R6 Tick"
date: 2025-01-12
authors: [rvs-team]
tags: [decompilation, ravenshield, r6weapons, r6engine, weapons, doors, ai, phase-6]
---

The [last post](/blog/the-game-layer) covered the big picture of Phase 6 — why five new DLLs exist, how they link together, and the technical puzzles we solved getting them to build. This post digs into the *content* of those modules. What does it actually look like when you crack open the code that makes Rainbow Six feel like Rainbow Six?

<!-- truncate -->

## The Weapon Pipeline

In most shooters, a weapon is one object. In Ravenshield, a weapon is a *graph* of cooperating objects spread across three DLLs.

The inheritance chain starts broad and gets specific:

```
AActor (Engine.dll)
  └─ AR6EngineWeapon (Engine.dll — header-only)
       └─ AR6AbstractWeapon (R6Abstract.dll)
            └─ AR6Weapons (R6Weapons.dll)
```

`AR6EngineWeapon` is the lightest possible base: just enough to participate in the engine's actor graph. `AR6AbstractWeapon` adds the gadget attachment system — every weapon can host up to five gadgets (scope, bipod, muzzle, magazine, and a general slot). And `AR6Weapons` finally brings the ballistics: clip capacity, rate of fire, muzzle velocity, accuracy modifiers, recoil.

### The Accuracy System

One struct tells you a lot about how the game feels:

```cpp
struct FstAccuracyType
{
    FLOAT fBaseAccuracy;
    FLOAT fShuffleAccuracy;
    FLOAT fWalkingAccuracy;
    FLOAT fWalkingFastAccuracy;
    FLOAT fRunningAccuracy;
    FLOAT fReticuleTime;
    FLOAT fAccuracyChange;
    FLOAT fWeaponJump;
};
```

There's no single "accuracy" number. The game tracks *five* different accuracy values depending on your movement state — standing still, shuffling, walking, walking fast, and running. The reticule on screen is a live visualisation of this: it blooms open when you move and tightens when you stop. `fReticuleTime` controls how fast that transition happens. `fWeaponJump` is the visual kick per shot.

The method `ComputeEffectiveAccuracy()` blends between these values every frame based on the pawn's current velocity. Paired with `GetMovingModifier()`, it gives each weapon a unique feel — a submachine gun snaps back to accuracy quickly, while a light machine gun takes forever to settle.

### Bullets Are Actors

Ravenshield doesn't use hitscan. Every bullet is a physical `AActor` in the world:

```cpp
class AR6Bullet : public AR6AbstractBullet
{
    INT   m_iEnergy;
    INT   m_iPenetrationFactor;
    INT   m_iNoArmorModifier;
    FLOAT m_fKillStunTransfer;
    FLOAT m_fRangeConversionConst;
    FLOAT m_fRange;
    FLOAT m_fExplosionRadius;
    ...
};
```

Energy, penetration factor, and range conversion constant — these drive the game's signature "one shot, one kill" lethality. The `m_iPenetrationFactor` determines whether a bullet punches through a wall to hit someone on the other side. The native function `execBulletGoesThroughSurface` handles the calculation: given a surface, a hit location, and the bullet's velocity, it outputs an exit location and exit normal (or says "no, the bullet stops here").

This is the system that makes wall penetration in Ravenshield feel physical. A 5.56mm round goes through drywall but not concrete. A shotgun slug stops at plywood. It's all driven by data — `m_iPenetrationFactor` versus the surface material's resistance.

---

## Doors: More Complex Than You'd Think

If weapons are the star of the gunplay, doors are the star of the *tactics*. In most games, a door is a trigger volume with an animation. In Ravenshield, doors are first-class game objects with their own physics, networking, and AI integration.

The door system is split across three classes:

| Class | Role |
|-------|------|
| `AR6IORotatingDoor` | The physical door — rotation, lock state, sounds |
| `AR6Door` | A navigation point *pair* (one on each side) for pathfinding |
| `AR6InteractiveObject` | Base class for anything the player can interact with |

`AR6IORotatingDoor` has an impressive amount of state:

```cpp
INT   m_iLockHP;           // Lock health — shoot it enough, it breaks
INT   m_iCurrentLockHP;    // Current lock health
INT   m_iMaxOpeningDeg;    // How far it opens (degrees)
INT   m_iInitialOpeningDeg;// Start position
BITFIELD m_bIsDoorLocked : 1;
BITFIELD m_bIsDoorClosed : 1;
BITFIELD m_bInProcessOfOpening : 1;
BITFIELD m_bInProcessOfClosing : 1;
TArray<AR6AbstractBullet*> m_BreachAttached;  // Breaching charges!
```

The `m_BreachAttached` array is great. It's a list of bullets (breaching charges inherit from `AR6AbstractBullet`) physically attached to this door. When they detonate, the door blows open. The native functions `execAddBreach` and `execRemoveBreach` manage this list.

The door also exports `DoorOpenTowards(FVector)` and `WillOpenOnTouch(AR6Pawn*)` — the AI uses these to figure out which way a door swings and whether it'll open automatically when a pawn walks into it.

### Doors and the AI

This is where it gets really interesting. The AI controller (`AR6AIController`) has a special relationship with doors:

```cpp
INT NeedToOpenDoor(AActor*);      // Is this actor a closed door?
void GotoOpenDoorState(AActor*);  // Transition state machine to "opening door"
DWORD eventCanOpenDoor(AR6IORotatingDoor*);  // Ask script: can I open this?
void eventOpenDoorFailed();       // Script callback: door didn't open
```

When an AI operative is pathfinding and encounters a closed door, the native `NeedToOpenDoor` checks whether the actor in the path is a door that needs opening. If so, `GotoOpenDoorState` transitions the AI's state machine to a special "opening door" behavior. The AI will stack up, breach, or just turn the handle — depending on commands from the planning phase.

The `eventCanOpenDoor` function is a bridge to UnrealScript: it calls `ProcessEvent` to ask the script layer "is this AI allowed to open this specific door?" The script can say no — maybe the mission plan says "wait for go code" or "use breaching charge on this one."

---

## The AI Controller Hierarchy

Speaking of AI, the controller system is one of the biggest parts of `R6Engine.dll`. The hierarchy:

```
AController (Engine.dll)
  └─ AAIController (Engine.dll)
       └─ AR6AIController (R6Engine.dll)
            ├─ AR6RainbowAI    — friendly operative AI
            ├─ AR6TerroristAI  — enemy AI
            └─ AR6HostageAI    — hostage behavior
```

`AR6AIController` alone exports 17 native functions — more than any other class in R6Engine. These are the expensive calculations that needed to run in C++ rather than UnrealScript:

- **Pathfinding:** `execFollowPath`, `execFollowPathTo`, `execMakePathToRun` — path following with awareness of doors, ladders, and cover
- **Positioning:** `execFindPlaceToFire`, `execFindPlaceToTakeCover`, `execFindNearbyWaitSpot` — spatial reasoning about combat positions
- **Detection:** `CanHear()`, `HearingCheck()` — noise-based awareness (feeding from `UR6AbstractNoiseMgr`)
- **Tactical queries:** `execFindGrenadeDirectionToHitActor`, `execActorReachableFromLocation` — "can I throw a grenade at this guy?" and "can I walk there?"

The Rainbow AI (`AR6RainbowAI`) adds sniping checks (`execClearToSnipe`), environment scanning (`execCheckEnvironment`), and entry/guard position calculation. The Terrorist AI (`AR6TerroristAI`) adds backup calling (`execCallBackupForAttack`, `execCallBackupForInvestigation`) and shot validation (`execHaveAClearShot`).

The hostage AI is the simplest: it mostly just follows whoever secured it, with `m_iDistanceCatchUp` and `m_iDistanceToStartToRun` controlling how urgently it tries to keep up.

---

## Deployment Zones

Another R6-specific concept: deployment zones. These define where terrorists and hostages spawn at the start of a mission.

```
AR6DeploymentZone
  ├─ AR6DZoneRectangle   — axis-aligned box
  ├─ AR6DZoneCircle      — circular area
  ├─ AR6DZonePath         — polygon defined by connected path nodes
  └─ AR6DZoneRandomPoints — scatter points within constraints
```

The deployment zone exports 9 native functions just for R6Engine alone — finding random spawn points, checking if a point is inside the zone, ordering terrorist lists by distance. The `UR6TerroristMgr` uses these to populate zones at mission start.

Hostages get special treatment: `m_ArrayHostage[16]` is a fixed array of 16 hostage slots (the maximum hostages per zone), stored as `FSTHostage` structs with spawn position and state.

---

## The Sound System

The voice command system is surprisingly detailed. `UR6RainbowPlayerVoices` has 40+ individual `USound*` members — one for every team command:

```cpp
USound* m_sndTeamOpenAndFrag;
USound* m_sndTeamOpenAndGas;
USound* m_sndTeamOpenAndSmoke;
USound* m_sndTeamOpenAndFlash;
USound* m_sndTeamOpenFragAndClear;
USound* m_sndTeamOpenGasAndClear;
```

Every combination of "open door" + "throw grenade type" + "clear room" has its own dedicated voice line. That's the level of detail that gives Rainbow Six its tactical feel — the operatives don't just say "go"; they say exactly what they're about to do.

---

## What's Next

All five R6 game modules now build. The entire dependency chain from `Core.dll` through `R6Game.dll` compiles and links. What remains before we can boot the game?

- **Phase 7:** The DARE audio system — the hardest phase, since there's no source reference at all
- **Phase 8:** `RavenShield.exe` — the launcher that kicks everything off
- **Phase 9A:** The D3D8 render loop — turning stubs into real GPU calls

We're past the halfway point in terms of modules. Twelve of sixteen binaries build. The next ones are the hardest — but the foundation is solid.
