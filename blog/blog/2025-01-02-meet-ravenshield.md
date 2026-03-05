---
slug: meet-ravenshield
title: "Meet Ravenshield: A 2003 Tactical Shooter Built on Unreal"
authors: [rvs-team]
tags: [ravenshield, decompilation]
---

Rainbow Six 3: Raven Shield launched in March 2003. It was the last *classic* Rainbow Six — the one where a single bullet could end your mission, where planning actually mattered, and where your heart rate spiked every time you stacked up on a door. Let's talk about what's under the hood.

<!-- truncate -->

## The Game in a Nutshell

Ravenshield (we call it RVS for short) is a **tactical first-person shooter** developed by Ubi Soft Montreal. You lead a team of counter-terrorism operatives through missions spanning embassies, oil platforms, meat-packing plants, and a memorable Venezuelan village.

What set it apart from other shooters of the era:

- **One-shot lethality.** No bullet sponges. Realistic damage means every firefight is tense.
- **Pre-mission planning.** You draw waypoints on a floor plan before the mission starts. Your AI teammates follow them autonomously.
- **Cooperative multiplayer.** Up to 16 players tackling missions together, plus adversarial modes.

## Why Ravenshield?

It's a compelling decompilation target for several reasons:

### Manageable Scope
The game ships as **15 DLLs and 1 EXE**. That's big, but not *impossibly* big. Each DLL has a clear responsibility — rendering, audio, weapons, game modes, networking — which means we can tackle them one at a time.

### Rich Reference Material
Ravenshield was built on **Unreal Engine 2**, and we have access to the UT99 (Unreal Tournament) source code for the base `Core` and `Engine` layers. Ubisoft also shipped a C++ SDK with headers that describe class layouts, exported functions, and memory alignment.

Between those two reference points, we can identify a *huge* percentage of the code before we even open Ghidra.

### Active Community
The game still has players — more than two decades later. A decompiled, rebuildable codebase would unlock modifications that the UnrealScript-only modding layer could never achieve: custom rendering, new networking protocols, engine-level bug fixes.

## Anatomy of the Game

Here's what the `system/` folder looks like at a high level:

| Binary | Role |
|---|---|
| `RavenShield.exe` | Launcher / bootstrap |
| `Core.dll` | Object system, names, memory, serialization |
| `Engine.dll` | Actors, rendering pipeline, physics, networking |
| `D3DDrv.dll` | Direct3D 8 rendering |
| `WinDrv.dll` | Windows viewport and input |
| `DareAudio.dll` | DARE audio subsystem |
| `Fire.dll` | Procedural texture generation |
| `IpDrv.dll` | TCP/IP networking + GameSpy |
| `R6Abstract.dll` | Base classes for R6 game systems |
| `R6Engine.dll` | R6-specific engine (AI, pawns, doors, interactions) |
| `R6Game.dll` | Game modes, missions, operative management |
| `R6Weapons.dll` | Ballistics, recoil, firing modes |
| `R6GameService.dll` | Server browser, mods, patching |
| `Window.dll` | Window management subsystem |

Plus a few more odds and ends. The R6-prefixed DLLs are Ubisoft's custom code layered on top of Epic's Unreal Engine base.

## The Build Stack (Circa 2003)

The original game was compiled with:

- **Microsoft Visual C++ .NET 2003** (MSVC 7.1) — the compiler
- **Windows Server 2003 Platform SDK** — system headers and libraries
- **DirectX 8 SDK** — rendering and audio APIs
- **C++98** with some MSVC extensions (`#pragma pack(push,4)` everywhere, `/Zc:wchar_t-`)

We'll use the exact same compiler for our rebuild. Why? Because different compilers — or even different *versions* of the same compiler — produce subtly different machine code. If we want to verify our decompilation is correct, we need byte-level comparison, and that requires matching the original toolchain.

## What's Next?

In the next post, we'll tour the toolbox: Ghidra for decompilation, CMake for builds, custom Python scripts for binary comparison, and the delightfully retro MSVC 7.1 development environment.
