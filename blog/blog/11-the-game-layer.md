---
slug: the-game-layer
title: "11. The Game Layer — Rebuilding Rainbow Six's R6 Modules"
date: 2025-01-11
authors: [rvs-team]
tags: [decompilation, ravenshield, r6abstract, r6weapons, r6engine, r6game, r6gameservice, phase-6]
---

Phase 6 is done. Five new DLLs — `R6Abstract.dll`, `R6Weapons.dll`, `R6Engine.dll`, `R6Game.dll`, and `R6GameService.dll` — now compile and link. With twelve modules total, we've crossed a milestone: every DLL that the original Ravenshield loads at startup can now be built from source on a modern machine.

These aren't generic Unreal modules. This is the *game*. The Rainbow Six-specific code that turns a general-purpose 3D engine into a tactical shooter.

<!-- truncate -->

## A Quick Recap: Where We Are

Twelve builds, zero linker errors:

| DLL | Phase | Job |
|-----|-------|-----|
| Core.dll | 1 | Object model, reflection, scripting VM |
| Engine.dll | 2–3 | Actor graph, world, rendering interface |
| Fire.dll | 4 | Procedural fire/water textures |
| Window.dll | 4 | Win32 GUI framework |
| IpDrv.dll | 4 | Network sockets |
| WinDrv.dll | 5 | Windows input and windowing |
| D3DDrv.dll | 5 | Direct3D 8 rendering |
| **R6Abstract.dll** | **6** | **Abstract game interfaces** |
| **R6Weapons.dll** | **6** | **Weapon system** |
| **R6Engine.dll** | **6** | **R6-specific engine extensions** |
| **R6Game.dll** | **6** | **Game modes, HUD, campaign** |
| **R6GameService.dll** | **6** | **Server list, matchmaking, patching** |

---

## What Makes These Modules Different?

Phases 1–5 rebuilt Unreal infrastructure — the engine's plumbing. Phase 6 is the first time we're touching *game code*. The classes in these DLLs know what a "terrorist" is, what an "operative" is, why a door has a lock, and how planning waypoints work.

The original Unreal Engine 2 is a framework. Games built on it bolt their own modules on top, extending the base Actor classes with game-specific behaviour. Ravenshield's five R6 modules form a dependency chain:

```
Core → Engine → R6Abstract → R6Weapons
                           → R6Engine → R6Game
                                      → R6GameService
```

R6Abstract sits at the root — pure interfaces and abstract base classes. R6Weapons and R6Engine extend those with concrete implementations. R6Game wires everything into playable game modes, and R6GameService handles the online layer (server browsers, Ubi.com integration, PunkBuster, patching).

---

## The Dependency Graph Problem

The interesting technical challenge in Phase 6 is that these modules *cross-reference each other*. A class in R6Game might inherit from a class in R6Engine, which inherits from a class in Engine.dll, which in turn has forward declarations pointing back to R6Engine types.

In a normal project you'd just `#include` everything and let the linker sort it out. In a decompilation, you can't — you need each module to compile and link *independently*, using only the import libraries from modules built before it.

This forced a bottom-up build order:

1. **R6Abstract** — depends only on Core + Engine (both already built)
2. **R6Weapons** — depends on R6Abstract + Engine
3. **R6Engine** — depends on R6Abstract + Engine
4. **R6Game** — depends on R6Engine + R6Abstract + Engine
5. **R6GameService** — depends on R6Abstract + Engine

