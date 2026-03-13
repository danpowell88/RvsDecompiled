---
slug: stubs-to-code-implementing-ai-and-matinee
title: "63. Stubs to Code: Implementing AI Movement and Matinee Animation"
authors: [dan]
tags: [decompilation, ai, matinee, windrv, unreal-engine]
---

Up until now, large chunks of the codebase compiled and linked but silently did nothing — they returned zero, returned null, or had entirely empty bodies. This post is about the milestone of replacing all those stubs with faithful implementations derived from the Ghidra decompilation export. Think of it as going from a skeleton to a body: the bones were in the right place, now there's muscle on them.

<!-- truncate -->

## What Is a Stub, and Why Did We Have So Many?

When you're rebuilding a game binary you don't have source for, you proceed in layers. The first goal is *linkability*: get every function declared so the linker is happy and you have a binary that loads. The second goal is *correctness*: replace the empty bodies with real implementations.

Stub functions look like this:

```cpp
INT AR6AIController::CanWalkTo(FVector, INT)
{
    return 0;
}
```

The game calls this function. It gets 0 back. Nothing explodes. But nothing works either. This post covers the batch of stubs we implemented this time — across three modules:

- **WinDrv** — the Windows driver DLL (window management, DirectInput)
- **R6AIController** — the AI controller (pathfinding, movement latent actions)
- **R6Matinee** — in-game cutscene animation (the matinee sub-action system)

---

## WinDrv: Small Things That Matter

WinDrv is the layer between Unreal's abstract viewport system and Win32. It's relatively small but there were a handful of functions that needed real bodies.

### GetWindowClassName

This one had a cosmetic bug — it was generating the window class name dynamically using `appSprintf`:

```cpp
// Before (stub):
appSprintf(OutName, TEXT("%sUnreal"), appPackage());
// → "WinDrvUnreal"
```

Ghidra showed the retail binary just writes a fixed string:

```cpp
// After:
appStrcpy(OutName, TEXT("WWindowsViewportWindow"));
```

The string `"WWindowsViewportWindow"` is the actual Win32 window class name used for Ravenshield's main game window. The stub produced `"WinDrvUnreal"` which would have registered the wrong window class name, potentially causing any code that looks up the window class to fail.

### UWindowsClient::Exec

The client's command execution handler was silently swallowing all commands:

```cpp
// Before:
return 0;

// After:
return Super::Exec(Cmd, Ar) != 0;
```

This is the standard UE2 pattern: try to handle the command yourself, and if you don't recognise it, pass it up the chain. Returning 0 always means the command chain terminates here and nothing above `UWindowsClient` in the hierarchy ever sees the command.

### HoldCount: A Raw Offset Divergence

`Hold` and `Unlock` both operate on a field called `HoldCount` that lives inside the `UViewport` base class. The problem: our local header doesn't expose this field by name. Ghidra confirmed it's at offset `0x214` from the viewport object's `this` pointer.

We use a raw byte offset with a `DIVERGENCE` comment:

```cpp
void UWindowsViewport::Hold(INT Horiz)
{
    guard(UWindowsViewport::Hold);
    // DIVERGENCE: HoldCount at raw offset 0x214 in UViewport; not in local headers.
    INT& HoldCount = *(INT*)((BYTE*)this + 0x214);
    if (Horiz) HoldCount++; else HoldCount--;
    unguard;
}
```

The `Horiz` parameter isn't a horizontal offset — it's a boolean: nonzero means "lock" (increment hold), zero means "release" (decrement). It's a somewhat confusing name from the original UE2 source.

`Unlock` similarly asserts the count is zero before calling `Super::Unlock()` — you shouldn't unlock if there are outstanding holds.

---

## AI Controller: Latent Movement Actions

Unreal Engine's scripting system has a concept of *latent functions* — functions that can span multiple game ticks before completing. Movement is the classic example: when you call `MoveTo()` in UnrealScript, the engine sets a `LatentAction` code in the state frame and then calls a corresponding `execPoll*` function every tick until the move finishes.

R6's AI builds on this with its own movement functions. Here are the key ones we implemented.

### A Quick Primer on UnrealScript Native Glue

Every UnrealScript function that has a native implementation gets a pair of C++ functions. The exec function (named `execFoo`) reads bytecode arguments off the stack, does its work, and optionally sets up a latent action. The poll function (named `execPollFoo`) is called every tick while the latent action is active.

The bytecode reading boilerplate looks like this:

```cpp
void AR6AIController::execMoveToPosition(FFrame& Stack, RESULT_DECL)
{
    P_GET_STRUCT(FVector, VPosition);    // read a 3-float struct from bytecode
    P_GET_STRUCT(FRotator, rOrientation); // read a 3-int rotator from bytecode
    P_FINISH;                            // consume the end-of-params marker

    // ... actual logic ...
}
```

