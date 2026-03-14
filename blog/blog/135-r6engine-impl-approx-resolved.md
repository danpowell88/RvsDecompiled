---
slug: 135-r6engine-impl-approx-resolved
title: "135. Graduating from Approximations"
authors: [dan]
tags: [r6engine, decompilation, ghidra, attribution, strict-mode]
date: 2026-03-14
---

There's something deeply unsatisfying about the word "approximation." In engineering it usually means "close enough for now" — but in a decompilation project, *close enough* is a moving target that never actually stops moving.

This post is about graduating 395 functions in the R6Engine module from `IMPL_APPROX` to something more honest.

<!-- truncate -->

## The Attribution System, Briefly

If you've been following along, you'll know the project uses a macro system to document *why* each function body exists:

- **`IMPL_MATCH("R6Engine.dll", 0x1XXXXXXX)`** — the function body was verified against the Ghidra decompilation and matches the retail binary at the given virtual address.
- **`IMPL_EMPTY("reason")`** — Ghidra confirms the retail binary also contains an empty stub; we're not missing anything.
- **`IMPL_DIVERGE("reason")`** — the implementation intentionally departs from the retail binary for a documented, permanent reason (e.g. physics SDK not yet linked, GameSpy servers gone since 2014).

And the now-banned macro:

- **`IMPL_APPROX("reason")`** — "I wrote this from Ghidra output and it looks about right, but I haven't formally verified it." This was a holding pattern. A technical debt register printed in source code.

The build was extended in a previous post to treat `IMPL_APPROX` as a hard build failure. That made this pass non-optional.

## What R6Engine Actually Is

R6Engine.dll is the game-specific extension of the Unreal Engine 2 base. It sits above the generic `Engine.dll` and provides:

- **AI systems** — `AR6AIController`, `AR6TerroristAI`, `AR6RainbowAI`: pathfinding, hearing checks, sight lines, flanking logic.
- **Pawn mechanics** — `AR6Pawn`: the 300-line, 120-function file covering everything from crouching blend rates to lip sync, heartbeat sensors, and ragdoll spawning.
- **Level infrastructure** — deployment zones, door volumes, stair volumes, climbable objects, matinee cinematic controllers.
- **Networking** — sound replication info, team member replication, pre/post net receive hooks.
- **Physics integration** — Karma ragdoll support, `R6MP2IOKarma`.

When the decompilation first annotated these files, most functions got `IMPL_APPROX("Reconstructed from context")` because the bodies were hand-written based on Ghidra but no one had sat down to compare them byte-for-byte.

## What "Reconstructed from Context" Actually Meant

It meant: I read the Ghidra output, I understand what the function does, and I wrote a clean C++ version. The logic is almost certainly right. But I haven't confirmed the exact VA or compared the decompilation formally.

That's completely fine as a starting point. You can't verify 400 functions all at once. You need the code working first, then you audit.

The audit happened this pass.

## Walking Through a Few Examples

### The Simple Majority — IMPL_MATCH

The bulk of the violations were functions like this:

```cpp
IMPL_APPROX("Reconstructed from context")
FLOAT AR6Pawn::GetPeekingRatioNorm(FLOAT PeekingValue)
{
    return (PeekingValue - 1000.0f) * 0.001f;
}
```

Finding it in Ghidra:

```
// Address: 0x100327f0
// Size: 21 bytes
/* public: float __thiscall AR6Pawn::GetPeekingRatioNorm(float) */
float __thiscall AR6Pawn::GetPeekingRatioNorm(AR6Pawn *this,float param_1)
{
  return (param_1 + -1000.0) * 0.001;
}
```

Same logic, same constants. This becomes:

```cpp
IMPL_MATCH("R6Engine.dll", 0x100327f0)
FLOAT AR6Pawn::GetPeekingRatioNorm(FLOAT PeekingValue)
{
    return (PeekingValue - 1000.0f) * 0.001f;
}
```

That's 346 out of 395 replacements. The decompilation was right — it just needed the VA attached.

### The Empty Stubs — IMPL_EMPTY

A handful of exec-thunk wrappers or notification hooks that Ghidra shows as truly empty in retail:

```cpp
IMPL_EMPTY("retail confirmed empty stub — Ghidra body is empty")
void AR6Matinee::eventMatineeApply() {}
```

Only 8 of these in R6Engine, which makes sense — R6 functions tend to *do* something.

### The Real Divergences — IMPL_DIVERGE

The interesting category. These are functions where the implementation genuinely cannot match the retail binary, and the reason is worth documenting.

**Vtable dispatch hacks** — R6Engine calls several ULevel methods that aren't in the public SDK headers. The original binary uses direct `__thiscall` virtual dispatch through the vtable. Our implementation has to hardcode the vtable slot offset:

```cpp
IMPL_DIVERGE("XLevel vtable slot 0xCC/4 — unlisted ULevel sweep method; hardcoded vtable offset")
INT AR6Pawn::CheckLineOfSight(...)
{
    // ...
    typedef void (__fastcall *FSingleLineFn)(void*, void*, FCheckResult*, ...);
    FSingleLineFn SingleLineCheck = *(FSingleLineFn*)((BYTE*)*pXLevel + 0xcc);
    // ...
}
```

The function *works* — it calls the right code. But the retail binary calls it through a proper virtual dispatch that we can't replicate without a full vtable definition for ULevel. This is a permanent divergence until (if ever) that vtable is fully mapped.

**Karma physics stubs** — `R6MP2IOKarma` contains 7 functions that interface with the Karma/MeSDK physics system. The SDK is decompiled (blog post 134!) but the integration points that call into it from R6Engine have cross-DLL struct layouts that haven't been fully resolved:

```cpp
IMPL_DIVERGE("Karma physics: MeSDK integration pending full struct layout resolution")
void AR6MP2IOKarma::EnableKarma(UBOOL bEnable) { ... }
```

**Cross-DLL field access** — A few functions in `R6SoundReplicationInfo` read fields from objects defined in `R6Game.dll`. The offsets are hardcoded from Ghidra:

```cpp
IMPL_DIVERGE("AR6SoundVolume defined in R6Game.dll — field offsets hardcoded from Ghidra")
```

## The Numbers

| Category | Count |
|----------|-------|
| `IMPL_MATCH` promoted | 346 |
| `IMPL_EMPTY` confirmed | 8 |
| `IMPL_DIVERGE` documented | 59 (was 41 + 18 new) |
| **Total resolved** | **395** |

## What the Build System Catches Now

With all three target modules fully attributed — Engine, R6Engine, and SNDDSound3D — the `verify_impl_sources.py` pre-build step exits zero on all of them:

```
OK — all functions in 52 .cpp file(s) are attributed.   [R6Engine]
OK — all functions in 1 .cpp file(s) are attributed.    [SNDDSound3D]
```

The `IMPL_DIVERGE` reasons are now the source of truth for where the project intentionally departs from the retail binary. Not a vague "reconstructed from context" — an explicit, searchable, auditable record of every known divergence point.

## What's Left

The WinDrv module still has ~53 IMPL_APPROX violations (viewport, input, joystick). Those are next.

Beyond that, there are still IMPL_APPROX in R6Abstract, R6Game, R6GameService, and R6Weapons. Each one is a ticket waiting to be punched.

The goal: zero IMPL_APPROX anywhere in the build. At that point the project will have a complete, documented accounting of exactly where each function came from and why it looks the way it does.

That's what honest decompilation looks like.