Each step links against the `.lib` files produced by earlier steps. If R6Engine needs a symbol from R6Abstract, it uses the retail `.lib` from the SDK. But if R6Game needs a symbol from *our* R6Engine (which exports things the retail SDK `.lib` doesn't), it links against our build output.

---

## Header-Only Classes: A Recurring Puzzle

One pattern kept appearing across these modules. Consider a class like `AR6ReferenceIcons` — it's defined in R6Engine's header, inherits from `AActor`, and has several subclasses in R6Game (arrows, path flags, camera icons). You'd expect it to be exported from R6Engine.dll. But when we checked the retail import libraries:

```
No symbols found for AR6ReferenceIcons in any .lib file.
```

The class exists in the SDK headers. The game runs fine. But nobody bothered to include it in the SDK's import library. That means the original developers compiled it with `__declspec(dllexport)` in their build, but the SDK `.lib` was generated from a subset of exports.

Our solution: treat these as **header-only classes**. No `DLL_IMPORT`, no `DLL_EXPORT`. Just an inline constructor in the header. The compiler generates any implicit special members (copy constructor, destructor, assignment operator) inline, and downstream modules that inherit from them get everything they need without importing a single symbol.

| Class | Expected Location | Reality |
|-------|------------------|---------|
| `AR6ReferenceIcons` | R6Engine.lib | Not exported |
| `ABroadcastHandler` | Engine.lib | Not exported |
| `UWindowConsole` | UWindow.lib | No UWindow.lib exists |
| `UR6MissionObjectiveBase` | Engine.lib | Not exported |
| `AR6AbstractHostageMgr` | Engine.lib | Not exported |

For `Engine.dll`, this creates a wrinkle: our `.def` file (extracted from the original binary) lists symbols for these classes — copy constructors, `operator new` overloads, `StaticClass()` — but without `__declspec(dllexport)` on the class, the compiler never emits standalone copies of those inline functions. We comment them out in the `.def` with a note reserving the ordinal, and move on.

---

## The Constructor Access Puzzle

MSVC mangles access level into constructor symbols. A **public** default constructor gets the mangling `@@QAE@XZ`. A **protected** one gets `@@IAE@XZ`. Same function body, different symbol.

For every class in every module, we had to answer: *which access level did the original use?*

The `.def` file tells us. If it exports `@@QAE@XZ`, the constructor was public. If it exports `@@IAE@XZ`, protected. Some modules even export *both* for the same class (though not in R6Game's case — there it's always one or the other).

Getting this wrong causes the linker to look for a symbol that doesn't exist:

```
error LNK2019: unresolved external symbol
  __imp_??0UConsole@@QAE@XZ    ← looking for public
  but Engine.lib has:
  __imp_??0UConsole@@IAE@XZ    ← which is protected
```

The fix is surgical: declare exactly the access level the original used. For `UConsole`, that means adding `protected: UConsole() {}` explicitly. The compiler-generated implicit constructor would be public (which is wrong), so we have to override it.

This pattern repeated for `AInfo`, `AR6ActionPointAbstract`, `UInteraction`, `UPlayerInput`, and `UCheatManager` — all base classes whose constructors are protected in the import library.

---

## Event Functions: The Generator Bug

Unreal's `ProcessEvent` mechanism bridges the gap between UnrealScript and C++. When a script function needs to call native code, it goes through a struct-based calling convention:

```cpp
void UR6GSServers::eventFillCreateGameInfo(AGameInfo *pGameInfo,
                                           ALevelInfo *pLevelInfo)
{
    struct {
        AGameInfo *pGameInfo;
        ALevelInfo *pLevelInfo;
    } Parms;
    Parms.pGameInfo = pGameInfo;
    Parms.pLevelInfo = pLevelInfo;
    ProcessEvent(FindFunctionChecked(R6GAMESERVICE_FillCreateGameInfo),
                 &Parms);
}
```

Our code generator had a bug: it emitted the *types* in the parameter struct but not the *names*:

```cpp
    struct {
        AGameInfo *;     // ← anonymous member?!
        ALevelInfo *;    // ← MSVC says no
    } Parms;
    Parms. = ;           // ← syntax error
```

Quick to spot, tedious to fix — R6GameService alone had 10 event functions that needed manual repair.

---

## R6Engine: The Big One

At 4,900+ lines of header and 300+ lines of method stubs, R6Engine is the largest module in Phase 6. It defines the core game actors:

- **Pawns**: `AR6Pawn`, `AR6Rainbow`, `AR6Terrorist`, `AR6Hostage`
- **AI**: `AR6TerroristAI`, `AR6TerroristMgr`, `AR6HostageMgr`
- **World**: `AR6Door`, `AR6ClimbableObject`, `AR6MissionObjective`
- **Interaction**: `AR6RainbowTeam`, `AR6DeploymentZone`, `AR6DoorIcon`
- **Charts**: `R6Charts` — ballistic penetration tables

That last one — `R6Charts` — was a fun puzzle. The SDK header declared its static members like functions:

```cpp
static struct stBodyPart m_stKillChart();    // ← function declaration!
```

That trailing `()` turns a static member variable into a function returning `stBodyPart`. The real type is just `static struct stBodyPart m_stKillChart;` — no parentheses. And the penetration factor members turned out to be *pointers to arrays*:

```cpp
static float (*m_fHumanSidePenetrationFactors)[2];  // pointer to float[2]
static int   (*m_iHumanPenetrationTresholds)[3];    // pointer to int[3]
```

`undname.exe` confirmed it. The mangled symbol decodes to `float (*)[2]`, not `float[2]`. A subtle but critical distinction — one is a pointer you can set to NULL, the other is a fixed-size buffer.

---

## The Scoreboard

Here's Phase 6 by the numbers:

| Module | Classes | Exports | Lines of Header | DLL Size |
|--------|---------|---------|-----------------|----------|
| R6Abstract | 32 | 350 | 958 | 55 KB |
| R6Weapons | 14 | 124 | 448 | 39 KB |
| R6Engine | 151 | 826 | 4,956 | 315 KB |
| R6Game | 78 | 186 | 1,175 | 148 KB |
| R6GameService | 5 | 106 | 413 | 53 KB |

That's 280 classes, 1,592 exports, and ~8,000 lines of header declarations across five modules.

---

## What's Next?

With all twelve DLLs building, the next frontier is the **launch executable** — `RavenShield.exe`. This is the thin wrapper that initialises the engine, loads the correct DLLs, and hands off to the game loop. After that, the goal shifts from *making things compile* to *making things run*: testing the rebuilt DLLs against real game data, comparing behaviour with the retail binaries, and chasing down the inevitable divergences.

We've gone from zero to twelve modules. The bones are in place. Now we start giving them muscles.
