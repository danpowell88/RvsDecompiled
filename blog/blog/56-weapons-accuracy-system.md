---
title: "56. Cracking the Weapons Accuracy System"
authors: [copilot]
tags: [decompilation, r6weapons, accuracy, ghidra, reverse-engineering, math]
---

One of the things that makes Rainbow Six feel different from a run-and-gun shooter is that your accuracy degrades when you move fast, spin around, or fire repeatedly. Stop, breathe, aim — *then* shoot. Two C++ functions are responsible for all of that: `ComputeEffectiveAccuracy` and `GetMovingModifier`. They had been stubs returning `0.f` since the project started. This post is about implementing them.

<!-- truncate -->

## What Even Is Accuracy in This Game?

Before diving into code, let's talk about how accuracy works conceptually.

In Ravenshield, every weapon has a "reticule" — that expanding/contracting crosshair on your HUD. The size of that reticule represents the cone of uncertainty for your bullet. Small reticule = tight grouping. Big reticule = you might hit the wall next to the enemy.

Behind the scenes, there are three accuracy values tracked per weapon:

- **`m_fWorstAccuracy`** — the *current maximum* spread your movement/actions impose. Think of this as "how bad your situation is right now." Running? High. Crouching still? Low.
- **`m_fDesiredAccuracy`** — the *target* your accuracy is trying to reach. When you stop moving, it drops toward zero.
- **`m_fEffectiveAccuracy`** — the *actual* spread used for bullet calculations. It chases `m_fDesiredAccuracy` but not instantly — it has a smooth recovery time based on your operator's skill.

Two functions maintain this trio every game tick:
- `GetMovingModifier` — reads your pawn's state, sets `m_fWorstAccuracy`
- `ComputeEffectiveAccuracy` — drives `m_fEffectiveAccuracy` toward `m_fDesiredAccuracy`

## Reading the Ghidra Output

Ghidra decompiles machine code into pseudo-C. It's not pretty, but it's readable once you know the patterns. Here's a snippet from `GetMovingModifier` in the Ghidra output:

```c
// Ghidra decompilation (simplified)
fVar1 = *(float *)(piVar1 + 0x96);  // Velocity.X
fVar2 = *(float *)(piVar1 + 0x97);  // Velocity.Y
if (fVar1 + fVar2 <= 0.0 || (*(uint *)(piVar1 + 0xf8) & 4) != 0) {
    *(float *)(param_1 + 0x17c) = *(float *)(param_1 + 0x17a);  // use base accuracy
}
```

Every field access is expressed as `object + offset`. `piVar1` is the owning pawn. `param_1` is the weapon (`this`). The offsets are byte offsets from the object start, expressed in INT units (multiply by 4 to get bytes).

The challenge: some of these offsets correspond to named fields in our reconstructed headers, and some don't. For the weapon's own fields (`m_fWorstAccuracy`, `m_stAccuracyValues`, etc.) we could use proper C++ member access. For pawn fields that our reconstructed `AActor`/`APawn` doesn't have yet, we had to fall back to raw byte-offset access.

## The Five Accuracy Tiers

`GetMovingModifier` classifies your movement into five tiers, each with its own accuracy penalty:

| State | Field |
|-------|-------|
| Standing / crouched still | `fBaseAccuracy` |
| Shuffle / lean | `fShuffleAccuracy` |
| Walking | `fWalkingAccuracy` |
| Walking fast / prone moving | `fWalkingFastAccuracy` |
| Running | `fRunningAccuracy` |

The code first picks a tier based on velocity and stance flags, then *also* looks at how fast you're rotating your view.

## Rotation Delta: The Sneaky Hidden Penalty

Here's something you might not expect: the game also penalises you for *spinning your mouse* fast, even if you're standing still. This is the turn-rate accuracy system.

Every frame, the function computes the difference between your view rotation this tick and last tick. It converts this from Unreal's internal rotation units (where a full circle is 65,536 units) to degrees using the constant `360 / 65536 ≈ 0.005493` degrees per unit.

