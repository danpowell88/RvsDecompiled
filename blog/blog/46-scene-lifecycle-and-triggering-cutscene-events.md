---
slug: 46-scene-lifecycle-and-triggering-cutscene-events
title: "46. Scene Lifecycle and Triggering Cutscene Events"
authors: [danpo]
tags: [decompilation, scene-manager, matinee, cutscene, batch-161]
---

Batch 161 completes the `ASceneManager` lifecycle methods — the start/end
bookends of a cutscene — and fills in the remaining sub-action sub-classes:
`USubActionCameraEffect` and `USubActionTrigger`. Along the way we discovered
how the engine tracks active scenes via a global counter and how the viewport
rendering flag is toggled when a cinematic begins.

<!-- truncate -->

## The Cutscene Lifecycle

Every cutscene is driven by an `ASceneManager` actor. A scene transitions through
a defined lifecycle:

```
SceneStarted() → UpdateViewerFromPct(t) × N → SceneEnded()
```

**`ASceneManager::SceneStarted`** (`0x11fcd0`):
1. Calls `InitializeActions()` — iterates every `UMatAction` in the Actions TArray
   and calls `action->Initialize()` on each.
2. Sets bit 1 (`flag 2`) of `this+0x3C0` (the "playing" bitmask).
3. Fires the `SceneStarted` UnrealScript event via `eventSceneStarted()`.
4. Only if there is an active actor (`this+0x3DC != 0`):
   - Snaps scene-speed (`this+0x3C8`) to `1.0`.
   - Clears the cached current-action pointer `this+0x3D8`.
   - Calls `ChangeOrientation()` with a zero `FOrientation` to establish baseline.
   - Increments the global `GNumActiveScenes` counter.
   - If the actor is a `PlayerController` **and** bit 1 of `this+0x398` is set (has-PC flag),
     finds the PC's `UViewport` at PC+0x5B4 and sets viewport+0x138 to 1 (enable rendering).

**`ASceneManager::SceneEnded`** (`0x11f2d0`):
1. Clears bits 1+2 from `this+0x3C0` (stop playing).
2. Zeros `this+0x448`.
3. Fires the `SceneEnded` UnrealScript event.
4. Empties the `PathSamples` TArray at `this+0x3E4` (FVector elements, 12 bytes each).
5. Decrements `GNumActiveScenes`.
6. If a PlayerController was registered and the has-PC flag is set, finds its viewport
   and clears the rendering flag (viewport+0x138 = 0).

The symmetry is clean: every flag and counter set in `SceneStarted` is undone in `SceneEnded`.

## ChangeOrientation

`ASceneManager::ChangeOrientation(FOrientation orient)` (`0x11e1e0`) is a simple cacher:

```cpp
*(FOrientation*)((BYTE*)this + 0x3FC) = orient;   // latch orientation
INT actor = *(INT*)((BYTE*)this + 0x3DC);
*(DWORD*)((BYTE*)this + 0x424) = *(DWORD*)(actor + 0x240);  // save actor AY
*(DWORD*)((BYTE*)this + 0x428) = *(DWORD*)(actor + 0x244);
*(DWORD*)((BYTE*)this + 0x42C) = *(DWORD*)(actor + 0x248);
```

The three DWORDs from actor+0x240 are the rotation components (AY/AP/AR) of the
active viewer, saved so the scene manager can compute relative rotations later.
Ghidra shows a follow-up call (`FUN_1041db30`) which likely rebuilds a rotation
matrix — this is currently omitted as the function has no known stub yet.

## PreparePath

`ASceneManager::PreparePath()` (`0x11f970`) does spline pre-computation before a
cutscene begins playing. The retail logic:

1. Empties `PathSamples` (this+0x3E4).
2. For each `UMatAction*` in the Actions TArray:
   - Empties the action's own samples TArray at `action+0x84`.
   - Calls `GMatineeTools.GetPrevAction(scene, action)` to find the preceding action
     in the timeline.
   - Calls `GMatineeTools.GetSamples(scene, prevAction, &PathSamples)` to fill the
     global spline sample buffer.
   - Repeats for the action's local buffer at `action+0x84`.
   - If bit 1 of `action+0x30` is set (constant-speed flag) and `action+0x38` != 0:
     computes `action+0x34 = action+0x3C / action+0x38` (time scale for constant speed).
3. In editor mode, calls `SetSceneStartTime()` to recalculate the scene's real time.

`GMatineeTools` is a global `FMatineeTools` instance defined in `Engine.cpp`. It
encapsulates all path-sampling and action iteration utilities used by the Matinee editor.

## VerifyIntPoints

A short guard method (`0x11db90`, 22 bytes):

