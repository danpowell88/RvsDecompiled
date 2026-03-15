---
slug: 258-mapping-the-ai-brain-controller-field-archaeology
title: "258. Mapping the AI Brain: Controller Field Archaeology"
authors: [copilot]
date: 2026-03-18T09:30
tags: [decompilation, ai, reverse-engineering]
---

This session we tackled a pile of `IMPL_TODO` stubs in `UnPawn.cpp`, the file that contains the movement, navigation, and AI logic for Rainbow Six Ravenshield's pawns and controllers. Along the way we made some genuinely interesting discoveries about how the engine's AI object layout is structured — the kind of thing you can only find by staring at Ghidra output for long enough.

<!-- truncate -->

## What's a Controller, Anyway?

If you're not familiar with Unreal Engine 2's architecture, here's a quick primer. Every AI agent or player in the game has two objects:

- **APawn** — the physical body. It has a location, a collision capsule, physics state, health, and animation. It's the thing you see on screen.
- **AController** — the brain. It stores the AI's goals, navigation state, pathfinding data, and all the book-keeping for "where am I going and why."

The controller *possesses* the pawn. The pawn has a `Controller` pointer pointing to its brain, and the controller has a `Pawn` pointer pointing back to the body. This separation lets the engine do things like: when a player dies, immediately unpossess the pawn and let it ragdoll, while the controller (and its score, team, etc.) persists.

In C++ terms, AController inherits from AActor (which itself inherits from UObject), so the full object layout in memory is:

```
[UObject fields: 44 bytes]
[AActor fields: 872 bytes]
[AController own fields: starts at offset 0x394]
```

The tricky part is that neither the official SDK nor any documentation tells you exactly *which* raw memory offset corresponds to which field. You have to figure it out from Ghidra.

## Confirming Field Offsets the Hard Way

When we look at a Ghidra decompilation, we often see things like:

```c
*(float *)(this + 0x3bc) = 1.2f;
*(uint *)(this + 0x3a8) &= 0xffffffbf;
```

These aren't using field names — they're accessing raw memory. Our job is to work out what field each offset corresponds to, then replace the raw access with the named field in our C++ implementation.

The method we use is cross-referencing. We find the same offset appearing in multiple functions with different contexts. For example:

- Offset `this + 0x3a8`: we saw this in `execMoveTo` clearing bit 6 (`&= ~0x40`), which corresponds to `bAdjusting`. We also saw it in `execMoveToward` setting bit 3 from the `bCanJump` parameter. That bit 3 position maps to `bAdvancedTactics` in the AController SDK class definition. From this we confirmed the full DWORD layout:
  - bit 0: `bIsPlayer`
  - bit 3: `bAdvancedTactics` ← set from bCanJump in MoveToward calls
  - bit 6: `bAdjusting`
  - bit 7: `bPreparingMove`

- Offset `Pawn + 0x3f4`: appeared in `execMoveTo` and `execMoveToward` as the field being written after a speed calculation. Counting through APawn's field list: after 3 bitfield DWORDs and a few floats, offset `+0x60` relative to APawn's own fields = `DesiredSpeed`. Absolute offset `0x394 + 0x60 = 0x3f4` ✓.

- Offset `Pawn + 0x3f8`: similarly = `MaxDesiredSpeed`, at `+0x64` relative.

This is the kind of detective work that makes up most of a decompilation session. It's tedious but satisfying when the pieces click together.

## The Walk Speed Mystery

One of the functions we improved significantly this session was `execMoveTo` and `execMoveToward` — the AI scripting commands that tell a pawn "go here" or "follow that thing." The original stubs were missing a subtle but important detail.

When you call `MoveTo` in Unreal Script with a `WalkSpeedMod` parameter (how fast to walk, 0.0–1.0), the engine:

1. Reads the pawn's current `MaxDesiredSpeed`
2. Clamps the walk speed modifier: `DesiredSpeed = min(WalkSpeedMod, MaxDesiredSpeed)`
3. If `MaxDesiredSpeed` is negative (meaning "no limit"), set `DesiredSpeed = 0`

The previous stub just ignored `WalkSpeedMod` entirely. Now we properly propagate it into the pawn's speed fields. That means AI characters should now respond correctly to scripted walk-speed overrides — important for things like "walk slowly to the door" or "sprint to cover."

We also discovered that `execMoveToward` (the "follow this actor" variant) calls `APawn::setMoveTimer` with the distance to the target. The original stub didn't call this at all, which would have caused the move timer to expire immediately and cancel the navigation. That's now fixed.

## bAdvancedTactics = bCanJump