The `P_GET_*` macros advance a bytecode program counter and call native evaluators to pull each argument. Once you have the arguments, the rest is just regular C++.

### execMoveToPosition: Direct Positional Movement

This function tells the pawn to move directly to a world position (not along a nav path). It:

1. Resets `m_eMoveToResult` to 0 (in-progress)
2. Calculates the distance to the destination
3. Stores the destination in `Destination` (for the poll function to use)
4. Computes a `FocalPoint` from the destination and orientation
5. Calls `Pawn->setMoveTimer(dist)` to set a timeout
6. Sets `LatentAction = 0x259` (decimal 601) — the code for `execPollMoveToPosition`
7. Initiates the move with `AR6Pawn::moveToPosition(Destination)`

The focal point calculation is: take the direction vector from `rOrientation`, multiply by 200 world units, and add to the destination. This gives the AI something to "look at" while moving:

```cpp
FocalPoint = Destination + rOrientation.Vector() * 200.0f;
```

The poll function `execPollMoveToPosition` runs every tick and calls `moveToPosition` again (which in the engine returns non-zero when the pawn has arrived). There's also a secondary path for `bAdjusting` — when the AI is wall-adjusting (taking a slight detour around a collision), it moves to `AdjustLoc` instead:

```cpp
if (bAdjusting)
{
    bAdjusting = (((AR6Pawn*)Pawn)->moveToPosition(AdjustLoc) == 0) ? 1 : 0;
    bSkipMainMove = bAdjusting;
}
if (!bSkipMainMove)
{
    if (((AR6Pawn*)Pawn)->moveToPosition(Destination))
        GetStateFrame()->LatentAction = 0;
}
if (GetStateFrame()->LatentAction == 0 && m_eMoveToResult == 0)
    m_eMoveToResult = 2;  // 2 = done/arrived
```

### execFollowPathTo: Navigated Pathfinding

`FollowPathTo` is for navigated movement — it uses Unreal's nav mesh (NavigationPoints) to find a route. The function:

1. Calls `AController::FindPath(dest, goalActor, 0)` to find the first waypoint
2. Stores the result in `MoveTarget`
3. If no path was found, sets `LatentAction = 0` and marks the move as failed
4. If a path was found, scans `RouteCache[16]` for a free slot, marks it with a sentinel value (per Ghidra — value `1`), then calls `FollowPath()`

There's a known divergence here: the retail binary makes an additional call through `XLevel->vtable[39]` passing `vDestination` before calling `FindPath`. The exact semantics of this navigation helper are unclear from Ghidra's output, so we omit it and document the gap.

### execPickActorAdjust: Adjusting Around Obstacles

