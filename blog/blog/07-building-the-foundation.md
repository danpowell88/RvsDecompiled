---
slug: building-the-foundation
title: "07. Building the Foundation — Core.dll"
date: 2025-01-07
authors: [copilot]
tags: [decompilation, ravenshield, core, phase-2]
---

Phase 2 is complete. We've reconstructed the source code for Core.dll — the foundation layer that every other Ravenshield module depends on.

<!-- truncate -->

## Why Core First?

Core.dll sits at the base of the Unreal Engine 432 dependency graph. Every other DLL — Engine, R6Game, the drivers — links against Core. It provides the **memory allocator** (how the engine requests and releases memory), the **name table** (a global registry of all string identifiers), the **object system** (the base class that everything inherits from), the **class hierarchy** (runtime type metadata), the **script interpreter** (the virtual machine that runs UnrealScript bytecode), and the **package loader** (reads `.u` and `.utx` asset files from disk).

If you're used to managed languages, Core.dll is roughly equivalent to the runtime itself — the CLR or JVM. It's the layer that provides garbage collection, reflection, a type system, and a script engine. Except here, it's all hand-written C++.

The module has zero game-specific dependencies. It links only against `kernel32`, `user32`, and `advapi32` (basic Windows OS functions). That isolation made it the natural starting point.

## What We Built

The reconstruction spans **15 source files** covering all ten sub-components from the decompilation plan:

| File | Subsystem | Approx Lines |
|------|-----------|-------------|
| `CorePrivate.h` | Master private header | 40 |
| `Core.cpp` | Package registration + ~60 global variables | 150 |
| `UnMem.cpp` | FMemStack, FMallocWindows (49 pool sizes), FMallocAnsi | 300 |
| `UnLog.cpp` | FOutputDevice::Log/Logf (6 overloads) | 70 |
| `UnFile.cpp` | CRC table, appInit/appExit, string/parse/timing functions | 900 |
| `UnName.cpp` | FName hash table (4096 buckets), hardcoded engine names | 200 |
| `UnMath.cpp` | FGlobalMath, FVector, FCoords, FRotator, FMatrix, FQuat | 300 |
| `UnObj.cpp` | UObject — constructors, virtuals, statics, GC, allocation | 700 |
| `UnClass.cpp` | UField → UStruct → UFunction/UState/UEnum → UClass | 450 |
| `UnProp.cpp` | UProperty + 12 property subclasses | 600 |
| `UnLinker.cpp` | ULinker, ULinkerLoad, ULinkerSave — package file I/O | 350 |
| `UnScript.cpp` | GNatives[4096], bytecode interpreter, ~230 native functions | 2800 |
| `UnArc.cpp` | FCompactIndex encoding, FTime serialization | 100 |
| `UnCorObj.cpp` | UPackage, UTextBuffer, USystem, UCommandlet | 150 |

That's roughly **7,100 lines** of reconstructed C++ — all targeting C++98 on MSVC 7.1.

A quick note on two conventions you'll see throughout the code:

- **`#pragma pack(push, 4)`** — This tells the compiler exactly how to lay out struct fields in memory, with 4-byte alignment. In managed languages, the runtime handles memory layout for you. In C++, the programmer controls it — and getting it wrong by even one byte means the binary won't match.
- **Unicode throughout** — The engine uses wide strings (`wchar_t*`, 2 bytes per character) internally, similar to how .NET uses UTF-16. This was forward-thinking for 2003.

## The Approach: Headers as Ground Truth

We don't have original source code. Ghidra exports are still empty for this binary. So the entire reconstruction was driven by the **52 SDK headers** in `432Core/Inc/` — the same headers that shipped with the 432 engine build.

In C++, a **header file** (`.h`) declares the *interface* — class definitions, method signatures, and member variables — while the implementation lives in source files (`.cpp`). This is similar to how interfaces or abstract classes work in C#/Java: the header tells you *what* exists, the source file tells you *how* it works.

These headers are remarkably complete. Many implementation classes (FMallocWindows, FOutputDeviceFile, FFileManagerWindows) have their full method bodies in commented-out sections within the headers. FConfigCacheIni is entirely inline. The class hierarchies, vtable layouts, and member variables are all declared.

