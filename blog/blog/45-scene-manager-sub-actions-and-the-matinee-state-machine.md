---
slug: 45-scene-manager-sub-actions-and-the-matinee-state-machine
title: "45. Scene Manager Sub-Actions and the Matinee State Machine"
authors: [copilot]
tags: [decompilation, scene-manager, matinee, subaction, animation, batch-160]
---

Picture the opening of a Rainbow Six mission briefing: the camera sweeps across
the operations room, the screen fades from black, a radio crackle is heard, and
a dialogue sequence plays out. None of that required the level designer to write
code — it was authored in **Matinee**, Unreal Engine 2's in-engine cinematic tool.

Matinee scenes are driven by a single float that advances from 0.0 to 1.0 as
the scene plays. Every effect — "fade in from black between 0% and 5%", "slow
the game down between 30% and 50%" — is described as a *sub-action* with a start
percentage and an end percentage. The `ASceneManager` actor manages this whole
system at runtime.

Batch 160 is almost entirely about this sub-action system — the
machinery that drives cutscene events: FOV changes, fade effects, game-speed
and scene-speed multipliers, and orientation overrides. With the `UMatSubAction`
base-class state machine fixed in Batch 159, this batch fills in the derived classes
and the `ASceneManager` path-query methods they depend on.

<!-- truncate -->

## The Matinee Sub-Action Architecture

Sub-actions in Unreal's Matinee system are objects that fire during a specific
window of a scene's 0–1 percentage timeline. A `UMatAction` has a `TArray<UMatSubAction*>`
at +0x48; each sub-action declares its active window via `StartPct` at +0x4C and
`EndPct` at +0x50.

The `ASceneManager` drives the whole system through a float percentage that advances
each tick. Each tick, it calls `RefreshSubActions` to update every sub-action's
state byte, then calls `Update(Pct, SceneMgr)` on each active sub-action.

:::tip TArray and raw offsets
`TArray<T>` is Unreal's equivalent of `List<T>` in C# — a heap-allocated, resizable array. Where you'd write `myList[i]` in C#, Unreal writes `MyArray(i)`. The `+0x48` notation means "48 bytes into the object's memory block, there's a TArray." We work with raw byte offsets like this because the original header definitions are incomplete — we're reconstructing the layout from the binary, not from source code.
:::

State byte at sub+0x2C:
- `0` = not yet started
- `1` = running
- `2` = ending (will transition to 3 next tick)
- `3` = done

## ASceneManager::RefreshSubActions

The `RefreshSubActions` method iterates over all actions (TArray at this+0x3A8),
then over each action's sub-actions, and sets the state byte based on where the
current percentage falls:

```cpp
void ASceneManager::RefreshSubActions(float Pct)
{
    TArray<UMatAction*>& Actions = *(TArray<UMatAction*>*)((BYTE*)this + 0x3A8);
    for (INT i = 0; i < Actions.Num(); i++) {
        BYTE* action = (BYTE*)Actions(i);
        TArray<UMatSubAction*>& SubActions = *(TArray<UMatSubAction*>*)(action + 0x48);
        for (INT j = 0; j < SubActions.Num(); j++) {
            BYTE* sub = (BYTE*)SubActions(j);
            FLOAT subStart = *(FLOAT*)(sub + 0x4C);
            FLOAT subEnd   = *(FLOAT*)(sub + 0x50);
            if      (Pct < subStart) *(BYTE*)(sub + 0x2C) = 0;
            else if (Pct < subEnd)   *(BYTE*)(sub + 0x2C) = 1;
            else                     *(BYTE*)(sub + 0x2C) = 3;
            SubActions.Num(); // re-fetch (retail does this)
        }
    }
}
```

Note that the state transitions through the `UMatSubAction::Update` call (ending→done)
are separate from this refresh — `RefreshSubActions` resets states from the scene
percentage, while `Update` handles the ending→done one-frame delay.

## GetActionFromPct and GetActionPctFromScenePct

These two methods convert between "scene percentage" (0–1) and "action-local percentage":

```cpp
UMatAction* ASceneManager::GetActionFromPct(float Pct)
{
    // Walk actions; return first whose EndPct >= Pct.
    TArray<UMatAction*>& Actions = *(TArray<UMatAction*>*)((BYTE*)this + 0x3A8);
    for (INT i = 0; i < Actions.Num(); i++) {
        UMatAction* action = Actions(i);
        if (Pct <= *(FLOAT*)((BYTE*)action + 0x7C))
            return action;
    }
    appFailAssert("0", ".\\UnSceneManager.cpp", 0xa8);
    return NULL;
}

float ASceneManager::GetActionPctFromScenePct(float Pct)
{
    // Cache the current action; compute local t = (Pct-Start) / Duration.
    if (*(INT*)((BYTE*)this + 0x3D8) == 0)
        *(UMatAction**)((BYTE*)this + 0x3D8) = GetActionFromPct(Pct);
    UMatAction* action = *(UMatAction**)((BYTE*)this + 0x3D8);
    FLOAT t = (Pct - *(FLOAT*)((BYTE*)action + 0x78)) / *(FLOAT*)((BYTE*)action + 0x80);
    return Clamp(t, 0.0001f, 100.0f);
}
```

