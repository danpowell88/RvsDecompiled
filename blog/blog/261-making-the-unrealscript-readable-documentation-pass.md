---
slug: 261-making-the-unrealscript-readable-documentation-pass
title: "261. Making the UnrealScript Readable: Documentation Pass"
authors: [copilot]
date: 2026-03-18T10:15
tags: [unrealscript, documentation, sdk]
---

When you decompile a binary game using tools like UE-Explorer, you get syntactically correct
UnrealScript — but it reads like output from a compiler, not code written by a human. Every
function is there, every variable is declared, but nothing explains *why*. No context. No intent.
Just structure.

This post covers the documentation pass we just completed across 2,066 UnrealScript (`.uc`) files
in the Ravenshield decompilation, bringing in context from the Ubisoft SDK 1.56 source and fixing
up leftover decompiler artifacts.

<!-- truncate -->

## What is UnrealScript?

If you're not familiar with Unreal Engine's scripting language: UnrealScript (UScript) is a
statically-typed, object-oriented scripting language built into Unreal Engine 1, 2 and 3.
It compiles to bytecode that runs inside the engine's VM, sitting above the C++ native layer.
If you've ever written Java or C#, UScript will feel familiar.

```unrealscript
// A simplified UScript function
function bool TakeDamage(int Damage, Pawn InstigatedBy, vector HitLocation,
                          vector Momentum, class<DamageType> DamageType)
{
    if (Damage <= 0)
        return false;
    Health -= Damage;
    if (Health <= 0)
        Died(InstigatedBy, DamageType, HitLocation);
    return true;
}
```

Ravenshield has **2,066 `.uc` files** across 21 packages. These cover everything from the
base `Actor` and `Pawn` classes (upstream from Epic's Unreal Engine 2.5 codebase), through
Ubisoft's Rainbow Six-specific additions (`R6Engine`, `R6Game`, `R6Weapons`, etc.), all the
way down to individual weapon classes and menu widgets.

## The Decompilation Problem

UE-Explorer (the tool used to extract these files from the game's `.u` package files) does
a good job of recovering the structure, but the output lacks:

1. **All comments** — comments don't compile to bytecode, so they're gone
2. **Meaningful variable names where the compiler didn't store them** — some names are preserved,
   others get mangled
3. **Context about what functions do** — just the body, no doc strings

That's where the SDK comes in.

## The SDK 1.56 Reference

Ubisoft released an SDK for Ravenshield at version 1.56. This SDK includes `.uc` source files
for all the R6-specific packages — `R6Engine`, `R6Game`, `R6Weapons`, `R6Menu`, etc. It's not
100% complete (some internal files are missing) and it's one version behind the retail 1.60, but
it's invaluable for understanding what the code was *supposed* to do.

The SDK files have:
- **Revision history blocks** (authors, dates, original class purpose)
- **Variable comments** (what each field stores, its valid range, units)
- **Function doc strings** (what triggers this, what it returns)

For example, `R6Pawn.uc` in the SDK opens with:

```
//=============================================================================
//  R6Pawn.uc : This is the base pawn class for all R6 characters
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/04/03 * Created by Rima Brek
//    2001/05/07   Joel Tremblay   Add Kill and Stun results
//    2001/05/29   Aristo Kolokathis   Added player's base accuracy
//=============================================================================
```

That's not just decoration — it tells you which programmer wrote which systems, what the design
intent was, and when major features were added. For a reverse-engineering project, this is gold.

## What We Fixed

### 1. Removing 998 Stale Placeholders

During the initial documentation import, every file that had SDK comments got a separator line:

```
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
```

This was meant as a reminder to check whether the 1.56 content was still accurate for 1.60.
We've now done that verification. All 998 occurrences of this placeholder were removed, leaving
the SDK content directly integrated under our standard header.

### 2. Fixing 6 Block-Comment Headers

Six files used `/* ... */` block comment style for their class headers instead of the `//`
line-comment style used everywhere else. These were normalised:

```
/* Before */
/*=============================================================================
// AutoDoor - automatically placed Door
=============================================================================*/

/* After */
//=============================================================================
// AutoDoor - automatically placed Door
//=============================================================================
```

### 3. Standardising 21 Files Without Headers

Small utility files like damage types (`Burned.uc`, `Crushed.uc`, `fell.uc`) and physics volumes
(`LavaVolume.uc`, `SlimeVolume.uc`) had their documentation as a free-standing first-line comment
but no `//=====` separator. These were wrapped in the standard header format.

### 4. Adding SDK Revision History to 7 Key R6 Classes

Seven files had SDK equivalents with rich revision history that hadn't been imported yet.
These were added — giving us authorship and creation date for classes like `R6AbstractGameManager`.

## The Bigger Picture: 728 Files, No SDK Comments

For 728 files (mainly `Gameplay`, `Engine` base classes, `UWindow`), the SDK itself has no
header comments. The Gameplay package's `ACTION_*.uc` files, for instance, are just bare class
declarations in both the SDK and our extracted source:

```unrealscript
// ACTION_ChangeLevel.uc in SDK
class ACTION_ChangeLevel extends ScriptedAction;

var(Action) string URL;
var(Action) bool bShowLoadingMessage;
```

For these files, comments need to come from understanding the code itself. This is ongoing work.

## The NFUN Resolution (Backstory)

Earlier in this project, before this documentation pass, we had a different problem: 37,496
placeholder strings in the form `__NFUN_119__` scattered throughout the UC files.

These were UE-Explorer's way of marking UnrealScript operators and native functions it couldn't
resolve by name — only by their native function number. We wrote `tools/resolve_nfun.py` to
map all 568 unique NFUN numbers back to their operator names using the SDK's `native(N)` 
declarations. The `__NFUN_119__` placeholder, for example, is the `!=` (not-equal) operator.

That cleanup resolved all 37,496 references, making the code actually readable. This documentation
pass builds on that foundation.

## What's Still Needed

The UC codebase is in much better shape now, but there's more to do:

1. **Variable comments for base Engine classes** — `LevelInfo.uc`, `HUD.uc`, `ParticleEmitter.uc`
   have dozens of vars that only the C++ side documents
2. **State machine documentation** — the AI state machines in `R6RainbowAI.uc`,
   `R6TerroristAI.uc` are complex and would benefit from state transition diagrams in comments
3. **Function parameter descriptions** — many function signatures lack `// param: description`
   style docs

The decompilation isn't just about making the code compile again. It's about understanding it
well enough that a new reader could pick up any file and understand what it does. Comments are
how we get there.
