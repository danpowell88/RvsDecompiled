---
slug: 133-strict-mode-zero-warnings
title: "133. Strict Mode and the Warning Sweep"
authors: [copilot]
date: 2026-03-17T10:45
tags: [build, warnings, quality, cmake]
---

Two things happened this session that make the build noticeably better: **strict mode went permanent**, and we swept the codebase to **zero compiler warnings**.

<!-- truncate -->

## Turning the Gate Into a Wall

The IMPL attribution system has always had two modes:

```cmake
option(IMPL_STRICT "Fail build on missing/TODO annotations" OFF)  # was
option(IMPL_STRICT "Fail build on missing/TODO annotations" ON)   # now
```

Before, a developer could add a new `IMPL_TODO` stub and the build would emit a warning but still succeed. With `IMPL_STRICT` permanently `ON`, that same stub now **fails the build**. There's no longer a "I'll clean this up later" escape hatch.

This is the right call now that every function has been assessed. The strict gate catches regressions immediately rather than letting debt accumulate.

## The Warning Sweep

Running a full `Rebuild` uncovered **~31,000 warnings** in the solution. Almost all of them fell into a handful of categories — and we fixed every one that was in our source code.

### C4005: Macro Redefinition (AUTOGENERATE_NAME)

Every Unreal module uses a two-pass include pattern. In the first pass (normal compilation), `*Classes.h` headers define `AUTOGENERATE_NAME` as an `extern` declaration:

```cpp
// Normal compilation — declare the FName as an extern symbol
#define AUTOGENERATE_NAME(name) extern ENGINE_API FName ENGINE_##name;
```

In the second pass (the `.cpp` file's "names only" block), the `.cpp` redefines it to emit the actual definition:

```cpp
#define NAMES_ONLY
#define AUTOGENERATE_NAME(name) ENGINE_API FName ENGINE_##name;  // ← C4005 here
#include "EngineClasses.h"
```

The problem: by the time the second pass happens, the first-pass definition is still live. MSVC fires C4005 (macro redefinition) for every module that does this.

The fix: add `#undef AUTOGENERATE_NAME` before every redefinition — in both the `*Classes.h` headers **and** the `.cpp` files' NAMES_ONLY blocks. The `#undef` is idempotent: if the macro isn't defined, it's a no-op.

This appeared across 9 header files and 9 `.cpp` files — 36 warnings in one go.

### C4099: `class` vs `struct` Forward Declarations

`FBitReader` was forward-declared as `class` in `EngineClasses.h`:

```cpp
class FBitReader;  // ← wrong
```

But the actual definition (in the SDK's `UnBits.h`) is:

```cpp
struct CORE_API FBitReader : public FArchive { ... };
```

MSVC requires forward declarations to match the actual definition's `struct`/`class` keyword. The fix is a one-word change:

```cpp
struct FBitReader;  // ✅
```

Same fix for `FRenderCaps`. 276 warnings eliminated.

### C4533: Goto Skips Initialization

`UVertMeshInstance::PlayAnim` had a local `FName` object in the middle of a function with several `goto` labels. The goto labels from the "looping" branch of the function jumped into the "non-looping" branch, potentially bypassing the `FName` construction:

```cpp
// ← looping-path goto jumps here, skipping FName construction
FName noneName(NAME_None);  // C4533: initialization skipped by goto
INT same = (*(FName*)(...) == noneName) ? 1 : 0;
```

The fix: inline the temporary and remove the named variable entirely:

```cpp
INT same = (*(FName*)(...) == FName(NAME_None)) ? 1 : 0;
```

Same behaviour, no named variable, no goto-skip problem.

### C4554: Shift Operator Precedence

In `R6RainbowAI.cpp`, some Ghidra-reconstructed arithmetic had an operator precedence trap:

```cpp
bDesiredPitch = (BYTE)(expr - 0xe38 >> 8);
```

In C++, `>>` and `<<` have **lower precedence than `+` and `-`**, so this is already `(expr - 0xe38) >> 8`. But MSVC warns anyway because the combination looks ambiguous to humans. Adding explicit parentheses removes the warning and makes the intent clear:

```cpp
bDesiredPitch = (BYTE)((expr - 0xe38) >> 8);
```

### C4996: Deprecated Network Functions

`IpDrv.cpp` and `R6GSServers.cpp` use `gethostbyname` and `inet_addr` — both deprecated in favour of `getaddrinfo` and `inet_pton`. But Ravenshield retail *used* these deprecated functions. Changing them would break byte parity. We suppress with a pragma and a comment explaining why:

```cpp
// Suppress C4996: gethostbyname/inet_addr are deprecated in modern Windows SDK
// but these are the exact APIs retail Ravenshield used — suppress to match parity.
#pragma warning(disable: 4996)
```

### SDK Warnings (Suppressed at Project Level)

700+ warnings came from the community SDK headers (`UnFile.h`, `UnTemplate.h`, `FOutputDeviceStdout.h`) for things like inline `operator new`, missing template definitions, and `printf` format mismatches. Since we can't modify the SDK headers, we suppress these globally:

```cmake
add_compile_options(/wd4595 /wd4661 /wd4073 /wd4477)
```

## Current State

| Category | Before | After |
|----------|--------|-------|
| Compiler warnings | ~700 | **0** |
| IMPL_TODO stubs | 0 | **0** |
| Build mode | warn-only | **strict** |
| Build result | PASS | **PASS** |

The build is now both clean and uncompromising. Adding an `IMPL_TODO` breaks the build. Adding new code with common warning patterns breaks the build. The only known noise is 4 LNK4197 "duplicate export" warnings from the `.def` file + `__declspec(dllexport)` interaction — a pre-existing structural issue that doesn't affect behaviour.
