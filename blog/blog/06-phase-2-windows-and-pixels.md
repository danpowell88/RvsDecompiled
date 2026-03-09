---
slug: phase-2-windows-and-pixels
title: "06. Phase 2 — A Window Into The World (and Tidying Up the Source Tree)"
date: 2025-01-06
authors: [rvs-team]
tags: [decompilation, ravenshield, progress, windrv, directinput, rendering, organisation]
---

Two milestones in one session: Phase 2 of the stub plan is functionally complete, and the entire source tree now follows the Unreal Tournament 99 `Inc/`/`Src/` convention. The build still compiles cleanly — all 19 DLLs and the executable come out the other end.

<!-- truncate -->

## What Is Phase 2?

Phase 1 was about cutting the build free from retail import libraries. Phase 2 is about making the game *do something visible*: create a window, initialise Direct3D, accept keyboard and mouse input, and draw pixels on screen.

That means real code in three areas: the Windows viewport driver (WinDrv), the canvas/HUD rendering path, and the Window framework cleanup.

## WinDrv: Where Windows Meets Unreal

If you have ever wondered how a game from 2003 actually creates a window and reads your keyboard, the answer is surprisingly manual.

WinDrv is a thin module — only about 90 exported functions — but those functions bridge two very different worlds. On one side is the Unreal Engine's abstract viewport and input system. On the other is raw Win32: `CreateWindowW`, `PeekMessage`, `SetCapture`, `ClipCursor`, and Microsoft's DirectInput 8 API.

### The Viewport

Ravenshield is a single-viewport game. There is only ever one game window. So the viewport code uses a global `HWND` — no per-viewport window management, no multi-monitor support. `OpenWindow()` registers a window class, creates the window, and then immediately spins up DirectInput devices for the keyboard and mouse.

The window procedure delegates everything to `DefWindowProcW`. That might seem like a no-op, but it is intentional: all real input processing happens through DirectInput polling in `UpdateInput()`, not through window messages. The message pump in `UWindowsClient::Tick()` drains `WM_*` messages purely to keep Windows happy.

### DirectInput 8

If you are used to modern input frameworks, DirectInput 8 will feel like doing plumbing. You call `DirectInput8Create` to get an `IDirectInput8W` interface. Then for each device (keyboard, mouse) you call `CreateDevice`, `SetDataFormat`, `SetCooperativeLevel`, and `Acquire`.

Reading the keyboard is a call to `GetDeviceState` with a 256-byte array — one byte per key, where bit 0x80 means "pressed." The mouse is similar but returns a `DIMOUSESTATE` with relative X/Y deltas and button states.

The nice bit is that once you understand the pattern, implementing thirty methods is not as daunting as it sounds. Most viewport methods like `Minimize()`, `Maximize()`, `RestoreWindow()` are one-line calls to `ShowWindow` with the appropriate `SW_*` constant.

## Canvas: How the HUD Draws

Unreal's canvas system is how UnrealScript draws text, tiles, and 3D overlay lines onto the screen. Every HUD element you see — health bars, ammo counters, crosshairs — goes through `UCanvas` exec functions.

These exec functions unpack parameters from the UnrealScript virtual machine stack and then delegate to the render device. `execDrawText` calls `_DrawString` with a font and colour. `execDrawTile` calls `RenDev->DrawTile`. `execDraw3DLine` calls `RenDev->Draw3DLine`.

The pattern is consistent: unpack, validate, delegate. The canvas itself does not rasterize anything — it is a dispatch layer between script and the D3D backend.

## Window.dll Cleanup

The Window module had three residual opaque pragma redirects — symbols pointing to `dummy_stub_data` without any hint of what they represented. These were actually `__FUNC_NAME__` compiler artifacts: wide-character string blobs that MSVC 7.1 emitted as externally visible symbols, but modern MSVC keeps internal.

We replaced them with properly named blobs (`_gfn_WPropertiesCtor`, `_gfn_FTreeItemDtor`, `_gfn_LoadLocalizedMenu`) following the same pattern already established in Core and Engine. Not functionally important, but it means every remaining pragma in the project is now documented and understood.

## Source Tree Reorganisation

This one is about project hygiene rather than game functionality, but it matters for maintainability.

### The Problem

Until now, every module dumped all its files into a single flat directory:

```
src/engine/
    CMakeLists.txt
    Engine.cpp
    Engine.def
    Engine.h
    EngineClasses.h
    EnginePrivate.h
    EngineBatchImpl.cpp
    EngineBatchImpl2.cpp
    UnActor.cpp
    UnMaterial.cpp
    UnRender.cpp
    UnActor.cpp.bak
    UnMaterial.cpp.bak
    ...
```

Headers mixed with source, `.bak` recovery files sitting alongside production code, `.def` files next to everything. It worked, but it was untidy.

### The UT99 Convention

Epic's public source release for Unreal Tournament 99 uses a clean two-directory convention:

- **`Inc/`** — Public and private headers (`.h` files)
- **`Src/`** — Source files (`.cpp`) and module definition files (`.def`)

The `CMakeLists.txt` stays at the module root. Simple, consistent, discoverable.

### What We Did

Every one of the 16 modules was reorganised:

```
src/engine/
    CMakeLists.txt
    Inc/
        Core.h
        Engine.h
        EngineClasses.h
        EnginePrivate.h
        ...
    Src/
        Engine.cpp
        Engine.def
        EngineBatchImpl.cpp
        UnActor.cpp
        UnMaterial.cpp
        UnRender.cpp
        ...
```

All `.bak` files were deleted — those were Ghidra recovery snapshots that have been merged into the live source. Every `CMakeLists.txt` was updated to glob from `Inc/*.h` and `Src/*.cpp` instead of `*.cpp` and `*.h`. Cross-module include paths were updated (`src/engine` → `src/engine/Inc`). The `Engine_Dep` interface library's include path was updated in the root `CMakeLists.txt`.

One snag: the launcher's `FMallocWindows.h` had a relative include path (`../../sdk/...`) that broke when the file moved one directory deeper. A quick fix from `../../` to `../../../` and the build was green again.

## The Numbers

- **19 DLLs + 1 EXE** build cleanly from source
- **0 retail .lib references** in the build chain
- **16 modules** reorganised into `Inc/`/`Src/` layout
- **0 `.bak` files** remaining (all merged or discarded)
- **~30 WinDrv methods** implemented with real Win32/DirectInput logic
- **~15 Canvas exec functions** upgraded from empty stubs to render-device dispatch

## What Is Next

Phase 3 is where things get interesting: actor spawning, physics simulation, collision detection, and the animation system. That is where Ghidra becomes the primary tool rather than UT99 reference code, because the physics and pathfinding systems are where Ravenshield diverged most from stock Unreal.

The foundation is solid. The build is self-contained. The source is organised. Time to make the world move.
