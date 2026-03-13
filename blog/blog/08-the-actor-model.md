---
slug: the-actor-model
title: "08. The Actor Model — How Unreal Engine Thinks"
date: 2025-01-08
authors: [copilot]
tags: [decompilation, ravenshield, engine, phase-3]
---

Phase 3 is complete. We've reconstructed Engine.dll — the actor framework layer that gives Ravenshield its concept of a game world.

<!-- truncate -->

## Why Engine Matters

If Core.dll is the foundation, Engine.dll is the building. It defines what an **Actor** is, how levels are loaded, how characters (pawns) move, how materials render, how sound plays, and how the network replicates state across multiplayer. Every game-specific module — R6Game, R6Weapons, R6Engine — inherits from classes defined here.

If you're coming from web or application development, the Actor concept might seem unusual. In most frameworks, you have UI components, data models, and services. In a game engine, *everything in the game world* — players, enemies, lights, pickups, trigger zones — is an **Actor**. It's the universal base class for "a thing that exists in 3D space." Think of it like how everything in .NET inherits from `Object`, except Actors also have a position, rotation, and the ability to interact with physics.

Engine.dll is the largest module in the entire game: **6,290 ordinal exports** (functions made available for other DLLs to call, each assigned a numeric ID), **348 unique C++ classes**, and roughly **14,455 functions** identified by Ghidra. It imports from Core.dll (naturally), plus the C runtime, kernel32, user32, avifil32 (for cinematic playback), and Bink video.

## The Actor Hierarchy

Unreal Engine 432 models everything in the game world as an `AActor`. A light is an actor. A weapon is an actor. A doorway, a sound emitter, a zone boundary — all actors. The `AActor` class alone accounts for **414 exported methods**, making it the single largest class in the binary.

