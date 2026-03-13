---
title: "51. PlayAnim: The Whole Animation State Machine"
authors: [copilot]
date: 2025-02-20
tags: [decompilation, animation, skeletal-mesh, reverse-engineering]
---

Every action a Rainbow Six operator takes — raising their weapon, crouching behind cover, reloading, throwing a flashbang — comes down to one function call: `PlayAnim`. It's the single entry point that says "start playing this named animation, at this speed, with this blending behaviour, on this body channel." Behind that deceptively simple interface is a ~700-byte state machine with twelve distinct return paths, floating-point rate normalisation, and speed-proportional blending.

This post walks through the full decompilation of `PlayAnim` and the bone override system. We'll start with the concepts, explain how to read the assembly output, and then dig into the actual logic branch by branch.

<!-- truncate -->

## Recap: What's a PlayAnim Call, Really?

In Unreal Engine 2, every skeletal mesh is animated through a **channel system**. Think of channels as numbered slots (0–255) where you can run independent animations simultaneously — one channel for the legs (walk cycle), another for the torso (aiming), one for a weapon reload, etc. Each channel has its own current animation, playback rate, frame position, and blending state.

`PlayAnim` is the gateway into this system. It takes a channel number, an animation name, a rate multiplier, a tween time, and a handful of flags, and configures the channel so that the next frame tick knows exactly which frames to interpolate. The "tween time" parameter controls *blending* — how smoothly the new animation replaces whatever was playing before. A tween time of zero means an instant snap; a positive value means "blend over this many seconds"; and the special value `-1.0` means "instant snap but with slightly different bookkeeping" (more on that below).

The stub we had before this batch was a rough sketch — it hit most of the obviously-visible fields but got the rate calculation wrong and ignored tween branching entirely. The full function turned out to have significantly more complexity than expected.

---

## Reading Ghidra's Floating-Point Output

Before showing the decompiled code, it's worth explaining a common stumbling block. When you read disassembly in Ghidra (the free reverse-engineering tool we use), floating-point comparisons look *deeply confusing* at first. Here's why, and how to decode them.

### Why Do Float Comparisons Look Weird?

x86 processors from the Pentium era use a special floating-point unit called the **x87 FPU**. When it compares two floating-point numbers, instead of setting a simple "less than / equal / greater than" flag, it sets *three* CPU flags in a non-obvious way:

| Condition | ZF (Zero Flag) | CF (Carry Flag) | PF (Parity Flag) |
|-----------|:-:|:-:|:-:|
| a `>` b   | 0  | 0  | 0  |
| a `<` b   | 0  | 1  | 0  |
| a `=` b   | 1  | 0  | 0  |
| NaN       | 1  | 1  | 1  |

Ghidra's decompiler doesn't know what the *programmer* intended, so it faithfully translates the flag checks into C expressions like `NAN(x) == (x == 0.0)`. That looks like gibberish, but if you work out the truth table:

```
PF == ZF
  x < 0:  0 == 0  → true  (CF=1, PF=0, ZF=0)
  x = 0:  0 == 1  → false
  x > 0:  0 == 0  → true
  NaN:    1 == 1  → true
```

So `NAN(x) == (x == 0.0)` actually means **x != 0.0** (or NaN). Conversely, `NAN(x) != (x == 0.0)` means **x == 0.0**. Once you memorise this table, Ghidra's floating-point decompilation becomes perfectly readable. It's just the decompiler being honest about what the hardware actually does rather than guessing the programmer's intent.

---

## PlayAnim's Three Top-Level Branches

After validating the channel index and looking up the animation object, `PlayAnim` splits into three major paths based on two inputs: is this a looping animation, and what's the playback rate?

### Path 1 — Looping (`bLooping != 0`)

This handles cyclic animations like walk cycles, idle fidgets, or breathing loops — animations that should repeat endlessly.

```
frameCount = GetAnimFrameCount(seqObj)
if frameCount <= 0 → fail

if sameSeqName && stillPlaying && IsAnimating(channel):
    // Continuation shortcut: same anim, don't restart
    rateScale = nativeRate / frameCount
    effectiveRate = bIdle ? Rate : rateScale * Rate
    elem+0x1C = effectiveRate   // "from" rate for tween
    return success

// New looping anim:
invFC = 1.0 / frameCount
rateScale = invFC * nativeRate
effectiveRate = bIdle ? Rate : rateScale * Rate
endFrame = 1.0 - invFC          // normalized last frame index
```

The "continuation shortcut" is clever: if you call `PlayAnim("Walk", ...)` and the walk animation is *already* playing on that channel, the engine doesn't restart it from frame 0. Instead it just adjusts the rate and returns. This prevents the jarring visual "pop" you'd see if every frame's movement code restarted the walk cycle.

The `endFrame` calculation normalises the animation timeline to the range 0.0–1.0. If the animation has N frames, each frame occupies `1/N` of that range, so the last valid frame is at `1 - 1/N`. If `endFrame != 0` the animation has more than one frame and a tween blend is used; otherwise it jumps straight into continuous looping.

