---
title: "58. The Complete Exec Stub Survey"
authors: [rvs-team]
tags: [decompilation, ghidra, r6engine, unrealscript, ai, native-functions, pathfinding]
---

Last time we touched exec stubs we fixed three functions and hit a wall. This time we went back with a systematic approach — read every single one of the 90+ stubs across all eleven source files, cross-reference each against the Ghidra export, and make a final decision: implement, annotate, or leave alone.

<!-- truncate -->

## The Survey

The exec functions live across these files, with roughly this many per file:

| File | Stubs |
|------|-------|
| R6Pawn.cpp | 27 |
| R6AIController.cpp | 17 |
| R6RainbowAI.cpp | 10 |
| R6TerroristAI.cpp | 8 |
| R6PlayerController.cpp | 8 |
| R6DeploymentZone.cpp | 9 |
| R6SoundReplicationInfo.cpp | 3 |
| R6IORotatingDoor.cpp | 3 |
| R6TerroristMgr.cpp | 2 |
| R6MatineeAttach.cpp | 2 |
| R6MP2IOKarma.cpp | 1 |

Ghidra's full function bodies live at lines 76 000–105 000 of the export. For each stub we located its body, read the logic, and decided what to do with it.

## The Three Categories

After reading all of them, every stub falls into one of three buckets.

### Bucket 1 — Already Correct

Most of the stubs were already right. Phase 4 got the parameter extraction correct and the delegation was straightforward once we had the C++ method names. Functions like `execActorReachableFromLocation`, `execFollowPath`, `execHaveAClearShot`, `execPlayWeaponSound`, `execSetAudioInfo` — all of these just call a named C++ method with the extracted parameters and return the result.

These needed no changes.

### Bucket 2 — Complex Inline Logic

A big chunk of the stubs have bodies in Ghidra that can't be translated cleanly. The culprits:

**Unknown struct layouts.** `STActionSpotCheck` appears in the signature of `FindNearestActionSpot`, but its fields are never defined in the SDK headers. Functions like `execFindPlaceToFire` and `execFindPlaceToTakeCover` allocate one of these on the stack to pass to `FindNearestActionSpot`, along with a function-pointer callback that Ghidra only knows as `FUN_1000b460`. Without knowing the struct layout or the callback identity, any translation would just be copying raw bytes in the wrong shape.

**Raw field offsets.** Ghidra constantly writes things like:

```c
*(int *)(iVar2 + 0x10188) += 1;
```

That `0x10188` is a field inside the `Level` object (the `ULevel` that contains all actors). It's somewhere in the middle of a 65 KB class definition. Without knowing which *named* field sits at offset 0x10188, any translation would be silent undefined behaviour.

**Unknown function calls.** Several functions call `FUN_10042934` — an internal helper the decompiler didn't recognise. From context it appears to be something like `appFloor(appFrand() * n)` (a dice roll), but we can't confirm that without disassembling the function itself. Using a guess here would produce a damage system that *looks* like it works but rolls dice incorrectly.

For all of these, the stubs stay as stubs. We added TODO comments explaining what Ghidra shows and where to look, so a future engineer (or a future version of this project) knows exactly what each stub is supposed to do:

```cpp
void AR6Pawn::execFootStep(FFrame& Stack, RESULT_DECL)
{
    P_GET_NAME(nBoneName);
    P_GET_UBOOL(bLeftFoot);
    P_FINISH;
    // TODO: decal/trace footstep effect — complex inline sound/decal logic (see Ghidra)
}
```

The comment is a breadcrumb, not a placeholder.

### Bucket 3 — Implementable

One function was clean enough to implement properly.

## execPollFollowPathBlocked

A quick primer on *poll functions*. In UnrealScript, some actions are *latent* — they take multiple game ticks to complete. The pattern works like this:

1. The initiating exec function (say, `execFollowPath`) sets up the destination, registers a callback, and then writes a non-zero value into `StateFrame->LatentAction`.
2. Every tick, the VM checks whether `LatentAction` is non-zero. If it is, it calls the corresponding poll function instead of advancing the script.
3. The poll function checks whether the action is done. When it is, it sets `LatentAction` back to zero and the script continues.

It's co-operative multitasking, baked into the scripting VM.

`execPollFollowPathBlocked` is the poll half of a pathing dead-end handler. When a pawn's path is blocked, the AI calls `FollowPathBlocked`, which stores the latent state (0x25a = 602) and suspends the script. Each tick, `execPollFollowPathBlocked` is called:

```c
/* Ghidra output */
void AR6AIController::execPollFollowPathBlocked(...)
{
    if (*(int *)(this + 0x3d8) != 0) {  // Pawn != NULL
        iVar1 = SetDestinationToNextInCache(this);
        if (iVar1 != 0) {
            *(int *)(StateFrame + 0x28) = 0x25a;  // LatentAction = keep waiting
            return;
        }
    }
    *(int *)(StateFrame + 0x28) = 0;  // LatentAction = done
    return;
}
```

The raw offsets resolve cleanly:
- `this + 0x3d8` = `AController::Pawn` (the possessed pawn)
- `StateFrame + 0x28` = `FStateFrame::LatentAction`
- `SetDestinationToNextInCache()` is a named C++ method on `AR6AIController`

So the translated version is:

```cpp
void AR6AIController::execPollFollowPathBlocked(FFrame& Stack, RESULT_DECL)
{
    // Poll function — no bytecode params; called by VM each tick while latent wait is active.
    // If we have a pawn and there's a next cached waypoint, keep following (LatentAction = 602).
    // Otherwise the path is exhausted or the pawn is gone, so clear the latent action.
    if (Pawn != NULL && SetDestinationToNextInCache())
        GetStateFrame()->LatentAction = 602; // EPOLL_FollowPathBlocked
    else
        GetStateFrame()->LatentAction = 0;
}
```

Note that poll functions don't call `P_FINISH`. Regular exec functions read arguments from the bytecode stream using `P_GET_*` and then call `P_FINISH` to advance the bytecode pointer past the end-of-call marker. Poll functions are invoked differently — the VM calls them directly from the latent action loop, not from a script callsite — so there's no bytecode stream to consume.

## The Damage Functions

`execGetKillResult`, `execGetStunResult`, and `execGetThroughResult` are all stubs returning zero. Ghidra shows they call `R6Charts::GetKillTable(eBodyPart)` to get a pointer into a damage lookup table, generate a random value, and compare against thresholds.

These will need their own dedicated post. Implementing them correctly requires understanding `R6Charts` (which hasn't been fully decompiled yet), the `stResultTable` struct layout, and the enum values for `eBodyPart` and `eArmorType`. Getting a damage function wrong is worse than having a stub — a stub at least fails visibly. An incorrect damage function produces numbers that look plausible but are subtly wrong, which is much harder to debug.

## The Vision Properties Functions

`execToggleHeatProperties`, `execToggleNightProperties`, and `execToggleScopeProperties` are used by the gadget system to apply thermal, night-vision, and scope overlays to the viewport. Ghidra shows they manipulate viewport texture slots via deep struct offsets into the render state.

These are aesthetic — the game renders without them — but they're also where Rainbow Six's signature gadget mechanics live. They'll be properly implemented when we tackle the HUD/viewport layer.

## What This All Means

Every exec function now either:
- Has a correct implementation (calls the right C++ method, or does the right thing)
- Has a correct stub (parameters consumed cleanly, safe default return) with a TODO comment explaining the missing logic
- Is genuinely empty (like `execTestLocation`, which Ghidra confirms does nothing in the original)

The bytecode bridge is solid. Scripts can call any of these functions without corrupting the stack or crashing the VM. They just won't do the *right thing* yet for the more complex cases — but that's a known, documented gap rather than a hidden one.
