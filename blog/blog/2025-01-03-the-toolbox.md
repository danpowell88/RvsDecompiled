---
slug: the-toolbox
title: "The Toolbox: Ghidra, CMake, and a 22-Year-Old Compiler"
authors: [rvs-team]
tags: [tools, decompilation]
---

Every craftsperson needs their tools. Ours range from cutting-edge open-source software to a compiler old enough to drink. Let's meet the team.

<!-- truncate -->

## Ghidra — The Decompiler

[Ghidra](https://ghidra-sre.org/) is a reverse engineering framework originally developed by the NSA. It was released as open source in 2019 and has since become the go-to free alternative to IDA Pro.

For our project, Ghidra does the heavy lifting:

- **Disassembly** — recognizing x86 instructions in the raw binary
- **Function detection** — figuring out where functions start and end
- **Decompilation** — translating assembly back into C-like pseudocode
- **Type recovery** — applying struct layouts and function signatures

We've written six custom Ghidra scripts in Python (Jython, specifically) that automate the tedious parts:

1. **`apply_types.py`** — Imports all the SDK headers into Ghidra's type system so it recognizes `UObject`, `AActor`, `FVector`, etc.
2. **`batch_import.py`** — Runs headless analysis on all 16 binaries and generates JSON reports.
3. **`symbol_recovery.py`** — Demangles MSVC C++ names from the export table and matches them to SDK headers.
4. **`cross_reference.py`** — Maps which DLLs call into which other DLLs.
5. **`ut99_matcher.py`** — Compares decompiled functions against the UT99 source code to find matches.
6. **`export_cpp.py`** — Exports the decompiled code as structured C++ files, one per class.

## CMake — The Build System

We use CMake to orchestrate the build. The root `CMakeLists.txt` defines:

- **SDK paths** pointing to the Raven Shield C SDK headers and UT99 reference code
- **Interface libraries** (`Core_Dep`, `Engine_Dep`) that encapsulate link-time dependencies
- **A macro** (`add_rvs_module`) that wraps the boilerplate for each DLL module
- **Per-module CMakeLists.txt** stubs for all 14 modules — they skip themselves when empty and activate as we add source files

The whole thing generates NMake Makefiles (because that's what MSVC 7.1 understands) via a custom **toolchain file** that points CMake at the vintage compiler.

## MSVC 7.1 — The Vintage Compiler

Here's where it gets fun. Microsoft Visual C++ .NET 2003 (version 7.1) is the compiler that Ubisoft used to build Ravenshield. We use the same compiler because **binary comparison only works when you match the toolchain**.

Different compilers make different choices about register allocation, instruction selection, and optimization. Even MSVC 7.1 vs MSVC 8.0 can produce noticeably different code for the same source. By using the *exact* compiler version, we can verify our reconstruction function-by-function.

The toolchain file sets up the classic 2003-era flags:
- `/Zc:wchar_t-` — `wchar_t` is a typedef, not a built-in type
- `/GR` — RTTI enabled (Unreal uses `dynamic_cast`)
- `/O2 /Ob2` — full optimization with aggressive inlining
- `/MD` — link against the multithreaded DLL runtime

## Binary Comparison Scripts

How do we know if our rebuilt code matches? Two Python scripts:

### `bindiff.py`
Compares PE sections byte-by-byte. Loads both the original and rebuilt DLL, matches sections by name (`.text`, `.rdata`, `.data`), and reports a match percentage for each.

```
Section     Orig Size   Rebuilt    Match    Status
.text          142336    142336   98.73%
.rdata          28672     28672  100.00%    OK
.data            8192      8192   99.84%
```

### `funcmatch.py`
Goes deeper — function by function. Uses the Ghidra analysis JSON for the original and the MSVC `.map` file for the rebuild. Matches functions by name, extracts their bytes from `.text`, and compares them individually. Sorts worst-first so you know exactly where to focus.

## Import Library Generator

One practical hurdle: we can't rebuild a DLL that *calls into another DLL* without having a `.lib` file for the dependency. The original game didn't ship import libraries (why would it?), so we wrote a PowerShell script (`generate_import_libs.ps1`) that:

1. Runs `dumpbin /exports` on each DLL
2. Generates a `.def` file from the export table
3. Runs `lib /def` to create a matching `.lib` file

This gives us link-time stubs for all 15 DLLs plus every third-party dependency (Bink, OpenAL, Ogg Vorbis, EAX).

## What's Next?

With Phase 0 complete, we have everything we need to actually start decompiling. Phase 1 will fire up Ghidra, run the batch analysis across all 16 binaries, and generate the first round of reports. We'll know exactly how many functions we're dealing with, which ones have exported symbols (easy wins), and where the UT99 source code gives us a head start.

Time to open the hood.