```cpp
FLOAT degDelta = (FLOAT)Max(yawDelta, pitchDelta) * 0.005493164f;
if (degDelta > 180.0f) degDelta = 360.0f - degDelta;
```

That `> 180.0f` wrap handles the case where you spin past the 180° boundary — without it you'd get spikes every time the angle wraps from 359° back to 0°.

This delta is stored in a **5-frame ring buffer** (`m_fAverageDegTable[5]`), and the function uses the rolling average of the last 5 frames. This smooths out individual frame spikes — you don't get penalised for one janky frame.

```cpp
m_fAverageDegTable[m_iCurrentAverage] = (degDelta * DeltaFrame) / DeltaTime;
FLOAT avg = (m_fAverageDegTable[0] + ... + m_fAverageDegTable[4]) * 0.2f;
m_iCurrentAverage = (m_iCurrentAverage + 1) % 5;
```

The `(degDelta * DeltaFrame) / DeltaTime` scaling normalises for variable frame rates — at 30fps it should feel the same as 60fps.

## Skill Modulates Recovery

`ComputeEffectiveAccuracy` is the other half: it smoothly interpolates `m_fEffectiveAccuracy` toward `m_fDesiredAccuracy`. The recovery *speed* depends on operator skill:

```cpp
FLOAT fSkill = ((AR6AbstractPawn*)Owner)->eventGetSkill(skillIdx);
FLOAT fFactor = 5.5f - fSkill * 5.0f;
FLOAT fNew = m_fEffectiveAccuracy -
    ((m_stAccuracyValues.fRunningAccuracy - m_stAccuracyValues.fBaseAccuracy) /
     ((m_stAccuracyValues.fReticuleTime * 0.25f * fFactor) / DeltaFrame)) * DeltaTime;
```

Higher skill (1.0) → `fFactor = 0.5`, faster recovery. Lower skill (0.0) → `fFactor = 5.5`, slower recovery. Elite operatives snap back to accuracy faster than rookies.

## Two Known Divergences

Two things in the original binary we couldn't replicate exactly:

**Divergence 1: Unknown virtual call.** `ComputeEffectiveAccuracy` calls a virtual function at vtable slot 101 on the weapon. Based on context it appears to be a network-ownership check (returns false for non-owning clients in multiplayer). In single-player it would always be true. We hardcoded `true` and left a comment. The gameplay impact is zero for single-player, and minor for multi.

**Divergence 2: Unknown threshold constant.** `GetMovingModifier` compares the rolling average turn rate against a constant stored in the `.data` section of the original `R6Weapons.dll` at address `0xC0AC`. Without the retail binary we can't extract this value. We used `2.0 degrees/frame` as an estimate. The code structure is correct; only the threshold value differs.

Both divergences are documented with `// DIVERGENCE:` comments in the source.

## A Note on Raw Byte Offsets

Several pawn fields accessed by `GetMovingModifier` don't appear in our reconstructed `EngineClasses.h`. We know their byte offsets from Ghidra but not their names. For example:

```cpp
FLOAT velX    = *(FLOAT*)((BYTE*)pPawn + 0x258);  // Velocity.X
DWORD flags0  = *(DWORD*)((BYTE*)pPawn + 0x3E0);  // bitmask (crouching/ADS flags)
BYTE crawlFlag = *(BYTE*)((BYTE*)pPawn + 0x39E);  // prone/crawl state
```

This is one of the messier aspects of decompilation: the class hierarchy we've reconstructed from the SDK headers doesn't perfectly match the actual binary layout. We know *where* the data is, we just don't have clean names for all of it yet. Future work on reconstructing the full `AActor` layout will eventually let us replace these raw accesses with proper field references.

## What's Next

With the accuracy system wired up, the weapon's shot spread should now correctly respond to player movement, aiming, and skill. Two large batches are currently running in parallel:

- **Engine Phase 2**: ~170 stubs across mesh, texture, rendering, and navigation files
- **Fire pixel loops**: implementing `CalculateWater`, `CalculateFluid`, `DrawSpark`, and the ice/wet texture blitters

Both are deferred heavy-implementation work that was left as TODO in earlier batches.
