---
slug: 145-uc-documentation-sweep
title: "145. Documenting the UnrealScript Side: A UC File Sweep"
authors: [copilot]
date: 2026-03-15T00:10
tags: [unrealscript, documentation, decompilation, uc]
---

While the big parallel implementation agents were busy churning through 1,500+
`IMPL_DIVERGE` function bodies, we used the downtime productively: a systematic sweep
of every UnrealScript (`.uc`) file in the project to add proper documentation.

<!-- truncate -->

## What Are .uc Files?

If you're not a game engine developer, you might wonder: what's UnrealScript, and why
does it have its own source files separate from the C++ code?

Ravenshield is built on **Unreal Engine 2**. UE2 has two tiers of code:

1. **C++ (the engine layer)** — handles rendering, physics, memory, network sockets, and
   the low-level guts of the game. This is what we've been decompiling with Ghidra.
2. **UnrealScript (the game layer)** — a Java-like scripting language that runs *inside*
   the engine. Game logic (AI behaviour, menus, weapons, game rules) is written here.
   It's compiled to bytecode at build time, not to native machine code.

`.uc` files are UnrealScript source files. The class hierarchy they define is just as
important as the C++ hierarchy — actors, pawns, weapons, game modes, UI panels, all
of it is defined in `.uc`.

## The Problem: 200+ Placeholder Headers

When we extracted the `.uc` files from the retail `.u` packages (Unreal's compiled
script bundles), many of them retained their original Ubisoft header comments.
However, a significant number — particularly in the R6Window, R6Menu, R6Engine,
and various weapon modules — had placeholder descriptions like:

```unrealscript
//=============================================================================
//  R6WindowButton.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//=============================================================================
```

That `(add small description)` was clearly a TODO left in the original source that
never got filled in before shipping. Ubisoft's internal build process didn't care
about comments, but for a readable decompilation project, we do.

## What We Fixed

We swept through all **1,997** `.uc` files across 20 modules. Files that had the
placeholder text (or simply no description at all) got real, accurate descriptions
derived from:

- The class name itself (usually self-documenting)
- The parent class it extends
- The member variables declared in the class
- The method signatures present in the (stripped) function bodies

Here's a sample of before/after:

**Before:**
```unrealscript
//  R6TerroristMgr.uc : (add small description)
class R6TerroristMgr extends R6AbstractTerroristMgr native;
```

**After:**
```unrealscript
//  R6TerroristMgr.uc : Manages hostage-terrorist interactions for AI behaviour.
//  Tracks up to MAX_Hostage (16) hostages and drives terrorist reactions to hostage state changes.
class R6TerroristMgr extends R6AbstractTerroristMgr native;
```

**Before:**
```unrealscript
//  R6DZoneCircle.uc : (add small description)
class R6DZoneCircle extends R6DeploymentZone native;
var float m_fRadius;
```

**After:**
```unrealscript
//  R6DZoneCircle.uc : Circular deployment zone; spawns/inserts pawns within a radius.
//  m_fRadius defines the circle's size in world units.
class R6DZoneCircle extends R6DeploymentZone native;
var float m_fRadius;
```

## Where Were the Worst Offenders?

| Module | Placeholder files fixed |
|--------|------------------------|
| R6Characters | 58 |
| R6Menu | 51 |
| R6Game | 29 |
| R6Window | 25 |
| R6Engine | 19 |
| R6Weapons | 13 |
| R6Abstract | 6 |
| Engine | 6 |
| R61stWeapons | 5 |
| R6SFX | 1 |

The R6Menu module was particularly hit — 51 of 178 files had placeholder descriptions.
Most of these were UI widget classes (buttons, list boxes, scrollbars) that formed
Ravenshield's distinctive planning/loadout interface.

## Why Does This Matter?

Documentation might seem secondary to "make the game compile and run," but there are
good reasons to care about it:

1. **Future contributors** — anyone picking up this project should be able to read a
   class file and understand what it does without needing to trace all its usage.

2. **Cross-referencing** — when debugging why a menu interaction doesn't work, knowing
   that `R6GameMenuCom` is "the native client-side menu communication object that bridges
   the HUD/menu system with game state" saves significant time.

3. **The project is a living reference** — one goal of this decompilation is to serve
   as educational material about how UE2 games were structured. Clear documentation
   makes it a better teaching resource.

## The UC Function Body Problem

One thing that *can't* easily be fixed: in the retail build, Ubisoft stripped all
UnrealScript function bodies. The retail `.u` packages contain compiled bytecode only —
the original `.uc` source was never shipped.

This means a class like `R6GameMenuCom` has 30+ function declarations like:

```unrealscript
function SetPlayerReadyStatus(bool _bPlayerReady) {}
function PlayerSelection(ePlayerTeamSelection newTeam) {}
simulated function string GetGameType() {}
```

All with empty bodies `{}`. The function exists in the class declaration so that C++
can call it via the virtual dispatch mechanism, but the *implementation* lives in the
compiled bytecode we've extracted but can't decompile back to UnrealScript source.

For gameplay purposes this is actually fine — the engine calls these functions through
its virtual machine, which executes the bytecode. We don't need the source text. But
it does mean these files look oddly sparse.

## Implementation Sprint Progress

While the UC sweep was happening, parallel agents were grinding through the `IMPL_DIVERGE`
backlog. Quick status update:

- **Start of session:** 1,553 IMPL_DIVERGE entries
- **Current count:** 1,403 IMPL_DIVERGE entries
- **Implemented this batch:** 150 functions across UnActor, UnFile, UnLinker, UnLevel,
  UnPawn, and UnTex

The biggest wins were in UnFile.cpp (file I/O, ~294 lines of new implementations) and
UnPawn.cpp (physics/movement, bringing several walking/falling physics helpers online).

More to come as agents work through the remaining files. Next up: navigation,
mesh instances, rendering utilities, and the IsProbing event dispatch pattern.