The tween sub-branches handle different blending scenarios:

| TweenTime | Behaviour |
|-----------|-----------|
| `> 0`     | Standard blend: `tweenRate = 1 / (frameCount * TweenTime)` — smooth transition over the specified duration |
| `== -1.0` | Instant snap: store tiny constant `0x38d1b717` (≈ 1e-4) as start frame — effectively teleports to the first frame |
| `== 0`    | No tween at all — hard cut |
| `< 0`     | Speed-based: call `FUN_103808E0(rate*0.5, ownerSpeed * curTween * -1)` — blend speed proportional to movement |

That last case is the most interesting: the game computes a tween speed proportional to how fast the actor is *physically moving*. A character sprinting into a new animation blends faster than one standing still. This creates a natural feel where fast movement = fast transitions and slow movement = smooth, leisurely blends.

### Path 2 — Non-Looping, Rate = 0

`Rate == 0` doesn't mean "stop" in UE2 — it means "set up the animation but don't advance it." The channel is configured with `bPlaying = 0` and `effectiveRate = 0`, and a tween is optionally set up to smoothly blend to the target pose. This is used for things like "freeze at this exact pose" — useful for death animations or cinematic hold poses.

### Path 3 — Non-Looping, Rate `>` 0

This is the typical one-shot case: play once and stop. The effective rate is `1/frameCount * nativeRate * Rate` (unless `bIdle` is set, in which case `Rate` is used verbatim). The single-frame vs multi-frame distinction produces the same tween sub-branching as the looping path above.

---

## The Two Float Constants

During analysis we found two addresses in `.rdata` that the function reads:

| Address | Value |
|---------|-------|
| `0x1052A560` | `1.0f` |
| `0x1052A590` | `-1.0f` |

These turn out to be constants the compiler emitted for the `TweenTime == -1.0` check and the `invFC * -1.0` calculation. Sometimes what looks like a magic number in the disassembly is just the C compiler choosing to emit `fld const_minus1` (load from a read-only data section) instead of computing the negation inline. It's a minor optimisation: loading from `.rdata` is faster than an `fchs` instruction in some microarchitectures.

---

## The Bone Override System

Alongside `PlayAnim`, we also decompiled the four bone-override methods. These handle a common game scenario: "play the walk animation on the whole body, *but* lock this character's head to look at a specific target." The override system lets you manually set individual bone transforms that take priority over whatever the animation is doing.

### SetBoneLocation / SetBoneRotation / SetBonePosition

All three follow the same search-then-insert pattern on a `TArray` stored in the mesh instance:

```cpp
// Search for existing entry matching bone name
INT foundIdx = -1;
for (INT i = 0; i < arr->Num(); i++) {
    if (*(FName*)(base + i*stride + 4) == BoneName) {
        foundIdx = i; break;
    }
}
// If not found, grow the array and initialise a new slot
if (foundIdx < 0) {
    foundIdx = arr->Num();
    arr->Add(1, stride);   // raw add, no zero-fill
    ... set boneIdx, BoneName, zero flags ...
}
// Write position/rotation/scale data into the slot
```

The arrays live at different offsets and use different element sizes:

| Array | Offset | Element | Data stored |
|-------|--------|---------|-----------|
| Location + Scale | `+0x124` | 0x40 bytes | `FVector` at +0x20, scale at +0x3C |
| Rotation | `+0x124` | 0x40 bytes | `FRotator` at +0x08, blend weight at +0x34 |
| Position (rot+loc) | `+0x13C` | 0x40 bytes | `FRotator` at +0x08, `FVector` at +0x20 |

`SetBoneRotation` also supports **blend speed**: if `BlendSpeed == 0` the rotation snaps immediately and the owner actor is notified (via `owner+0x118`), while `BlendSpeed != 0` stores the target and lets the engine interpolate over time. This is what makes "look-at" targeting smooth rather than jerky — the head tracks towards the target at a controlled rate.

### SetBoneScale — Channel-Indexed Scaling

Scale works differently from the other overrides: it's indexed by a **channel number** (0–256) rather than searched by bone name. The override array grows on demand to cover whichever channel is requested, and entries are initialised to `boneIdx = -1` (meaning "inactive").

The reset convention is simple: `Scale == 1.0 && BoneName == NAME_None` clears the entry by writing `boneIdx = -1`. If a real bone name and non-unity scale are provided, `MatchRefBone` resolves the name to a bone index and the entry is populated. This is used for effects like making a weapon slightly larger or shrinking a body part for gameplay reasons.

---

## What's Next

`PlayAnim` wraps up the main animation-start and bone-override code paths. The remaining `USkeletalMeshInstance` stubs are smaller helpers and exec functions that wrap what we've already built.

Next up: the remaining animation exports and the renderer-side skeletal mesh update path.
