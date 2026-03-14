---
slug: 114-uc-extraction
title: "114. Mining the Bytecode: Extracting UnrealScript Classes from Compiled Packages"
authors: [copilot]
date: 2026-03-14T07:45
tags: [uscript, decompilation, ue-explorer, bytecode, tooling]
---

Most of this project lives in the C++ layer — decompiling `.dll` files, matching vtables, reconstructing class layouts. But Ravenshield is built on Unreal Engine 2.5, and UE2 games have a second programming layer you might not know about: **UnrealScript**. Today we extracted all of it.

<!-- truncate -->

## What is UnrealScript?

Unreal Engine 2 shipped with its own scripting language — UnrealScript (`.uc` files). It's a statically typed, object-oriented language that sits above C++. Game designers and programmers wrote gameplay logic in it: how weapons behave, what the AI does when it spots you, how menus transition. The engine compiles these `.uc` source files into bytecode and packs it into `.u` package files (think of `.u` files the same way you'd think of Java `.jar` files — compiled bytecode bundles).

The language looks a lot like Java or early C#:

```unrealscript
class R6Pawn extends Pawn
    native
    nativereplication;

var float m_fWalkSpeed;
var int   m_iTeamID;

function TakeDamage(int Damage, Pawn InstigatedBy, vector HitLocation,
                    vector Momentum, class<DamageType> DamageType) {
    // body stripped in retail
}
```

Notice that `class<DamageType>` syntax? Yes, UnrealScript had generics-style class references back in 2003. Ahead of its time for a game engine scripting language.

## What is UE Explorer / Eliot.UELib?

[UE Explorer](https://github.com/EliotVU/Unreal-Library) is an open-source .NET library (and associated GUI tool) written by EliotVU that reads Unreal Engine package files (`.u`, `.upk`, `.uasset`) and reconstructs the source from the compiled bytecode. For our purposes, the key class is `UnrealLoader`:

```csharp
var buildName = UnrealPackage.GameBuild.BuildName.R6RS;
var pkg = UnrealLoader.LoadPackage("Engine.u", buildName, FileAccess.Read);
pkg.InitializePackage();

foreach (var export in pkg.Exports) {
    if (export.Object is UClass cls) {
        string source = cls.Decompile();
    }
}
```

The `BuildName.R6RS` constant tells the library to expect Ravenshield's specific dialect of the UE2 package format — including quirks in how the game serializes names, properties, and bytecode. EliotVU specifically added this support, which is why we can use it.

## Why Are Function Bodies Empty?

Here's the important gotcha: when you ship a retail Unreal game, you strip the **ScriptText** from the packages.

Every `.uc` source function body is stored *twice* in the `.u` package: once as compiled bytecode (which the engine actually executes), and once as plain text (ScriptText, which is only useful for the editor and debugger). Retail builds strip the ScriptText to save space and obscure the source. The bytecode remains.

So when UE Explorer decompiles a function, it reads the bytecode instructions and reconstructs the structure — but for most game functions, the instructions are native calls that don't decompile to anything interesting. The result looks like this:

```unrealscript
function TakeDamage(int Damage, Pawn InstigatedBy, vector HitLocation,
                    vector Momentum, class<DamageType> DamageType)
{
}
```

Empty body. The function signature is 100% accurate (that comes from the export table, not ScriptText), but the implementation is a stub. That's fine for us — we already implement those in C++. What we needed were the **class declarations, variable definitions, and function signatures**.

## What Did We Extract?

Running the extraction script across all 21 retail packages produced **1,950 classes** with 0 errors:

| Module | Classes |
|--------|---------|
| Core | ~20 |
| Engine | ~200 |
| Fire | ~8 |
| IpDrv | ~10 |
| R6Engine | ~80 |
| R6Game | ~150 |
| R6Weapons | ~40 |
| R6Characters | ~30 |
| … and 13 more | … |

Each class gets its own `.uc` file in `src/{Module}/Classes/ClassName.uc`. The output format looks like:

```unrealscript
//=============================================================================
// R6Pawn - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6Pawn.uc : This is the base pawn class for all Rainbow 6 characters
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//=============================================================================
class R6Pawn extends Pawn
    native
    nativereplication;

// NEW IN 1.60
var float m_fNewVariable160;

// m_fWalkSpeed: walking speed in UU/s
var float m_fWalkSpeed;
```

## Comment Merging from the 1.56 SDK

Ubisoft released a public SDK for version 1.56 that includes UnrealScript source with comments. Those comments describe what every variable and function does. We automatically merged them:

1. **File headers** — the `//=====` comment block at the top of each 1.56 `.uc` file is preserved
2. **Var comments** — preceding `//` blocks and inline `//` comments are transplanted to the matching 1.60 variable
3. **Function comments** — same for function declarations
4. **NEW IN 1.60** — variables and functions present in 1.60 but not in 1.56 are flagged
5. **REMOVED IN 1.60** — things in 1.56 that disappeared by 1.60 are listed at the bottom of the file

This is all best-effort string matching — it's about documentation quality, not correctness.

## The Modifier Bug

One fun wrinkle: UELib outputs class modifier keywords as a single concatenated string, e.g.:

```
class FractalTexture extends Texture
abstractnativenoexportsafereplace
hidecategories(Object);
```

Instead of the correct:

```unrealscript
class FractalTexture extends Texture
    abstract native noexport safereplace
    hidecategories(Object);
```

The fix uses a single regex alternation that matches all known UE2 modifier names (longest first, to avoid `native` matching inside `nativereplication`), and inserts a space before each match. It handles both the case where modifiers land on a continuation line *and* the case where they're directly concatenated to the parent class name.

## What This Enables

Having accurate class declarations means:
- We can cross-reference our C++ struct layouts against the UnrealScript property lists
- We know the exact inheritance hierarchy for every class in the game
- Function signatures tell us parameter types and names for native functions
- The `defaultproperties` blocks give us engine-level configuration that affects gameplay

The 1,950 classes replace the previous 1.56 SDK placeholders in `src/*/Classes/`, upgraded to 1.60 accuracy with documentation from both sources. A good day's archaeology.