```cpp
int ASceneManager::VerifyIntPoints() {
    if (*(BYTE*)((BYTE*)this + 0x398) & 4) return 1;  // playing — skip check
    TArray<UMatAction*>& Actions = *(TArray<UMatAction*>*)((BYTE*)this + 0x3A8);
    for (INT i = 0; i < Actions.Num(); i++) {
        if (*(INT*)((BYTE*)Actions(i) + 0x40) == 0) return 0;
        Actions.Num(); // re-fetch
    }
    return 1;
}
```

`action+0x40` is the interpolation handle (cubic spline control point). If any
action is missing one (NULL), the path is not ready to play.

## UpdateViewerFromPct

`ASceneManager::UpdateViewerFromPct(float Pct)` (`0x11f6d0`) is the per-tick
update driver. Our implementation covers the core logic:

1. Clamps Pct to [0.0001, 100.0].
2. Saves the previous action pointer from `this+0x3D8` into `this+0x3D4`.
3. If Pct > 1.0, returns early (outside normal action range).
4. Calls `GetActionFromPct(Pct)` to find the current `UMatAction*`.
5. If the action changed, fires `eventActionStart(activeActor)` on the new action.
6. In editor mode, calls `RefreshSubActions(Pct)` to resync all sub-action states.
7. Iterates the sub-actions TArray at `this+0x3F0`, calling their `Update(Pct, this)`
   virtual via vtable slot 0x64 on any that aren't done (state byte != 3).

The retail version additionally calls `GetLocation`/`GetRotation` to move the
active actor along the spline and rebuilds a rotation matrix from 18 DWORDs of
orientation data — work for a later batch once those paths are more fully
understood.

## USubActionCameraEffect::Update

`USubActionCameraEffect::Update` (`0x86800`) works like a lerp controller for a
`UCameraEffect` object:

- Calls base `UMatSubAction::Update`; bails if not running.
- Gets the scene manager via vtable slot 0x6C.
- Checks the active actor is an `APlayerController`.
- The effect object is stored at `this+0x58` as a pointer.
- Alpha at `effect+0x2C` is either snapped (if duration == 0) or lerped from
  `startAlpha` (this+0x5C) → `endAlpha` (this+0x60) over the sub-action's duration.
- If the resulting alpha <= 0 and we're not ending with a reversed flag:
  calls `eventAddCameraEffect(effect, 1)` to add the effect to the viewport.
- Otherwise calls `eventRemoveCameraEffect(effect)` to remove it.

This is a clean on/off toggle tied to alpha: as the scene progresses,
effects are added or removed from the player's camera pipeline.

## USubActionTrigger::Update

The simplest sub-action at only 74 bytes (`0x11f090`):

```cpp
int USubActionTrigger::Update(float Pct, ASceneManager* SceneMgr) {
    if (!UMatSubAction::Update(Pct, SceneMgr)) return 0;
    ASceneManager* mgr = vtable_slot_27(this);  // GetSceneManager()
    if (!mgr) return 1;
    ((AActor*)SceneMgr)->eventTriggerEvent(
        *(FName*)(this + 0x58),       // trigger name
        *(AActor**)(mgr + 0x3DC),     // other (active actor)
        *(APawn**)(mgr + 0x3E0));     // instigator
    return 0;
}
```

When this sub-action becomes active, it fires a named UnrealScript trigger event
on the scene manager, allowing arbitrary script code to hook into the cutscene timeline.
The trigger name is stored in the sub-action's `FName` field at `this+0x58`.

## New Global: GNumActiveScenes

While writing `SceneStarted`/`SceneEnded`, we found a retail global at `0x1061b80c`
that tracks the count of currently active scenes. We added:

```cpp
// Engine.cpp
ENGINE_API INT GNumActiveScenes = 0;
```

This is incremented in `SceneStarted` and decremented in `SceneEnded`, allowing
other engine subsystems to gate behaviour on whether any cutscene is running.

## Summary

| Method | Retail RVA | Status |
|--------|-----------|--------|
| `ASceneManager::VerifyIntPoints` | 0x11db90 | ✅ Implemented |
| `ASceneManager::ChangeOrientation` | 0x11e1e0 | ✅ Implemented |
| `ASceneManager::SceneEnded` | 0x11f2d0 | ✅ Implemented |
| `ASceneManager::UpdateViewerFromPct` | 0x11f6d0 | ✅ Implemented (partial) |
| `ASceneManager::PreparePath` | 0x11f970 | ✅ Implemented |
| `ASceneManager::SceneStarted` | 0x11fcd0 | ✅ Implemented |
| `USubActionCameraEffect::Update` | 0x86800 | ✅ Implemented |
| `USubActionTrigger::Update` | 0x11f090 | ✅ Implemented |

All 8 functions build cleanly. Engine.dll is 1,033,728 bytes post-Batch 161.
The `ASceneManager` section is now largely complete — the main remaining gap
is the full `UpdateViewerFromPct` `GetLocation`/`GetRotation` branch, which
depends on spline evaluation work scheduled for a later batch.
