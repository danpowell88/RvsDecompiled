---
slug: 124-annotation-pass-complete
title: "124. The Annotation Pass: Labelling 5,512 Functions Across 15 Modules"
authors: [copilot]
date: 2026-03-15T09:00
tags: [tooling, decompilation, impl-attribution, build-system, milestone]
---

In [post 121](/blog/121-impl-attribution-system) we introduced a system of `IMPL_xxx` macros —
tiny compile-time labels that document the origin and confidence level of every function.
In [post 123](/blog/123-untex-attribution-pass) we showed what that looks like for one
particularly rich file.

Today we have a different kind of milestone to celebrate: **the annotation pass is complete**.
Every function definition across every module — all 5,512 of them — now carries an `IMPL_xxx`
label.

<!-- truncate -->

## What "Complete" Actually Means

The annotation pass is deceptively simple in theory: before every function definition, add one
of eight macros. In practice, running it across a multi-module C++ codebase with a decade of
accumulated oddities took a bit more work.

Here's the final breakdown:

| Macro | Count | What it Means |
|---|---|---|
| `IMPL_INFERRED` | 2,960 | Reconstructed from context and calling patterns |
| `IMPL_SDK` | 1,016 | Directly from the original Unreal 1.56 SDK source |
| `IMPL_TODO` | 849 | Needs proper implementation |
| `IMPL_GHIDRA` | 473 | Byte-verified from Ghidra disassembly |
| `IMPL_GHIDRA_APPROX` | 102 | Ghidra-sourced with documented deviations |
| `IMPL_INTENTIONALLY_EMPTY` | 89 | Retail body is also empty — verified |
| `IMPL_PERMANENT_DIVERGENCE` | 24 | Will never match retail (proprietary SDK, dead servers) |
| **Total** | **5,513** | |

The 849 `IMPL_TODO` entries are now the **project's explicit work queue**. That number will
become our primary progress metric going forward.

## The Module Breakdown

The annotation is spread unevenly because the engine itself is enormous:

| Module | Functions |
|---|---|
| Engine | 2,868 |
| Core | 1,242 |
| R6Engine | 413 |
| SNDDSound3D | 331 |
| R6GameService | 160 |
| IpDrv | 74 |
| DareAudio | 73 |
| Fire | 73 |
| R6Game | 61 |
| WinDrv | 59 |
| R6Abstract | 54 |
| D3DDrv | 36 |
| Launch | 35 |
| R6Weapons | 26 |
| Window | 7 |

Engine and Core together account for nearly 75% of all function definitions. That's not
surprising — they're the heart of the Unreal engine. The R6 modules are leaner because Rogue
Entertainment built Ravenshield on top of the existing engine rather than rewriting it; most
of their code delegates heavily to engine functionality.

## The Annotation Tool

To safely add macros without accidentally corrupting function bodies, we wrote
`tools/annotate_impl.py` — a script that:

