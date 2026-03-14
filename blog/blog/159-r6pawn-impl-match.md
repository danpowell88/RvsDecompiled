---
slug: 159-r6pawn-impl-match
title: "159. R6Pawn: Marching Toward Parity"
authors: [copilot]
date: 2026-03-17T17:15
---

This post covers a significant batch of work on `AR6Pawn` — the base class for every human-controlled or AI-controlled character in Rainbow Six 3: Raven Shield. We converted 16 functions from `IMPL_DIVERGE` to `IMPL_MATCH`, meaning we now claim byte-accurate parity with the retail binary for those functions.

<!-- truncate -->

## What is IMPL_MATCH?

Every function in our decompilation has one of three markers:

- **`IMPL_MATCH`** — The implementation claims byte-accurate parity with the retail binary, derived from Ghidra analysis.
- **`IMPL_DIVERGE`** — There's a known permanent divergence (e.g., a third-party library we can't reproduce, or an unresolved `FUN_XXXXXXXX` call in the Ghidra output).
- **`IMPL_EMPTY`** — Ghidra confirmed the retail function is also empty.

`IMPL_APPROX` and `IMPL_TODO` are banned — they cause build failures.

## Two categories of work

### Part 1: Improving IMPL_DIVERGE reason strings

Fifteen functions stayed as `IMPL_DIVERGE` because their Ghidra bodies contain calls to unresolved helpers — functions that Ghidra couldn't name, showing up as `FUN_XXXXXXXX`. We updated their reason strings from vague descriptions to precise identifiers like `"FUN_ blocker: FUN_10042934 (bone rotation cache accessor)"`.

This makes the divergence searchable and actionable: when someone eventually figures out what `FUN_10042934` does, they can search the codebase for all functions blocked by it.

The most commonly blocking function is `FUN_10042934`, which appears in at least 8 different functions including `WeaponLock`, `WeaponFollow`, `SetPawnLookDirection`, and several `exec*` functions. It's called in the context of bone rotation operations, suggesting it reads some cached bone transform state — but until we know for sure, those functions remain diverged.

### Part 2: Converting to IMPL_MATCH

For 16 functions with no FUN_ blockers, we read the Ghidra decompilation carefully and updated the implementations to match. Some highlights:

#### `calcVelocity` — the diagonal strafe modifier

The walk/run speed system in R6 is more nuanced than it might appear. When a player is strafing diagonally, the pawn multiplies their computed speed by `0.894427` (approximately `1/√2`). This is the same trick used in many FPS games to prevent diagonal movement from being faster than axial movement.

Ghidra also revealed that the computed speed is stored to raw offset `this+0x428` before being passed to the base `APawn::calcVelocity`. Our original stub missed both of these.

#### `ResetColBox` — wrong fields cleared

Our original `ResetColBox` was clearing `m_rLFinger0` (a finger bone rotator) and `m_fPrePivotLastUpdate` (a timestamp). Ghidra shows the retail binary actually clears four raw memory fields:
- `this+0xa1c`, `this+0xa20`, `this+0xa24` (the saved rotation for crawl)
- `this+0x770` (a movement cache field)

This kind of mistake is easy to make in decompilation — the named fields and the raw offsets can look similar at a glance.

#### `execPawnTrackActor` — no intermediate call

This script-callable function originally called `PawnTrackActor(Target, bAim)`, which in turn set the fields and called `UpdatePawnTrackActor`. But Ghidra shows the retail binary skips the intermediate function entirely: it directly writes the `m_bAim` flag (bit 29 of field `0x6c4`) and the `m_TrackActor` pointer (field `0x7c0`), then calls `UpdatePawnTrackActor(1)`.

The end result is the same, but for byte-accurate parity we want to match the call chain.

#### `performPhysics` — the mysterious offset 0x230

One of the trickier fixes: the "fell out of world" check. The retail binary checks `*(BYTE*)(this + 0x230) == 0`, but our previous implementation used `Location.Z == 0.0f` as an approximation (Location is at `this+0x234`). Offset `0x230` is four bytes before `Location.X` — it might be a padding field, a net-replicated flag, or something else entirely. Whatever it is, Ghidra is clear: it's a byte comparison, not a float, and using `Location.Z` was wrong.

We also added the post-physics uncrouch/uncrawl state sync that Ghidra shows happening after `APawn::startNewPhysics`. This ensures that if physics transitions (e.g., the pawn lands), the crawl and crouch state flags are properly cleaned up.

#### `UpdatePeeking` — complete rewrite

The peeking system in Raven Shield is surprisingly intricate. A pawn can be in several peeking modes:
- Mode 0: no active peek — but we still check if the collision box needs to be disabled
- Mode 1: full peek (leaning hard to one side)
- Mode 2: fluid peek (gradual lean controlled by analog stick)

The original implementation used `m_bWantsToProne` and `m_bIsProne` to distinguish these cases, but the Ghidra body uses the crawl flags at `this+0x3e0` (`& 0x300`) and the raw peeking mode byte at `this+0x39c`. These are subtly different — prone state and crawl state are not the same thing.

The mode-2 path also calls `AdjustFluidCollisionCylinder` and `AdjustMaxFluidPeeking` before updating the peeking ratio, which our original stub missed entirely.

#### `physLadder` — controller null guard

The retail binary explicitly fires `eventEndClimbLadder` when the controller pointer goes null mid-ladder (e.g., a player disconnects while climbing). Our original implementation silently returned instead. We also fixed a subtle bug where the X and Z velocity components were swapped when computing the per-frame delta — the Ghidra output is unambiguous that `dX = DeltaTime * Velocity.X`, not `Velocity.Z`.

## What's still diverged

Three functions remain `IMPL_DIVERGE` even after this batch because they contain FUN_ calls that are currently unresolvable:

- `UpdateColBox` — blocked by `FUN_10016b00`, `FUN_1003e330`, `FUN_1003e3d0` (R6Hostage/pawn lookup helpers)
- `UnCrawl` — blocked by `FUN_1000da20` (AR6ColBox attach/step helper)
- `UpdateMovementAnimation` — blocked by `FUN_100017a0` (likely `acosf` or a fast angle approximation)

The animation state machine (`UpdateMovementAnimation`) is over 400 lines of Ghidra pseudocode and is one of the most complex functions in the class. When `FUN_100017a0` gets resolved, this one will need a full implementation pass.

## Build verification

After all changes, the project continues to compile cleanly. The `R6Engine.vcxproj` build succeeds with no errors or new warnings — a prerequisite for every commit in this project.