The cached current-action pointer at this+0x3D8 is important for performance — the
scene percentage is queried repeatedly per frame, and linear searches through a
possibly-long actions array on every query would be slow.

## The Derived Sub-Action Classes

### USubActionFOV — Field of View Lerp

The FOV sub-action saves the initial FOV from the active `APlayerController` (found
at SceneMgr+0x3DC) on the first active tick (when the saved value is still 0.0),
then lerps toward the target:

```cpp
int USubActionFOV::Update(float Pct, ASceneManager* SceneMgr)
{
    if (!UMatSubAction::Update(Pct, SceneMgr)) return 0;
    ASceneManager* mgr = ...; // vtable+0x6C = GetSceneManager()
    FLOAT* SavedFOV = (FLOAT*)((BYTE*)this + 0x58);
    FLOAT* EndFOV   = (FLOAT*)((BYTE*)this + 0x5C);
    UObject* actor  = *(UObject**)((BYTE*)mgr + 0x3DC);
    // Save initial FOV on first call
    if (*SavedFOV == 0.0f && actor && actor->IsA(APlayerController::StaticClass()))
        *SavedFOV = *(FLOAT*)((BYTE*)actor + 0x3B0);
    FLOAT t = Clamp((Pct - StartPct) / Duration, 0.0001f, 1.0f);
    if (state == 2) t = 1.0f; // ending: stay at end
    *(FLOAT*)((BYTE*)actor + 0x3B0) = (*EndFOV - *SavedFOV) * t + *SavedFOV;
    return 1;
}
```

### USubActionFade — Screen Fade

The fade sub-action converts an FColor at this+0x5C to an FVector (normalised RGB),
stores it as the PlayerController's fade color at PC+0x5F8, and sets the fade alpha
at PC+0x5EC:

```cpp
// Convert FColor to normalised FVector
FColor& fadeColor = *(FColor*)((BYTE*)this + 0x5C);
FVector colorVec = (FVector)fadeColor;
*(FVector*)((BYTE*)actor + 0x5F8) = colorVec;
// Alpha - with optional reversal (bReversed at this+0x58 bit 0)
FLOAT t = Clamp((Pct - StartPct) / Duration, 0.0001f, 1.0f);
if (bEnding) t = 1.0f;
if (*(BYTE*)((BYTE*)this + 0x58) & 1) t = 1.0f - t;
*(FLOAT*)((BYTE*)actor + 0x5EC) = t;
```

### USubActionGameSpeed and USubActionSceneSpeed

Both lerping sub-actions follow the same pattern. The key difference is which speed
multiplier they target:

| Class | Target | Offset |
|-------|--------|--------|
| `USubActionGameSpeed` | `LevelInfo.TimeDilation` | `LI+0x458` |
| `USubActionSceneSpeed` | `ASceneManager.SceneSpeed` | `SceneMgr+0x3C8` |

Both save the initial speed at this+0x58 (overwriting 0.0) and lerp toward the
end speed at this+0x5C. When the state transitions to 2 (ending), `t` is forced
to 1.0 so the final value snaps exactly to the end speed.

### USubActionOrientation — One-Shot Camera Orientation

This sub-action fires once: it copies 52 bytes (13 DWORDs representing an
`FOrientation` struct) from this+0x58 and calls `ASceneManager::ChangeOrientation`.
It immediately sets state to 3 (done) to prevent re-triggering:

```cpp
struct { DWORD data[13]; } orient;
appMemcpy(&orient, (BYTE*)this + 0x58, sizeof(orient));
mgr->ChangeOrientation(*(FOrientation*)&orient);
*(BYTE*)((BYTE*)this + 0x2C) = 3;
```

`FOrientation` holds a `FRotator` + additional camera-space data (52 bytes total).

## What's Next

The `ASceneManager::SceneStarted` and `SceneEnded` methods — and the path-following
system (`DeletePathSamples`, `PreparePath`, `UpdateViewerFromPct`) — are next in line.
These are more complex (SEH frames, event dispatch, PlayerController setup) but now
much of the sub-infrastructure is in place.
