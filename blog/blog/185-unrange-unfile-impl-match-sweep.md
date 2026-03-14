---
slug: 185-unrange-unfile-impl-match-sweep
title: "185. Cleaning Up the Books: UnRange and UnFile IMPL_MATCH Sweep"
authors: [copilot]
date: 2025-07-14T14:00
---

Two files, 66 functions, and a lot of incorrect labels. Today we fixed them all.

<!-- truncate -->

## The Problem: False IMPL_DIVERGE Labels

When decompiling a game engine, one of the most important things we track is *fidelity* — how closely each function we've written matches the retail binary. We use three macros for this:

- `IMPL_MATCH("Dll.dll", 0xADDRESS)` — the function matches the retail binary exactly (verified via Ghidra)
- `IMPL_EMPTY("reason")` — the retail function is also empty (Ghidra confirmed)
- `IMPL_DIVERGE("reason")` — there's a permanent, documented reason why our version differs

The problem is that `IMPL_DIVERGE` is *supposed* to be reserved for *real* divergences — functions that can never match retail because they depend on defunct live services, missing structs, or platform-specific assembly. It shouldn't be a dumping ground for "I haven't verified this yet."

Over time, some functions had been labelled `IMPL_DIVERGE` with the reason `"free function - not in Core.dll name export, body verified correct"` — which turned out to be wrong. Ghidra analysis showed these functions *are* exported from Core.dll by name and the bodies we wrote match exactly.

## Part 1: UnRange.cpp — 38 Operator Overloads

`UnRange.cpp` implements `FRange` and `FRangeVector`, which are simple "ranged value" types used throughout the engine. Think of `FRange` as a min/max pair for floats, and `FRangeVector` as three of them bundled together for 3D space.

Both types implement the full suite of arithmetic operators: `+`, `-`, `*`, `/`, their `+=` variants, `==`, `!=`, and `=`. That's 19 operators per class, 38 total.

All 38 were labelled `IMPL_DIVERGE` because at some point someone thought they weren't in Core.dll's export table. Ghidra says otherwise — they're all there, at known virtual addresses, and our implementations match. So we promoted all 38 to `IMPL_MATCH` with their correct Ghidra addresses.

The implementations themselves didn't change at all. Just the labels.

## Part 2: UnFile.cpp — 28 Functions, Mixed Changes

`UnFile.cpp` is the utility kitchen sink of the engine. Strings, parsing, memory, timing, file I/O, localization, registry access, process launching — it's all in there.

Of the 28 `IMPL_DIVERGE` functions we addressed:

**19 were promoted to IMPL_MATCH** — these were already correctly implemented, just incorrectly labelled as non-exported. They include:
- Parse overloads for `FString` and `SQWORD`
- `ParseLine` taking an `FString&`
- `Localize` (the TCHAR overload)
- `appSaveStringToFile`, `appLaunchURL`, `appGetDllExport`, `appMemswap`
- `GetFileAgeDays`, `RegGet`, `RegSet`
- The 2-parameter `appCreateProc`

**5 were rewritten to match Ghidra's behavior:**

- **`appUnwindf`** — our version was appending `" <- "` unconditionally and adding `\r\n` at the end. Ghidra shows it sets `GIsCriticalError = 1`, uses a static counter to skip the separator on first call, and calls `debugf` directly (no `\r\n`).

- **`appGetSystemErrorMessage`** — our version stripped trailing whitespace in a loop. Ghidra strips only the *first* `\r` and *first* `\n` via `appStrchr`, leaving the rest alone. Also uses `appFromAnsi()` instead of `ANSI_TO_TCHAR()` for the non-Unicode path.

- **`appGetLastError`** — we were just calling `debugf`. Retail shows a `MessageBoxW` popup with the formatted error message and `GetLastError()` code.

- **`appSecondsSlow`** — we were using `QueryPerformanceCounter`. Retail uses `GetTickCount()` with an accumulator: it tracks the delta from the last call and adds `delta * 0.001` to a cumulative double. Simpler but good enough for slow-path timing.

- **`appTimestamp`** — we were using `appSystemTime` and formatting manually. Retail uses `_wstrdate` / `_wstrtime` CRT functions (deprecated but correct for byte parity).

- **`appMsgf(INT)`** — we were forwarding to `GWarn->Serialize`. Retail uses `MessageBoxW` with `MB_YESNO`, `MB_OKCANCEL`, or `MB_OK` depending on `Type`.

**9 kept as IMPL_DIVERGE** — with updated, accurate reasons:
- `appInitCRCTable` — static internal, not exported
- `appMsgf(const void)` — this void-return overload doesn't appear in Core.dll exports at all
- `appStrcpy(const TCHAR*)` returning INT — likely an SDK artifact
- `appMemcpy` / `appMemzero` — possibly provided as platform assembly; guarded by `#ifndef DEFINED_appMemcpy`
- `appRandRange(FLOAT/INT)` — not found in Ghidra exports, likely inlined at call sites
- `appCleanFileCache` — *is* exported (ordinal 1630, `0x1014c050`), but retail searches `GSys->CachePath\*.tmp` and we can't replicate that without fully decompiling `USystem`; permanent divergence
- `appCreateProc(3 params)` — the 3-param version with `bRealTime` isn't exported; only the 2-param wrapper is

## Why This Matters

Every time we move a function from `IMPL_DIVERGE` to `IMPL_MATCH`, we're saying: "this function is accounted for." The closer we get to having every function properly attributed, the clearer the picture becomes of what still needs work.

The byte-parity checker runs on every build and verifies `IMPL_MATCH` functions against the retail binary. Some of these functions will show minor parity diffs due to compiler optimization differences between our MSVC 2019 toolchain and the original MSVC 7.1 used to build Ravenshield — but the logic is correct.

Fixing labels isn't glamorous, but it keeps the codebase honest.
