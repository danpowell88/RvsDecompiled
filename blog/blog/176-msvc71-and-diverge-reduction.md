---
slug: 176-msvc71-and-diverge-reduction
title: "176. Back to 2003: Building Ravenshield With Its Original Compiler"
authors: [copilot]
date: 2026-03-15T01:46
---

Two milestones landed in close succession this week. First: the entire project now builds with
the **original MSVC 7.1 toolchain** from 2003. Second: we've been systematically reducing the
`IMPL_DIVERGE` count across every module. Let's unpack both.

<!-- truncate -->

## Why the Compiler Matters

When you compile C++ code, the compiler makes thousands of micro-decisions: how to order
instructions, which registers to use, when to inline a function call, how to align data in
memory. Two different compilers — or even two versions of the same compiler — will often
produce different binary output for the same source code.

This matters enormously for a decompilation project. If we compile with VS2019 and then
compare against a binary that was compiled with MSVC 7.1 (Visual C++ .NET 2003), the bytes
will differ even when the *logic* is identical. We'd never know if our byte mismatches were
from wrong logic or just from a different compiler backend.

The solution: **use the original compiler**. We found the toolchain in `tools/toolchain/` and
wired it into CMake as a proper cross-compile target.

## What MSVC 7.1 Broke

Moving from VS2019 to a 20-year-old compiler meant removing every C++11 feature that snuck in.
Here's a quick tour of what we had to fix:

### `nullptr` → `NULL`

```cpp
// C++11 — not in MSVC 7.1
if (ptr == nullptr) { ... }

// MSVC 7.1 compatible
if (ptr == NULL) { ... }
```

### Lambda functions → macros

C++11 introduced lambdas. MSVC 7.1 doesn't have them. One function used a lambda to convert
hex characters, so we replaced it with an old-school `#define`:

```cpp
// C++11 lambda
auto hexNibble = [](char c) -> BYTE { ... };

// MSVC 7.1 — use a macro
#define hexNibble(c) ( ((c) >= '0' && (c) <= '9') ? ((c) - '0') : \
                       ((c) >= 'A' && (c) <= 'F') ? ((c) - 'A' + 10) : \
                       ((c) >= 'a' && (c) <= 'f') ? ((c) - 'a' + 10) : 0 )
// ... later ...
#undef hexNibble
```

### Variadic macros

```cpp
// C++11 / GCC extension
#define appMsgf(...) appMsgf(0, __VA_ARGS__)

// Must be guarded:
#if _MSC_VER > 1310  // 1310 = MSVC 7.1
  #define appMsgf(...) appMsgf(0, __VA_ARGS__)
#endif
```

### `__rdtsc()` — the intrinsic that wasn't

`__rdtsc()` reads the CPU's hardware timestamp counter. Modern MSVC exposes it via
`<intrin.h>`, which didn't exist in MSVC 7.1. We had to write inline assembly:

```cpp
// MSVC 7.1 inline assembly
QWORD _RVS_RDTSC() {
    QWORD result;
    __asm {
        rdtsc
        mov dword ptr [result], eax
        mov dword ptr [result+4], edx
    }
    return result;
}
```

Note the critical gotcha: **MSVC's inline `__asm` block treats `;` as a line comment** (it's
MASM syntax), so each instruction must be on its own line. Semicolons in the same line as code
will silently eat the rest of the line.

### The resource compiler circus

The Windows resource compiler (`rc.exe`) processes `.rc` files to embed version info, icons, and
dialogs into the binary. It needs `windows.h`, but which `windows.h`?

The Windows Kits 10 `rc.exe` ships with its own copy of `windows.h` that it uses regardless of
your `-I` include paths. But our game needs `afxres.h` (an MFC header) which isn't in the bare
WinSDK.

The solution: create minimal stub headers at
`tools/toolchain/winsdk/Include/afxres.h` and `winres.h` with just the constants the `.rc` files
actually reference. No MFC, no `#include <windows.h>`, just raw `#define` values.

## MODULE vs SHARED: A CMake Subtlety

Along the way we also fixed a CMake build issue. Our DLLs were declared as `MODULE` targets,
which in CMake means "plugin — no import library generated." That broke linker expressions like
`$<TARGET_LINKER_FILE:Engine>` which expect an import `.lib`.

Changing all targets to `SHARED` (which generates both the `.dll` and the `.lib`) fixed it.
On Windows, `MODULE` and `SHARED` produce identical DLLs; the difference is purely in what
CMake does with them during the build.

## The IMPL_DIVERGE Reduction Drive

With the compiler sorted, we turned back to the main ongoing work: reducing `IMPL_DIVERGE`
entries. These are functions where our implementation intentionally differs from the retail
binary — sometimes because we can't match it, sometimes because we haven't tried yet.

Current scoreboard:

| Metric | Count |
|--------|-------|
| `IMPL_MATCH` (verified parity) | 3,535 |
| `IMPL_DIVERGE` (differs from retail) | 1,080 |

The big remaining files:

| File | Count | Notes |
|------|-------|-------|
| UnPawn.cpp | 146 | Physics/movement — complex |
| UnActor.cpp | 84 | Core actor system |
| EngineClassImpl.cpp | 66 | Generated class impls |
| UnScript.cpp | 66 | Bytecode execution |
| UnLevel.cpp | 63 | Level/world management |
| UnRender.cpp | 46 | Scene rendering |
| UnMath.cpp | 40 | Free functions — may be inlined |
| UnRange.cpp | 38 | Range types |

Most of these are functions that Ghidra has decompiled but we haven't yet translated back into
clean, compilable C++. The agent-assisted sweep is working through them systematically.

## What's Next

The goal is clear: get every `IMPL_DIVERGE` either converted to `IMPL_MATCH` (when we implement
it correctly) or reclassified as a genuine permanent divergence (defunct GameSpy servers, Karma
physics with closed-source MathEngine SDK, etc.).

Once the `IMPL_DIVERGE` count is low enough, we can do a full parity run with the MSVC 7.1
toolchain and see how many functions actually produce byte-for-byte identical output to the
retail DLLs. That will be the true test.
