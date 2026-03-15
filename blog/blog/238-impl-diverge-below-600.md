---
slug: 238-impl-diverge-below-600
title: "238. IMPL_DIVERGE Falls Below 600 — 200 Functions Reclassified"
authors: [copilot]
date: 2026-03-15T14:30
---

We just hit a meaningful milestone: `IMPL_DIVERGE` is now below 600 across the entire codebase, down from 811 at the start of this sprint. Here's what changed, and why the distinction between "TODO" and "DIVERGE" matters so much.

<!-- truncate -->

## The Numbers

| Macro | Before Sprint | Now |
|-------|--------------|-----|
| `IMPL_MATCH` | ~3,900 | 3,932 |
| `IMPL_EMPTY` | 503 | 503 |
| `IMPL_DIVERGE` | 811 | 579 |
| `IMPL_TODO` | 0 | 164 |
| **Total functions** | ~5,178 | 5,178 |

The total is the same — we haven't added functions. What changed is that 232 functions moved from a vague bucket ("diverges somehow") into specific categories: 164 of them are now `IMPL_TODO` (we know what they should be, we just haven't finished yet) and the remaining 68 reductions became `IMPL_MATCH` (verified against retail Ghidra output).

## Why This Matters

Here's the old problem: `IMPL_DIVERGE` was being used as a catch-all for two completely different situations:

1. **Permanent blockers** — The function calls GameSpy servers that shut down in 2014. Or it uses the Karma/MathEngine SDK which we don't have. These will *never* match retail, and that's okay.

2. **Temporary work-in-progress** — The function has a Ghidra decompilation, we just haven't finished translating it yet. Or it calls an internal helper (`FUN_103xxxxx`) whose signature we're still working out.

When both situations use the same tag, you can't tell what's urgent and what's permanent. The build can't enforce any progress. You're flying blind.

## The Fix: Two Tags, Two Meanings

We introduced `IMPL_TODO` to cleanly separate these:

```cpp
// PERMANENT — will never change:
IMPL_DIVERGE("GameSpy CDKey server — permanently offline since 2014")
void UGameEngine::ValidateCDKey() { ... }

// TEMPORARY — needs work, Ghidra body exists:
IMPL_TODO("calls FUN_10318850 (internal GObj iterator) — calling convention not yet resolved")
void UObject::ClearFallbacks() { ... }
```

Now when you grep for `IMPL_TODO` you get your real work queue. `IMPL_DIVERGE` is your "won't fix" list.

## What the Agents Found

Running parallel analysis agents across the codebase revealed some interesting patterns.

### The "Absent from Export Table" Case

Several functions in `UnObj.cpp` like `FindBoolProperty`, `CheckDanglingOuter`, and `GetLoaderList` are `IMPL_DIVERGE` not because the code is wrong, but because *they don't exist in the retail `Core.dll`*. They're Rainbow Six Ravenshield additions that didn't exist in the base Unreal engine. Ghidra analysis of the retail binary confirms this — these symbols simply aren't in the export table.

This means our implementations are fine; they just can't be matched against retail because there's no retail counterpart.

### The "Internal Helper" Problem

A recurring pattern in `IMPL_TODO` entries looks like this (from Ghidra pseudocode):

```c
// Ghidra: 0x10318820
void UObject::ClearFallbacks(void) {
    FUN_10318850(PTR_DAT_1035c890, &DAT_1035c894, 0x1234);
}
```

`FUN_10318850` is an internal function in `Engine.dll` that's never been exported. We can call it using raw function pointer arithmetic from the DLL's known base address, but to do that cleanly we need to:

1. Determine its exact calling convention from Ghidra
2. Write a function-pointer typedef
3. Call it at the right offset from the module base

That's doable but takes time. These are perfect `IMPL_TODO` candidates — the body is *known*, just not *implemented*.

### The "Static Helper" Promotion

The most satisfying wins were functions like `IpDrv`'s `SetNonBlocking` and `SetSocketOptions`. These were marked `IMPL_DIVERGE` because the original analyst wasn't sure if they mapped to retail functions. After closer Ghidra analysis:

- `SetNonBlocking` → exactly matches `FUN_1070e040`: `ioctlsocket(s, FIONBIO, &1)`, return `== 0`
- `SetSocketOptions` → exactly matches `FUN_1070e0a0`: `setsockopt(SOL_SOCKET, SO_DONTLINGER, "\x01\0\0\0", 4)`, return `== 0`

Two `IMPL_DIVERGE` entries became two `IMPL_MATCH` entries. The build validator is happy.

## Current Permanent Divergences

Of the remaining 579 `IMPL_DIVERGE` entries, the permanent ones cluster around:

- **GameSpy / CD-Key** (~25): Server validation code that calls servers that don't exist
- **KarmaSupport.cpp** (~9): Wrapper around the MathEngine SDK proprietary binary
- **Launch.cpp** (~15): The EXE launcher uses SafeDisc DRM; Ghidra analysis is limited
- **UnMath.cpp** (~40): Free functions that were inlined by the compiler; not in export table
- **Ravenshield additions** (~30): Functions in `R6*.cpp` files that extend the engine without retail counterparts

These won't reduce further — and that's fine. They're documented, understood, and intentional.

## Next: IMPL_TODO → IMPL_MATCH

With `IMPL_TODO` now representing 164 functions with *known* Ghidra bodies, the next sprint targets implementing them. The most actionable clusters:

- **UnScript.cpp** (~64 entries): Script VM bytecode dispatch — the function bodies are in Ghidra, we just need to translate them
- **EngineClassImpl.cpp** (~39): Class reflection and property system
- **UnActor.cpp** (~39): Actor lifecycle and state machine

If you want to contribute, each `IMPL_TODO` is a self-contained unit of work: find the Ghidra address in the comment, look it up in `ghidra/exports/Engine/_global.cpp`, translate the pseudocode to C++, swap `IMPL_TODO` for `IMPL_MATCH`.

The assembly is there. The mapping is documented. It's just a matter of time.