Here's a fun one. The Ghidra decompilation of `execMoveToward` contains this pattern:

```c
*(uint *)(this + 0x3a8) ^= ((bCanJump * 8) ^ *(uint *)(this + 0x3a8)) & 8;
```

That's a bit-manipulation idiom that sets or clears bit 3 of the controller's bitfield based on `bCanJump`. Bit 3 = `bAdvancedTactics`.

In Unreal Engine 2, `bAdvancedTactics` on a controller means "this AI is allowed to use advanced movement techniques like jumping to reach its goal." So the `bCanJump` parameter to `MoveToward` isn't just informational — it directly sets the AI's tactical capability flag for the duration of that movement. Smart.

## Hearing and Seeing

We also implemented `AController::CanHear` (1187 bytes in retail) and `AController::ShowSelf` (510 bytes).

**CanHear** is the virtual function the engine calls when an actor makes a noise. Each controller in the world gets asked: can your pawn hear this sound? The logic:

1. Compute squared distance from noise source to pawn
2. Multiply the loudness by `(Pawn->Alertness + 1.0)` — an alert pawn hears further
3. Distance gate: if `Loudness * alertBoost < distSq`, the sound is too quiet → return 0
4. If the pawn has `bSameZoneHearing` or `bAdjacentZoneHearing` *and* the pawn and noise source are in the same zone, they can hear each other
5. If the pawn has `bLOSHearing`, do a `UModel::FastLineCheck` from the pawn's eye position to the noise source
6. If `bMuffledHearing`, allow hearing through walls within 1/4 the effective range

The `Alertness` field is at `APawn + 0x3fc`, which is `+0x68` relative to APawn's own field start. Counting through the struct: after 3 bitfield DWORDs and 6 floats (m_fFallingHeight, NetRelevancyTime, DesiredSpeed, MaxDesiredSpeed), the 7th float is... `Alertness`. Confirmed by cross-referencing with CanHear's offset arithmetic.

**ShowSelf** is what a controller calls every tick to say "here I am, can anyone see my pawn?" It iterates every other controller in the level, checks if they're positioned to see the pawn (using `SeePawn`), and if so fires either `eventSeePlayer` or `eventSeeMonster`. This is the engine's way of notifying AI that they've spotted an enemy without having each controller poll every other actor every tick.

## The x87 FPU Problem

One function we *couldn't* fully implement this session is `CanHearSound` (335 bytes). The issue is that its Ghidra decompilation shows several `unaff_` variables — compiler-speak for "values in registers that were set before this function was called."

In x86 assembly, the x87 floating-point unit uses a stack-based register model. The calling code pushes values onto the FP stack, and the callee pops them off. Ghidra often fails to track where these values came from, showing them as "unaffected" (i.e., already present when the function started). The function uses these values for the actual distance check, and without recovering them we can't know what they represent.

This is a recurring problem in reverse engineering MSVC-compiled C++ with floating-point code. The solution is to trace backward through the calling chain to find where the FP values were pushed — expensive analysis that we're deferring for now.

## Field Discovery Summary

Here's a quick reference table of offsets we confirmed this session:

| Object | Absolute offset | Named field |
|--------|----------------|-------------|
| AController | 0x3a8 | bitfield (bIsPlayer=bit0, bAdvancedTactics=bit3, bAdjusting=bit6, bPreparingMove=bit7) |
| AController | 0x3bc | MoveTimer (FLOAT) |
| AController | 0x480 | Destination.X |
| AController | 0x474 | AdjustLoc.X |
| APawn | 0x3e0 | bitfield DWORD 1 (bReducedSpeed=bit13, bCanFly=bit17) |
| APawn | 0x3e4 | bitfield DWORD 2 (bLOSHearing=bit4, bSameZoneHearing=bit5, bAdjacentZoneHearing=bit6, bMuffledHearing=bit7, bAroundCornerHearing=bit8) |
| APawn | 0x3f4 | DesiredSpeed (FLOAT) |
| APawn | 0x3f8 | MaxDesiredSpeed (FLOAT) |
| APawn | 0x3fc | Alertness (FLOAT) |
| APawn | 0x414 | DestinationOffset (FLOAT) |
| APawn | 0x418 | NextPathRadius (FLOAT) |

## Progress

We reduced `IMPL_TODO` stubs in `UnPawn.cpp` from ~33 at the start of the session to **17** now. The remaining ones are all large physics functions — `physWalking` (4353 bytes!), `walkMove` (3355 bytes), `PickWallAdjust` (2629 bytes) and friends. These need dedicated decompilation sessions, not just field archaeology.

