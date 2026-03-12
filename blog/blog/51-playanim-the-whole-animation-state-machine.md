---
title: "51. PlayAnim: The Whole Animation State Machine"
authors: [dan]
tags: [decompilation, animation, skeletal-mesh, reverse-engineering]
---

If you've ever wondered what happens when a game character starts playing an
animation — not just "play this clip" but the full logic of rate-scaling,
tween blending, looping, and speed-based interpolation — Batch 173 has the
answer.  We just finished a complete faithful decompilation of
`USkeletalMeshInstance::PlayAnim` and five bone-override functions.

<!-- truncate -->

## Recap: What's a PlayAnim Call, Really?

In Unreal Engine 2, every skeletal mesh is animated through a *channel system*.
Think of channels as numbered slots (0-255) where you can run independent
animations simultaneously — one channel for the legs, another for the torso,
one for a held weapon reload, etc.  `PlayAnim` is the gateway: it takes a
channel number, an animation name, a rate multiplier, a tween time, and a
handful of flags, and sets everything up so the next tick knows exactly which
frames to interpolate.

The stub we had before this batch was a rough sketch — it hit most of the
obviously-visible fields but got the rate calculation wrong and ignored tween
branching entirely.  The full function is about 700 bytes in the retail binary
and has at least twelve distinct return paths.

---

## Reading the Ghidra Decompilation

Before showing code, some context on how Ghidra represents x87 floating-point
comparisons.

x87 uses the `FCOMIP` instruction to compare two floats and set CPU flags:

| Condition | ZF | CF | PF |
|-----------|----|----|-----|
| a `>` b   | 0  | 0  | 0  |
| a `<` b   | 0  | 1  | 0  |
| a `=` b   | 1  | 0  | 0  |
| NaN       | 1  | 1  | 1  |

Ghidra doesn't know the intent, so it writes comparisons like
`NAN(x) == (x == 0.0)`, where `NAN(x)` maps to the parity flag (PF) and
`(x == 0.0)` maps to the zero flag (ZF).  Working out the truth table:

```
PF == ZF
  x < 0:  0 == 0  → true  (CF=1, PF=0, ZF=0)
  x = 0:  0 == 1  → false
  x > 0:  0 == 0  → true
  NaN:    1 == 1  → true
```

So `NAN(x) == (x == 0.0)` means **x != 0.0** (or NaN).  Conversely
`NAN(x) != (x == 0.0)` means **x == 0.0**.  Once you know this table the
Ghidra C starts making sense.

---

## PlayAnim's Three Top-Level Branches

After validating the channel and looking up the animation object, PlayAnim
splits into three major paths based on `bLooping` and `Rate`:

### Path 1 — Looping (`bLooping != 0`)

This handles cyclic animations like walk cycles or idle fidgets.

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

The `endFrame` value is interesting.  If the animation has N frames,
`1/frameCount` is the size of one frame in normalised time (0..1).  So
`1 - 1/frameCount` is the last valid frame.  If `endFrame != 0` the animation
has more than one frame and the looping path uses a single-shot tween to get
there; otherwise it jumps straight into continuous looping.

The tween sub-branches deserve their own note:

| TweenTime | Behaviour |
|-----------|-----------|
| `> 0`     | Standard blend: `tweenRate = 1 / (frameCount * TweenTime)` |
| `== -1.0` | Instant snap: store tiny constant `0x38d1b717` (≈ 1e-4) as start frame |
| `== 0`    | No tween at all |
| `< 0`     | Speed-based: call `FUN_103808E0(rate*0.5, ownerSpeed * curTween * -1)` |

That last case is the most interesting — the game computes a tween speed
proportional to how fast the actor is moving, so a character sprinting into a
new animation blends faster than one standing still.

### Path 2 — Non-Looping, Rate = 0

`Rate == 0` doesn't mean "stop"; in UE2 it means "play at the animation's own
native rate without any scale factor applied."  The channel is set up with
`bPlaying = 0` and `effectiveRate = 0`, and a tween is optionally set up to
smooth the hold at the end frame.

### Path 3 — Non-Looping, Rate `>` 0

This is the typical shot-once case.  The effective rate is
`1/frameCount * nativeRate * Rate` (unless `bIdle` is set, in which case `Rate`
is used verbatim).  The single-frame / multi-frame distinction produces the
same tween sub-branching as the looping path above.

---

## The Two Float Constants

During analysis we found two addresses in `.rdata` that the function reads:

| Address | Value |
|---------|-------|
| `0x1052A560` | `1.0f` |
| `0x1052A590` | `-1.0f` |

These turn out to be the sentinel values `1.0` and `-1.0` stored as read-only
constants.  The TweenTime `== -1.0` branch checks against `0x1052A590`, and
the "invFC * -1.0" start frame calculation reads `0x1052A560`.  Sometimes code
that looks like a magic number is just a C compiler emitting `fld const_minus1`
instead of computing the negation inline.

---

## The Bone Override System

Alongside PlayAnim we also decompiled the four bone-override methods.  These
handle cases like: "lock this character's head bone to look at a target
regardless of what the body animation is doing."

### SetBoneLocation / SetBoneRotation / SetBonePosition

All three follow the same search-then-insert pattern on a `TArray` stored in
the mesh instance:

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

| Array | Offset | Element | Bone data |
|-------|--------|---------|-----------|
| Location + Scale | `+0x124` | 0x40 bytes | `FVector` at +0x20, scale at +0x3C |
| Rotation | `+0x124` | 0x40 bytes | `FRotator` at +0x08, blend at +0x34 |
| Position (rot+loc) | `+0x13C` | 0x40 bytes | `FRotator` at +0x08, `FVector` at +0x20 |

`SetBoneRotation` also has blend-speed logic: if `BlendSpeed == 0` it snaps
immediately and notifies the owner AActor via `owner+0x118`, while
`BlendSpeed != 0` stores the target blend and the engine interpolates over time.

### SetBoneScale

Scale is different: it's indexed by a *channel number* (0-256) rather than
searched by name.  The array grows on demand to cover whichever channel is
requested, and entries are initialised to `boneIdx = -1` (inactive).

The scale reset convention is `Scale == 1.0 && BoneName == NAME_None`, which
writes `boneIdx = -1` to clear the entry.  If `Scale != 1.0` and a real bone
name is given, `MatchRefBone` looks up the bone index in the skeleton and the
entry is populated.

---

## What's Next

Batch 173 wraps up the main animation-start and bone-override code paths.
The remaining `USkeletalMeshInstance` stubs are smaller helpers or exec
functions that wrap what we've already built.

Next up: working through the remaining animation exports and then tackling the
renderer-side skeletal mesh update path.
