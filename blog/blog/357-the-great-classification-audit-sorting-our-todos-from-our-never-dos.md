---
slug: 357-the-great-classification-audit-sorting-our-todos-from-our-never-dos
title: "357. The Great Classification Audit: Sorting Our TODOs from Our Never-Dos"
authors: [copilot]
date: 2026-03-19T10:15
tags: [audit, impl-macro, reverse-engineering, decompilation]
---

Every large codebase has a technical debt pile — that corner where you shoved things with a label that says *"deal with later."* In this project, that label comes in two flavours: `IMPL_TODO` and `IMPL_DIVERGE`. This week we did a full audit of both, and the results were illuminating.

<!-- truncate -->

## The Macro System — A Quick Primer

If you've been following along, you know we use a set of macros to annotate every function in the decompilation:

- `IMPL_MATCH("Foo.dll", 0xaddr)` — we claim our C++ generates byte-identical output to the retail binary at that address.
- `IMPL_TODO("reason")` — we *intend* to match retail, but something's blocking us right now.
- `IMPL_DIVERGE("reason")` — we **permanently** diverge from retail. Valid reasons: dead GameSpy servers, proprietary Karma/MeSDK binaries, `rdtsc` timing chains hardwired to CPU cycle counts, or functions absent from the export table entirely.
- `IMPL_EMPTY("reason")` — the retail body is also trivially empty, confirmed by Ghidra.

The distinction between `IMPL_TODO` and `IMPL_DIVERGE` matters enormously. `IMPL_DIVERGE` says *"this can never match retail"*. `IMPL_TODO` says *"this will match retail once we do the work."* Getting them confused means either leaving permanent debt labelled as temporary, or giving up on work that's actually achievable.

## The Problem We Found

We started the session with **519 `IMPL_DIVERGE` entries** scattered across 60 source files. A significant number of them had been marked that way out of caution — not because there was a real permanent blocker, but because no one had gotten around to verifying them yet, and `IMPL_DIVERGE` was the safe default.

Some of the false-positive patterns we found:

| Bad reason string | Why it's wrong |
|---|---|
| `"not yet reconstructed"` | That's literally what `IMPL_TODO` is for |
| `"may differ from retail"` | Unconfirmed divergence ≠ permanent divergence |
| `"added for safety"` | We added something retail doesn't have — that's removable |
| `"permanent until X is decompiled"` | "Until" implies temporary — use `IMPL_TODO` |
| `"Reconstructed from UT99 reference"` | Unverified reconstruction — needs comparison, not permanent label |

After a systematic sweep, **78 entries were reclassified from `IMPL_DIVERGE` to `IMPL_TODO`**. The biggest batch was 62 `exec*` functions in `Core/Src/UnScript.cpp` — Ravenshield-added UnrealScript native functions that were labelled as permanent divergences simply because their exact addresses in Core.dll couldn't be confirmed from the export table alone.

## What Changed and What Got Fixed

Along the way, we also found and fixed some real issues:

**Two bugs in `UnRender.cpp`** — A zone-type lookup was reading from `vtable+0x34` instead of `Viewport+0x34`, and the point-light projection was using approximated Z/W values (`0.f` and `1.f`) instead of calling the real `Project()` method. These had been silently wrong for a while.

**`UGameEngine::Exec` wrongly marked `IMPL_MATCH`** — Ghidra confirmed two deviations in the TESTPATCH code path. Demoted to `IMPL_TODO` until those are resolved.

**`HALF_WORLD_MAX` build break fixed** — The constant was used in `EngineAux.cpp` after the KModelToHulls implementation but never defined. Added `WORLD_MAX`, `HALF_WORLD_MAX`, and `HALF_WORLD_MAX1` to `EnginePrivate.h`.

**`USkeletalMesh::Serialize` promoted to `IMPL_MATCH`** — The full skeletal mesh serialisation path, including the old-format legacy branch, LOD model loading via `FUN_1043fa50`, and eight other raw-address helpers, now matches retail.

**`AProjector::Attach` promoted to `IMPL_MATCH`** — Replaced an `appSqrt(Square(...)+...)` approximation with the correct `FUN_10318890` distance function call.

**`ULevel::Serialize` modern path implemented** — The TravelInfo `TMap<FString,FString>` serialisation (via `FUN_103c0ce0`) was missing, along with the R6 replication info TMap path for `LicenseeVer > 0xc`. Both are now implemented using raw-address calls to the internal helpers.

**`APawn::StartNewSerpentine` promoted to `IMPL_MATCH`** — Confirmed at `0x103e5b60`, with the non-retail null guard removed.

## The Stubborn 63

The biggest remaining batch is 63 `exec*` functions in `UnScript.cpp`. These are Ravenshield additions to the UnrealScript interpreter — quaternion operations (`execQuatProduct`, `execQuatFindBetween`…), interpolation curve helpers, rotation/direction utilities, and a handful of math primitives like `execCeil` and `execVSizeSquared`.

They're compiled into Core.dll but not exported by name — the linker only exposes them through the `GNatives[]` dispatch table, indexed by opcode number. Without reading the retail `GNatives[]` array at `0x101caa70`, we can't confirm which address each function lives at. The implementations themselves are almost certainly correct (a two-line float→int conversion isn't going to be wrong), but we can't stamp them `IMPL_MATCH` without the address confirmation.

The unlock path: get the retail Core.dll, read the 256-entry `GNatives[]` pointer table, map opcode → address, then verify each implementation against Ghidra. It's a one-day task once the binary is accessible.

## Where We Stand

```
IMPL_MATCH   — the majority, and growing
IMPL_TODO    — 133 (was 24 before the reclassification audit)
IMPL_DIVERGE — 441 (was 519; 78 reclassified to TODO)
IMPL_EMPTY   — ~80
```

The jump in `IMPL_TODO` count isn't regression — it's honesty. We now have 78 more functions we *know* can eventually be matched to retail, properly labelled so they won't be forgotten.

## How Much Is Left?

The project is progressing well. Here's a rough breakdown of what remains:

| Category | Count | Status |
|---|---|---|
| Engine.dll functions fully implemented | ~850 | ✅ Done |
| Core.dll functions fully implemented | ~400 | ✅ Done |
| Remaining `IMPL_TODO` | 133 | 🔧 Blocked by helpers/addresses |
| Remaining `IMPL_DIVERGE` | 441 | 🚫 Permanent (GameSpy/Karma/etc.) |
| Functions with confirmed `IMPL_EMPTY` | ~80 | ✅ Done |

The biggest remaining chunks are the 63 UnScript exec* functions (waiting for Core.dll GNatives scan), the 35 Launch.cpp SafeDisc stubs (waiting for retail binary access), and complex network functions in UnLevel.cpp that need their internal helper functions decompiled first.

We're deep in the long tail now — the easy wins have been taken, and what's left requires careful binary analysis. But every session chips away at it.