This function is called when the AI needs to adjust its path around an actor in the way. It checks whether the blocking actor is close to the AI's stored destination — if it's far enough away (its collision radius squared doesn't dominate the distance), it delegates to `AR6Pawn::PickActorAdjust`. Otherwise it stalls the latent action:

```cpp
FLOAT dX = Destination.X - pActor->Location.X;
FLOAT dY = Destination.Y - pActor->Location.Y;
FLOAT r = pActor->CollisionRadius;
if (4.0f * r * r <= dX * dX + dY * dY)
{
    *(INT*)Result = ((AR6Pawn*)Pawn)->PickActorAdjust(pActor);
    return;
}
// Too close to the destination — don't adjust, stall the latent action
*(INT*)Result = 0;
INT latent = GetStateFrame()->LatentAction;
if (latent == 0x25A || latent == 0x25B)
    GetStateFrame()->LatentAction = 0x25B;  // PollFollowPathBlocked
else
    GetStateFrame()->LatentAction = 0;
```

The `0x25A` and `0x25B` values are the latent action codes for `PollFollowPath` (602) and `PollFollowPathBlocked` (603). The "blocked" poll function handles the case where the path ahead is obstructed and the AI needs to wait or reroute.

---

## Matinee: Animation Sub-Actions

The matinee system in UE2 is how scripted cutscene animations play. A `UMatAction` contains a list of `UMatSubAction` objects, each of which drives something in the scene over time. `UR6SubActionAnimSequence` is Rainbow Six's custom sub-action type — it plays a named animation sequence on an actor, advancing through a playlist of animation clips.

Before these implementations, `Update`, `UpdateGame`, and `LaunchSequence` all returned 0 and did nothing.

### LaunchSequence: Playing an Animation

`LaunchSequence` fires the current animation clip at the affected actor. It calls two functions through raw vtable slots because they don't have named C++ bindings in our headers:

```cpp
INT UR6SubActionAnimSequence::LaunchSequence()
{
    if (!m_AffectedActor)
        return 0;

    // Set channel 17 to full blend weight
    m_AffectedActor->AnimBlendParams(0x11, 1.0f, 0.0f, 0.0f, NAME_None);

    // DIVERGENCE: PlayAnim via raw vtable slot 88 (offset 0x160) on m_AffectedActor.
    typedef void (__thiscall *TPlayAnim)(AActor*, INT, INT, FLOAT, FLOAT, INT, INT, INT);
    TPlayAnim pfPlayAnim = (TPlayAnim)(*(INT**)m_AffectedActor)[0x160 / 4];
    pfPlayAnim(m_AffectedActor, 0x11, *(INT*)&m_CurSequence->m_Sequence,
               m_CurSequence->m_Rate, m_CurSequence->m_TweenTime, 0, 0, 0);

    if (m_bUseRootMotion)
    {
        // StopAnim on a second channel to suppress root motion blending
        typedef void (__thiscall *TStopAnim)(AActor*, INT, INT, INT, INT, FLOAT);
        TStopAnim pfStopAnim = (TStopAnim)(*(INT**)m_AffectedActor)[0x11C / 4];
        pfStopAnim(m_AffectedActor, 0xC, 0, 0, 0, 1.0f);
        *(DWORD*)((BYTE*)m_AffectedActor + 0xA8) &= ~0x1000;
    }
    return 1;
}
```

The raw vtable slot pattern (`(*(INT**)actor)[slot]`) is how you call a virtual function through a manually computed vtable offset. Ghidra exposes the actual slot numbers; we encode them as named constants in the DIVERGENCE comments so they're easy to find and fix if the layout is ever pinned down more precisely.

### Update and UpdateGame: The Per-Tick Logic

`Update` is the virtual method called by the matinee system every tick. The split between `Update` and `UpdateGame` is intentional: `Update` handles editor-specific preview logic (which we skip — it requires even deeper mesh vtable calls), and `UpdateGame` handles runtime playback.

```cpp
INT UR6SubActionAnimSequence::Update(FLOAT Time, ASceneManager* Mgr)
{
    if (!UMatSubAction::Update(Time, Mgr))
        return 0;
    if (GIsEditor)
        return 1;  // DIVERGENCE: editor preview omitted
    return UpdateGame(Time, Mgr);
}
```

`UpdateGame` is more interesting. It uses a "first-time" flag (`m_bFirstTime`) to initialise the sequence list, then on subsequent ticks it increments a frame counter (`m_PlayedTime`) and checks whether the current clip has reached `m_MaxPlayTime`. When it has — and the clip isn't set to loop — it calls `IncrementSequence()` to advance to the next clip or fire `eventSequenceFinished()` if there are no more.

The "active" check at the top uses another raw vtable call (slot 27 on `this`). From context this is almost certainly `IsRunning()` from `UMatSubAction` — if the sub-action isn't marked as running yet, return 1 immediately without doing any animation work.

---

## The DIVERGENCE Comment Pattern

Throughout all of these implementations you'll see comments like:

```cpp
// DIVERGENCE: retail calls XLevel vtable[39] on vDestination before FindPath.
// Exact semantics unknown; call is omitted.
```

These are deliberate markers. When something in the retail binary can't be cleanly named or translated — a raw vtable slot, an unknown field offset, an omitted helper call — we document *what* the retail code does, *why* we can't replicate it exactly, and *what* we do instead. This makes it easy for a future contributor to grep for `DIVERGENCE` and understand exactly where our reconstruction falls short of byte accuracy.

It's also honest. The goal of this project isn't to pretend we've recovered the source — it's to produce a readable, buildable reconstruction with documented gaps.

---

## What's Still a Stub?

Not everything got implemented. Some functions remain as stubs because their Ghidra bodies involve too many unknown helper functions to translate safely:

- **`AR6AIController::CanHear`** — 1534-byte function with complex actor iteration and sound attenuation math
- **`AR6AIController::CanWalkTo`** — requires two `SingleLineCheck` navigation probes with unknown parameters
- **`AR6AIController::FindNearestActionSpot`** — iterates action spot lists but requires unnamed callback infrastructure
- **`AR6FalseHeartBeat::IsRelevantToPawnHeartBeat`** — 382-byte function calling three unnamed helpers
- **`GetAnimDuration`, `IsAnimAtFrame`, `PctToFrameNumber`** — all require mesh API calls through unknown vtable slots

These are documented with comments explaining what Ghidra showed. They return safe defaults (0 or NULL) and won't crash anything — the game just won't have full AI hearing, optimal waypoint selection, or precise frame-based animation queries until those are filled in.

## Result

Both the `WinDrv` and `R6Engine` DLLs build and link cleanly with all the new implementations. The stub count is meaningfully lower, and the documented divergences give a clear map of what remains to be resolved in future sessions.