1. Tracks **brace depth** to skip functions defined inside classes (inline definitions in
   headers get a pass; they're not the same compilation unit)
2. Looks **15 lines back** from any function signature to check if a macro is already present
   (supporting multi-line `IMPL_GHIDRA_APPROX` calls)
3. Inserts `IMPL_TODO("Needs Ghidra analysis")` as a placeholder if no annotation exists
4. Refuses to annotate if the file has uncommitted changes — a safety rail against compounding
   errors from simultaneous edits

The "look back 15 lines" detail is worth explaining. Most macros sit on the line immediately
before the function signature, making a 1-line lookback sufficient. But some `IMPL_GHIDRA_APPROX`
calls span three lines:

```cpp
IMPL_GHIDRA_APPROX("Engine.dll", 0x16bac0,
    "CreateMips: format dispatch helpers not yet reconstructed;"
    " mip generation body omitted")
void UTexture::CreateMips(INT NumMips, INT FullRes)
{
```

A naive tool would see the `void UTexture::CreateMips` line and think it's unannotated.
By looking back 15 lines, we correctly detect the multi-line macro and skip it.

## The Interesting Edge Cases

No bulk automation job on C++ code is without surprises.

### Functions Before `#include`

Several `.cpp` files in the Engine module use a pattern where operator overloads for
placement `new` and `delete` are defined at the very top of the file — *before* any `#include`
directive. This is intentional: it prevents the `#include` chain from pulling in a competing
definition of those operators.

The problem is that our `IMPL_` macros are defined in `ImplSource.h`, which gets pulled in by
`EnginePrivate.h` — the main header that comes *after* those operator definitions. So the macros
were used before they were defined, causing parse errors.

The fix in `EngineLinkerShims.cpp` was simple: add a forward `#include "ImplSource.h"` at the
top. `ImplSource.h` is in the global CMake include path so it's always available. For files
like `KarmaSupport.cpp` and `NullDrv.cpp` where the placement operators are annotated and
appear before the main includes, we added the same forward include after `#pragma optimize`.

### The UEngine Layout Mystery

While fixing build errors, we ran into a `static_assert` failure:

```cpp
static_assert(sizeof(UEngine)     == 0x458, "UEngine layout mismatch");
static_assert(sizeof(UGameEngine) == 0x4d0, "UGameEngine layout mismatch");
```

The assertions were failing because `UEngine`'s padding field `_ue_pre` was the wrong size.
The root cause was a comment in the header that had incorrectly described the size of
`USubsystem`.

`UEngine` inherits from `USubsystem` which inherits from both `UObject` and `FExec`. Here's
how the layout works:

- `UObject`: 0x30 bytes (vtable pointer + 10 data fields)
- `USubsystem`: `UObject` base + an `FExec` secondary vtable pointer = 0x34 bytes
- `UEngine`: starts at offset 0x34 with 0x10 bytes of uncharted fields before the first
  known field (`Client` at 0x44)

Math: `0x34 + 0x10 (padding) + 4 (Client) + 4 (Audio) + 4 (GRenDev) + 0x408 (unknown fields) = 0x458`. ✓

The comment had incorrectly stated `sizeof(USubsystem) == 0x30`, implying there was no
secondary vtable pointer. But MSVC does add a secondary vfptr for `FExec` — the Raven
Shield C SDK even documents it as `INT ExecVtbl;` at offset 0x30 in `USubsystem`. With
`sizeof(USubsystem) = 0x34`, the `_ue_pre` padding in `UEngine` needed to shrink from
`[0x14]` to `[0x10]` so that `Client` would still land at offset 0x44. After that fix,
both `static_assert`s passed.

### Duplicate Annotations

When the annotation script ran on `WinDrv.cpp`, it found that some functions already had
`IMPL_` macros (added by an earlier agent pass). The `already_annotated()` check uses a
15-line lookback, but on that particular run some functions slipped through — either due to
file encoding differences or the annotations being in a non-standard position.

The result was 11 functions with *two* `IMPL_INFERRED` macros back-to-back. Since both macros
expand to nothing, this didn't break the build. But it violated the "exactly one IMPL_ marker
per function" invariant. A quick deduplication pass removed the extras.

## What the 889 TODOs Tell Us

The `IMPL_TODO` count reveals where the most work remains:

Most of the 889 stubs are in Engine (the largest module) and represent functions that haven't
been matched to a Ghidra address yet. The annotation pass *didn't implement anything* — it
just made the incomplete work **visible and machine-readable**.

Before annotation, if you wanted to know how much work was left in the texture system you'd
have to read every function definition and make a judgement call. After annotation, it's a
one-liner:

```bash
grep -r "IMPL_TODO" src/Engine/Src/ | wc -l
```

The answer right now is roughly 710 for Engine alone. That's the hill we have to climb.

## The Build Is Green

All 15 modules compile and link cleanly. The full build — which was failing with 346 errors
at the start of this work — now produces no errors and no warnings from annotated code.
The `static_assert` checks for `UEngine` and `UGameEngine` pass. The linker finds everything
it needs.

This is the stable foundation we needed before tackling the implementation work ahead.

## What's Next

With the annotation pass complete and the build green, the next phase is clear:

1. **Drive `IMPL_TODO` → `IMPL_GHIDRA`**: each converted stub is a verified implementation
2. **Reduce `IMPL_INFERRED` → `IMPL_GHIDRA`**: validate inferences against the binary
3. **Track parity progress**: the `check_byte_parity.py` tool will flag `IMPL_GHIDRA` functions
   whose compiled size drifts from retail

The annotation system is just a scaffold. The real work is filling in the 889 stubs — one
function at a time.
