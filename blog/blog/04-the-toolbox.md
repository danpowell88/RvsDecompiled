---
slug: the-toolbox
title: "04. The Toolbox: Ghidra, CMake, and a 22-Year-Old Compiler"
date: 2025-01-04
authors: [copilot]
tags: [tools, decompilation]
---

Every craftsperson needs their tools. Ours range from cutting-edge open-source software to a compiler old enough to drink. Let's meet the team.

<!-- truncate -->

## Ghidra — The Decompiler

[Ghidra](https://ghidra-sre.org/) is a reverse engineering framework originally developed by the NSA. It was released as open source in 2019 and has since become the go-to free alternative to IDA Pro.

If you've ever used a decompiler for .NET (like ILSpy) or Java (like JD-GUI), Ghidra fills the same role — but for native machine code, which is *much* harder to decompile. A .NET decompiler can give you nearly perfect C# because the intermediate language preserves class names, method signatures, and rich type information. Ghidra is working with raw CPU instructions where all of that metadata has been stripped away. It has to *infer* structure from instruction patterns.

For our project, Ghidra does the heavy lifting:

- **Disassembly** — recognizing x86 instructions in the raw binary (the equivalent of reading opcodes like `MOV`, `CALL`, `JMP` and turning them into something structured)
- **Function detection** — figuring out where functions start and end (not as obvious as it sounds — there are no clear delimiters like `{` and `}`)
- **Decompilation** — translating assembly back into C-like pseudocode that humans can read
- **Type recovery** — applying struct layouts and function signatures so the output uses meaningful types instead of raw memory offsets

We've written six custom Ghidra scripts in Python (Jython, specifically) that automate the tedious parts:

1. **`apply_types.py`** — Imports all the SDK headers into Ghidra's type system so it recognizes `UObject`, `AActor`, `FVector`, etc.
2. **`batch_import.py`** — Runs headless analysis on all 16 binaries and generates JSON reports.
3. **`symbol_recovery.py`** — Demangles MSVC C++ names from the export table and matches them to SDK headers.
4. **`cross_reference.py`** — Maps which DLLs call into which other DLLs.
5. **`ut99_matcher.py`** — Compares decompiled functions against the UT99 source code to find matches.
6. **`export_cpp.py`** — Exports the decompiled code as structured C++ files, one per class.

## CMake — The Build System

If you've used build tools like MSBuild, Gradle, or Webpack, CMake fills a similar role for C++: it describes *what* to build, and generates the actual build instructions for your platform. You don't write makefiles by hand — you write a `CMakeLists.txt` that says "build this DLL from these source files, linking against these dependencies," and CMake figures out the compiler commands.

We use CMake to orchestrate the build. The root `CMakeLists.txt` defines:

- **SDK paths** pointing to the Raven Shield C SDK headers and UT99 reference code
- **Interface libraries** (`Core_Dep`, `Engine_Dep`) — these are "placeholder" targets that represent DLLs we haven't rebuilt yet. They tell the linker "this module exists and exports these functions" without needing the actual source code. As we reconstruct each module, the placeholder gets replaced with the real thing.
- **A macro** (`add_rvs_module`) that wraps the repetitive boilerplate for each DLL module — similar to a factory function that stamps out consistent project configurations
- **Per-module CMakeLists.txt** stubs for all 14 modules — they skip themselves when empty and activate as we add source files

The whole thing generates NMake Makefiles (a simple format that the 2003-era compiler understands) via a custom **toolchain file** — a CMake configuration that says "don't use whatever compiler is installed on this machine; use *this specific* 22-year-old compiler instead."

## MSVC 7.1 — The Vintage Compiler

Here's where it gets fun. Microsoft Visual C++ .NET 2003 (version 7.1) is the compiler that Ubisoft used to build Ravenshield. We use the same compiler because **binary comparison only works when you match the toolchain**.

Why does this matter? When a compiler translates C++ to machine code, it makes thousands of micro-decisions: which CPU register to store a value in, whether to inline a small function or generate a `CALL` instruction, how to lay out a loop. Two different compilers (or even two versions of the *same* compiler) will make different choices — producing different bytes even from identical source code. Since our verification strategy is "compare our output byte-for-byte against the original," we need the exact same decision-maker.

The toolchain file sets up the classic 2003-era compiler flags. If you're used to modern C#/Java where the runtime handles most of this, these flags control low-level behavior that managed languages abstract away:

- `/Zc:wchar_t-` — Treats `wchar_t` (the wide character type for Unicode) as a typedef rather than a built-in type. This is a 2003-era quirk; modern compilers treat it as built-in by default.
- `/GR` — Enables RTTI (Run-Time Type Information), which lets the program check an object's type at runtime. In C#, you get this for free with `is`/`as`/`GetType()`. In C++, it's optional and adds overhead, so it must be explicitly enabled. Unreal uses it for `dynamic_cast`.
- `/O2 /Ob2` — Full optimization with aggressive function inlining. The compiler will try to inline small functions directly into their callers rather than generating a function call. This makes the code faster but also makes decompilation harder — the inlined code doesn't look like a separate function anymore.
- `/MD` — Link against the multithreaded DLL version of the C runtime. In managed terms: "use the shared version of the standard library, not a private copy."

## Binary Comparison Scripts

How do we know if our rebuilt code matches? This is the key verification step — and it requires understanding how a DLL is structured internally.

### A Quick Primer: What's Inside a DLL?

A compiled DLL (or EXE) isn't just a blob of code. It's a structured format called **PE (Portable Executable)**, and it's divided into named **sections** — each holding a different kind of data:

- **`.text`** — The actual machine code (compiled functions). This is the section we care about most.
- **`.rdata`** — Read-only data: string literals, constants, virtual function tables.
- **`.data`** — Mutable global variables.

If you're used to managed assemblies, the PE format serves the same role as a .NET assembly's metadata tables and IL stream — it's the container format that the OS loader understands.

### `bindiff.py`
Compares PE sections byte-by-byte. Loads both the original and rebuilt DLL, matches sections by name, and reports a match percentage for each:

```
Section     Orig Size   Rebuilt    Match    Status
.text          142336    142336   98.73%
.rdata          28672     28672  100.00%    OK
.data            8192      8192   99.84%
```

98.73% on `.text` means our compiled functions produce nearly identical machine code to the original. The remaining ~1.3% is where we need to refine our reconstruction.

### `funcmatch.py`
Goes deeper — function by function. Uses the Ghidra analysis JSON for the original and the MSVC `.map` file (a linker output that lists every function's name and address) for the rebuild. Matches functions by name, extracts their bytes from `.text`, and compares them individually. Sorts worst-first so you know exactly where to focus.

## Import Library Generator

One practical hurdle requires some background on how native linking works.

In managed languages, you add a reference to another assembly and the runtime resolves everything automatically. In native C++, the process is more explicit. When your code calls a function from another DLL, the **linker** (the tool that combines your compiled code into a final binary) needs to know: "this function exists, it's in *that* DLL, and here's its signature." That information lives in an **import library** — a small `.lib` file that acts as a link-time promise: "trust me, this function will be available when the DLL is loaded at runtime."

The original game didn't ship import libraries (they're a developer tool, not something players need), so we wrote a PowerShell script (`generate_import_libs.ps1`) that reverse-engineers them:

1. Runs `dumpbin /exports` on each DLL to list every function it makes available
2. Generates a `.def` file (a text file that lists exported function names and their ordinal numbers)
3. Runs `lib /def` to create a matching `.lib` file from that definition

This gives us link-time stubs for all 15 DLLs plus every third-party dependency (Bink, OpenAL, Ogg Vorbis, EAX). With these in hand, we can compile any single DLL even before we've reconstructed the ones it depends on.

## What's Next?

With Phase 0 complete, we have everything we need to actually start decompiling. Phase 1 will fire up Ghidra, run the batch analysis across all 16 binaries, and generate the first round of reports. We'll know exactly how many functions we're dealing with, which ones have exported symbols (easy wins), and where the UT99 source code gives us a head start.

Time to open the hood.
