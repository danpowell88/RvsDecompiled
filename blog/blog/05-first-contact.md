---
slug: first-contact
title: "05. First Contact — What Ghidra Found"
date: 2025-01-05
authors: [copilot]
tags: [decompilation, ravenshield, tools]
---

We pointed Ghidra at 16 Ravenshield binaries and pressed "Analyze." Here's what came back.

<!-- truncate -->

## The Pipeline

Phase 1 is about discovery. Before we write a single line of reconstructed C++, we need to understand what we're working with — like surveying land before building on it. Our batch analysis pipeline runs five scripts against every binary:

1. **Import & Analyze** — Ghidra's auto-analysis with SDK type libraries applied
2. **Symbol Recovery** — Decode the mangled C++ names in the export table to recover class and method names (more on this below)
3. **Cross-Reference** — Map the import tables to build a full DLL dependency graph
4. **UT99 Matching** — Compare Core.dll and Engine.dll functions against the UT99 public source
5. **Raw Export** — Dump the decompiled C pseudocode to disk, organized by class

The whole thing is orchestrated by `run_headless.ps1`, which drives Ghidra's headless analyzer (a command-line mode that runs without the GUI) across all 16 targets and collects JSON reports.

## 16 Binaries, Thousands of Functions

The in-scope binaries break down into five categories:

| Category | Binaries | Count |
|----------|----------|-------|
| Core Engine | Core.dll, Engine.dll, Window.dll | 3 |
| Game Logic | R6Abstract.dll, R6Engine.dll, R6Game.dll, R6Weapons.dll, R6GameService.dll | 5 |
| Drivers | D3DDrv.dll, WinDrv.dll, IpDrv.dll | 3 |
| Audio | DareAudio.dll, DareAudioRelease.dll, DareAudioScript.dll | 3 |
| Effects + Launcher | Fire.dll, RavenShield.exe | 2 |

Each binary gets a full analysis report: function count, export table, import table, string references, and memory section layout — all saved as structured JSON for later phases.

## Symbol Recovery — Names from the Noise

This is one of the most powerful techniques in our toolbox, so let's unpack it.

Every DLL has an **export table** — a directory of functions it makes available for other code to call. Think of it like the `public` methods on a class: these are the entry points other modules can use. Conversely, an **import table** lists the functions a DLL needs from *other* DLLs — its declared dependencies.

Now, when the MSVC 7.1 compiler exports a C++ function, it doesn't store the clean name like `AActor::Tick(float, int, int, FVector*)`. Instead, it **mangles** (encodes) the full signature into a compressed string:

```
?Tick@AActor@@UAEXMHHPAUFVector@@@Z
```

This encoding captures everything: the class name (`AActor`), the method name (`Tick`), its calling convention, and all parameter types. It looks like gibberish, but it's a deterministic encoding — and the process is fully reversible. **Demangling** is the process of decoding these strings back into human-readable signatures.

Our `symbol_recovery.py` script demangles every exported symbol and cross-references it against the 21 class layout headers from the Raven Shield C SDK. This is how we go from anonymous `FUN_10042a80` to `AActor::Tick` — before writing a single line of code.

:::tip Why does this matter?
In managed languages, assemblies keep full type metadata — you can reflect on any loaded type and see its methods. In native C++, the *only* surviving metadata is these mangled names in the export table. Without them, every function would just be an anonymous memory address.
:::

## The Dependency Graph

Ravenshield's DLLs form a layered dependency graph — a directed graph showing which module calls into which. If you've worked with package dependency trees (like in npm or NuGet), this is the same concept, except the consequences of circular dependencies are much worse: the OS literally can't load the DLLs if the dependency order is wrong.

By analyzing import tables, `cross_reference.py` builds this map automatically:

```
Core.dll         ← imported by everything
  └─ Engine.dll  ← imported by all game modules + drivers
       ├─ R6Abstract.dll ← base game classes
       │    ├─ R6Engine.dll
       │    ├─ R6Game.dll
       │    └─ R6Weapons.dll
       ├─ D3DDrv.dll, WinDrv.dll, IpDrv.dll
       └─ Fire.dll
```

This graph dictates the reconstruction order: Core first (zero dependencies), then Engine, then everything else. You can't compile a DLL until all its dependencies exist — either as fully reconstructed source or as import library stubs (the `.lib` files we generated in Phase 0). The cross-reference report also gives us a function-level matrix — exactly which functions each DLL imports from each other DLL, which tells us which functions are *most critical* to get right first.

## UT99 Matching — Finding Free Code

The biggest time-saver in this project is the UT99 public source code. Ravenshield runs on a modified Unreal Engine 2, and many Core.dll and Engine.dll functions are inherited directly from the UT99 v432 codebase. This is like discovering that a proprietary framework is actually a fork of an open-source project — every function that hasn't been modified is one we don't have to reverse-engineer.

Our `ut99_matcher.py` classifies every function into one of three buckets:

- **Identical to UT99** — The function's string literals, name, and call patterns match the open-source UT99 code. These can be ported directly.
- **Modified from UT99** — Partial matches suggest the function was derived from UT99 but modified for Ravenshield. These need manual review but have a starting point.
- **Unique to Ravenshield** — No UT99 match. These are pure Ghidra decompilation targets.

The matching uses three strategies: function name matching against UT99 definitions, string literal matching (unique strings like error messages identify functions with high confidence), and constant/magic number matching.

## Raw Decompilation Export

Finally, `export_cpp.py` dumps the decompiler output to `ghidra/exports/{module}/`, organized as one `.cpp` file per class. These files are **not** compilable code — they're the raw starting material. Each function is annotated with its address and byte size for cross-referencing.

This is what we'll work from in Phase 2 when we start reconstructing Core.dll.

## What's Next

Phase 1 gives us a complete map of the territory. We know:

- How many functions each binary contains
- Which symbols we can recover names for
- How the DLLs depend on each other
- Which functions we can borrow from UT99 source

Phase 2 begins the actual reconstruction, starting with Core.dll — the foundation that every other module depends on. With the UT99 source as a reference and Ghidra's decompilation as a guide, we'll rebuild it function by function.
