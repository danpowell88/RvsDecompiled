---
slug: what-is-decompilation
title: "What Is Decompilation? A Gentle Introduction"
authors: [rvs-team]
tags: [decompilation]
---

If you've ever wondered how people take a finished video game — a blob of ones and zeros — and turn it back into readable source code, you're about to find out. Welcome to the world of **decompilation**.

<!-- truncate -->

## From Source Code to Machine Code (and Back Again)

When a developer writes a game in C++, their human-readable code goes through a **compiler** (in our case, Microsoft Visual C++ 7.1 from 2003) which translates it into machine code — the raw instructions your CPU actually executes. That compiled output ships as `.exe` and `.dll` files.

**Decompilation** is the reverse journey. We take those compiled binaries and attempt to reconstruct something that *looks like* the original source code. It won't be identical — variable names, comments, and formatting are lost during compilation — but the *logic* is all still there, encoded in the instruction patterns.

## Why Would Anyone Do This?

Great question. A few reasons:

- **Preservation.** Old games stop working on new hardware. If you can read and rebuild the code, you can keep the game alive.
- **Modding.** Ravenshield has had an active modding community for over 20 years. Proper source access lets modders do things that were never possible with UnrealScript alone.
- **Education.** A 2003-era Unreal Engine game is a fantastic case study. It's complex enough to be interesting, but small enough to be approachable.

## How Does It Work in Practice?

We use a tool called **Ghidra** (built by the NSA and released as open source in 2019). Ghidra reads a binary, figures out where functions start and end, traces the control flow, and produces a C-like pseudocode listing for each function.

The catch? Ghidra's output is *ugly*. Variables are named `iVar1`, `uVar2`, `local_48`. There are no classes, no method names, no structure. It's our job to:

1. **Identify** what each function does (using SDK headers, string references, and the UT99 source code as clues).
2. **Rename** everything to meaningful names.
3. **Restructure** the decompiled output into proper C++ classes.
4. **Compile** it and compare the output byte-by-byte against the original.

Rinse and repeat, a few thousand times.

## What's Different About a Game Binary?

Games compiled with Unreal Engine 2 have some fun quirks:

- **DLL plugins.** The game isn't one giant EXE — it's a launcher plus about 15 DLLs, each responsible for something different (rendering, audio, networking, weapons, AI...).
- **MSVC name mangling.** C++ symbol names in the export table look like `?ProcessEvent@UObject@@UAEXPAVUFunction@@PAX@Z`. We can decode these back into `UObject::ProcessEvent(UFunction*, void*)`.
- **UnrealScript glue.** Many C++ functions exist purely to be called *from* UnrealScript. The naming conventions are predictable, which helps us identify them.

## What Comes Next?

In the next post, we'll introduce the game itself — Rainbow Six: Ravenshield — and talk about what makes it a compelling decompilation target. Then we'll tour the toolbox: Ghidra, CMake, custom comparison scripts, and the vintage MSVC 7.1 compiler.

Stay tuned. This is going to be a ride.