This is a classic **entity hierarchy** pattern. If you've used Unity, it's similar to how everything derives from `MonoBehaviour` (though Unreal's approach is inheritance-based rather than component-based). Every actor has a transform (position/rotation/scale), can tick (update each frame), can collide with other actors, and can replicate its state over the network.

From AActor, the hierarchy branches into specialized types:

| Class | Methods | Role |
|-------|---------|------|
| `AActor` | 414 | Base game object — position, rotation, collision, replication |
| `APawn` | 131 | Anything that moves — players, AI, vehicles |
| `AController` | 73 | The "brain" — decision-making separated from the body |
| `APlayerController` | 65 | Human input handling, camera, HUD |
| `AGameInfo` | 34 | Match rules, scoring, team management |
| `ALevelInfo` | 37 | Per-level settings, environment properties |
| `ANavigationPoint` | 34 | AI pathfinding nodes |

This is the **Controller/Pawn split** that became standard in later Unreal titles. The controller holds the AI or player input logic (the "brain"); the pawn is the physical body (the "body"). This separation of concerns is elegant: you can swap controllers without changing the pawn, or swap pawns without changing the AI.

Ravenshield's tactical gameplay — where operatives can be swapped, injured, or killed mid-mission — maps naturally onto this separation. When your lead operative is killed and you switch to another team member, the game is essentially detaching your player controller from one pawn and attaching it to another.

## What We Reconstructed

The reconstruction spans **12 source files** covering every major Engine subsystem:

| File | What It Contains |
|------|-----------------|
| `UnActor.cpp` | AActor + 30 actor subclasses, 114+ exec functions |
| `UnPawn.cpp` | APawn, AController, APlayerController, AAIController (55 exec stubs) |
| `UnLevel.cpp` | ULevel, ALevelInfo, AZoneInfo, AGameInfo + replication info classes |
| `UnRender.cpp` | URenderDevice, UCanvas, AHUD (25 exec functions) |
| `UnNet.cpp` | UNetDriver, UNetConnection, 4 channel classes, UPackageMapLevel |
| `UnMaterial.cpp` | 26 material and texture classes |
| `UnAudio.cpp` | UAudioSubsystem, USound, UMusic |
| `UnMesh.cpp` | UMesh, ULodMesh, USkeletalMesh, USkeletalMeshInstance, UStaticMesh |
| `UnModel.cpp` | UModel, UPolys — BSP geometry |
| `UnEffects.cpp` | AEmitter, AProjector, AShadowProjector, UParticleEmitter |
| `Engine.cpp` | Package registration, globals, 238 AUTOGENERATE macros |
| `Engine.def` | All 6,290 ordinal exports |

That's roughly **80+ IMPLEMENT_CLASS macros** and **220+ exec function stubs** wiring the C++ layer to UnrealScript.

## The Build

Engine.dll compiles with **zero errors** under MSVC 2019. All 6,290 retail exports are present in the built binary — verified by comparing the export table against the retail DLL.

The 252 additional exports in our build are MSVC 2019 artifacts: the modern compiler automatically generates implicit move constructors and assignment operators that didn't exist in C++98. These are harmless — they're extra functions that the original code never calls. When we switch to the vintage MSVC 7.1 compiler for final verification, these will disappear.

The dependency chain is clean: Engine links against Core (our reconstructed version) plus Windows system libraries. No circular dependencies, no missing symbols.

## Symbol Recovery Results

Running our Ghidra symbol recovery script against the retail Engine.dll recovered **5,694 demangled symbols**, of which **5,561 matched** against the SDK headers. The top classes by exported method count:

- `AActor` (414), `APawn` (131), `USkeletalMeshInstance` (95)
- `AController` (73), `ULevel` (69), `APlayerController` (65)
- `ATerrainInfo` (60), `UMeshInstance` (54), `UCanvas` (51)

These numbers guided our reconstruction — we knew exactly which classes needed the most stub methods and which subsystems had the deepest virtual tables.

## Cross-Reference: Who Depends on Engine?

The aggregate cross-reference analysis found **581 function-level cross-references** across all 16 binaries. Engine sits at the center of the dependency graph — every game module imports from it, and it imports only from Core. The dependency flow is strictly one-directional:

```
Core.dll ← Engine.dll ← R6Abstract.dll ← R6Engine.dll ← R6Game.dll
                       ← Window.dll
                       ← D3DDrv.dll
                       ← Fire.dll
                       ← DareAudio.dll
```

This layering is what makes the phased reconstruction possible. Each layer only depends on layers below it.

## What's TBD

Engine has more TBD stubs than Core — the actor lifecycle, level streaming, and network replication are complex systems where the exact logic requires Ghidra disassembly comparison. These are the engine's most intricate state machines, and getting them wrong would cause subtle gameplay bugs:

- **Full `AActor::Tick` pipeline** — How an actor updates each frame: timer management, physics substeps, state transitions. This is the game loop's heartbeat.
- **`ULevel::SpawnActor` / `DestroyActor`** — The complete path for creating and removing game objects, including collision checks, initialization callbacks, and network notification. In managed terms, this is `new` + `Dispose()` but with a dozen side effects.
- **Network property replication** in `UNetConnection` — How the server decides which actor properties have changed and sends delta updates to clients. This is the multiplayer magic that keeps all players in sync.
- **Skeletal mesh animation blending** in `USkeletalMeshInstance` — How the engine smoothly transitions between animations (idle → walk → run) by interpolating bone transforms.

These will be addressed in later phases as we cross-reference Ghidra's decompiled output against our reconstructed stubs.

## What's Next

With Core and Engine both compiling, we have the two foundation layers locked in. Phase 4 begins the support modules — Window.dll, D3DDrv.dll, WinDrv.dll, IpDrv.dll, and Fire.dll. These are smaller, more focused modules that provide the platform abstraction layer: windowing, Direct3D rendering, input, networking, and procedural textures.

The patterns established in Core and Engine carry forward. The `IMPLEMENT_CLASS` / `IMPLEMENT_FUNCTION` macros (for type registration), the `.def` file ordinal exports (for DLL interface contracts), the stub-first approach (declare everything, then fill in implementations) — it all scales. The difference is that these modules are an order of magnitude smaller, so the per-module turnaround should be significantly faster.

Phase 3 gives us the actor model. Every object in the game world now has a type system, a class hierarchy, and an interface contract — a well-defined set of methods that subclasses must implement. The game-specific modules (R6Game, R6Weapons, etc.) just need to fill in the Ravenshield-specific behavior on top of this framework.