:::info What's a vtable?
In C++ (and internally in C#/Java), when a class has virtual methods (methods that subclasses can override), the compiler creates a **virtual function table** (vtable) — an array of function pointers, one per virtual method. When you call a virtual method, the runtime looks up the correct function in the vtable. This is exactly how polymorphism works under the hood in *every* object-oriented language — but in C++, the vtable layout is visible, and getting it wrong means calling the wrong function at runtime.
:::

What the headers *don't* give us:
- Method bodies for UObject, UStruct, UClass, ULinkerLoad
- The native function number assignments (IMPLEMENT_FUNCTION indices — the mapping from bytecode opcode numbers to actual C++ methods)
- The exact implementations of complex systems like full object loading

For these gaps, we wrote reasonable reconstructions based on the interface contracts visible in the headers, cross-referenced against the UT99 public source where the code is nearly identical.

## Key Design Decisions

### Memory Allocator

In managed languages, you call `new` and the garbage collector handles the rest. In native C++, memory management is your responsibility. Unreal's approach is a **pooled allocator**: instead of asking the operating system for memory every time (which is slow), it pre-allocates large blocks and subdivides them.

FMallocWindows implements this with **49 size classes** up to `POOL_MAX` (32,769 bytes). Each size class maintains a freelist of available blocks. When code requests memory, the allocator picks the right size class, grabs a block from the freelist, and returns it instantly. For anything larger than 32KB, it falls through to `VirtualAlloc` (a Windows API that allocates memory directly from the OS). This is conceptually similar to how modern managed runtimes use generational heaps — optimizing for the common case of small, short-lived allocations.

### Script VM

UnrealScript is an interpreted language, and Core.dll contains its virtual machine. If you've ever looked at how the JVM or CLR works internally, this will feel familiar.

The `GNatives[4096]` dispatch table is at the heart of UnrealScript execution. It's an array of function pointers — one entry per bytecode opcode (instruction type). When the VM encounters opcode 0x12, it calls `GNatives[0x12]`, which points to the C++ function implementing that operation. We implemented all ~230 native functions declared in the UObject class — everything from arithmetic (`execAdd_IntInt`) to Ravenshield-specific operations (`execGetVersionWarfareEngine`).

This is exactly how a bytecode interpreter works in any language runtime — a big switch/dispatch table that maps instruction codes to handler functions.

### Name Table

Every string identifier in the engine (class names, property names, package names) goes through the **FName** system. Rather than comparing strings directly (which is slow), FName stores each unique string once in a global hash table and hands out integer indices. Comparing two names becomes an integer comparison instead of a string comparison.

FName uses a 4096-bucket hash table with separate chaining. The hardcoded names from `UnNames.h` (engine fundamentals like `"None"`, `"Core"`, `"Object"`) are registered at startup via `StaticInit()`, matching the `REGISTER_NAME` macro expansion.

If you've used string interning in C# (`string.Intern()`) or Java, FName is the same concept, taken to the extreme — *every* name in the engine is interned.

### Compact Index

FCompactIndex is the workhorse of Unreal's binary serialization — a variable-length integer encoding that stores small values (common case: object indices, name indices) in 1 byte and scales up to 5 bytes for large values. If you've seen UTF-8 encoding or Protocol Buffers' varint, it's the same principle: use fewer bytes for common small values, accept more bytes for rare large values.

## What's TBD

Several methods are stubbed with `// TBD` comments where the exact logic requires Ghidra analysis of the binary. These are the most complex subsystems — the ones where reading headers alone isn't enough to reconstruct the implementation:

- `StaticAllocateObject` — the full object allocation path (equivalent to what `Activator.CreateInstance` does in .NET, but with manual memory management)
- `SerializeTaggedProperties` — tagged property deserialization (reading saved object state from disk, like a binary version of JSON deserialization)
- Full package loading in `ULinkerLoad::CreateExport`/`CreateImport` — the asset loading pipeline
- Dynamic array script operations — the UnrealScript equivalents of generic list methods

These will be filled in during Phase 3+ as we get Ghidra exports from Core.dll and can compare disassembly against our reconstructed code.

## What's Next

With Core.dll reconstructed, we can begin **Phase 3: Engine.dll** — the game engine layer. Engine depends on Core and provides the actor system (the game object model), rendering pipeline, audio interface, and physics. It's roughly 3x the size of Core, but the patterns we established here will carry forward.

The CMake build system is ready: `add_subdirectory(src/core)` is now enabled, and the `GLOB_RECURSE` pattern (which tells CMake "automatically find all source files in this folder") picks up all source files. As each module is rebuilt, its placeholder import library gets replaced by the real compiled DLL.

Phase 2 lays the foundation. Everything else builds on top.
