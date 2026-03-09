---
slug: what-is-decompilation
title: "01. What Is Decompilation? A Gentle Introduction"
date: 2025-01-01
authors: [rvs-team]
tags: [decompilation]
---

If you've ever wondered how people take a finished video game — a blob of ones and zeros — and turn it back into readable source code, you're about to find out. Welcome to the world of **decompilation**.

<!-- truncate -->

## From Source Code to Machine Code (and Back Again)

If you're used to languages like C#, Java, or Python, you probably know that your source code gets transformed before it runs. In C# and Java, the compiler produces an intermediate format (IL or bytecode) that still retains a lot of structure — class names, method signatures, even variable names. That's why tools like dotPeek or JD-GUI can decompile a .NET or Java binary almost perfectly.

C++ is a different beast. When a developer writes a game in C++, the compiler translates it directly into **machine code** — the raw CPU instructions your processor executes. There's no intermediate layer. The resulting `.exe` and `.dll` files are pure binary. Class names? Gone. Variable names? Gone. Comments? Gone. What's left is register shuffles, memory addresses, and jump instructions.

**Decompilation** is the reverse journey. We take those compiled binaries and attempt to reconstruct something that *looks like* the original source code. It won't be identical — all those names and comments were discarded during compilation — but the *logic* is all still there, encoded in the instruction patterns.

:::tip Coming from managed languages?
Think of it this way: decompiling a .NET assembly is like translating a book from Spanish back to English — the structure is preserved and the result is quite readable. Decompiling a native C++ binary is like reconstructing a novel from its audiobook recording — the content is there, but all the formatting, paragraph breaks, and chapter titles are missing. You have to figure those out yourself.
:::

## Why Would Anyone Do This?

Great question. A few reasons:

- **Preservation.** Old games stop working on new hardware. If you can read and rebuild the code, you can keep the game alive.
- **Modding.** Ravenshield has had an active modding community for over 20 years. Proper source access lets modders do things that were never possible with UnrealScript alone. (UnrealScript is the engine's own scripting language — think of it like Lua or GDScript: a higher-level language the engine interprets at runtime. It can control game logic, but it can't touch the engine internals.)
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

- **DLL plugins.** If you're used to NuGet packages or npm modules, a DLL (Dynamic Link Library) is the native equivalent — a self-contained library of compiled code that gets loaded at runtime. The game isn't one giant EXE. It's a small launcher plus about 15 DLLs, each responsible for something different (rendering, audio, networking, weapons, AI...). This modular design is actually great for us: we can tackle one DLL at a time.
- **MSVC name mangling.** In managed languages, reflection gives you clean class and method names at runtime. C++ doesn't have that luxury — but it does have something called *name mangling*. The compiler encodes a function's full signature (class, method name, parameter types) into a single decorated string. So `?ProcessEvent@UObject@@UAEXPAVUFunction@@PAX@Z` is the compiler's way of storing `UObject::ProcessEvent(UFunction*, void*)`. We can decode these, and they become our roadmap.
- **UnrealScript glue.** Many C++ functions exist purely to be called *from* UnrealScript. If you've ever written native plugins for Unity or Godot that expose methods to a scripting layer, it's the same idea. The naming conventions are predictable, which helps us identify them.

## What Comes Next?

In the next post, we'll introduce the game itself — Rainbow Six: Ravenshield — and talk about what makes it a compelling decompilation target. Then we'll tour the toolbox: Ghidra, CMake, custom comparison scripts, and the vintage MSVC 7.1 compiler.

Stay tuned. This is going to be a ride.
