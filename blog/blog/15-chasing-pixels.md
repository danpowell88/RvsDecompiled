---
slug: chasing-pixels
title: "15. Chasing Pixels — Reconstructing the D3D8 Render Pipeline"
date: 2025-01-15
authors: [rvs-team]
tags: [decompilation, ravenshield, d3d8, rendering, phase-9]
---

Phase 9 is where the project takes its biggest leap yet: rebuilding the Direct3D 8 rendering driver from scratch, auditing every stub in the codebase, and wiring up the final launcher connections that make `Engine->Init()` and `Engine->Tick()` actually call real code. This is the post where pixels start moving.

<!-- truncate -->

## The Render Device: A Bridge Between Worlds

If you've built anything with modern graphics APIs — Vulkan, Metal, DirectX 12 — you'll recognise the concept immediately: a *render device* is the abstraction that sits between the engine's "I want to draw this mesh with this material" and the GPU's "feed me vertex buffers and shader programs."

Ravenshield uses **Direct3D 8**, which is a fascinating historical artifact. Released in 2000, D3D8 was the first DirectX version to merge DirectDraw (2D) and Direct3D (3D) into a single unified API. Before D3D8, you needed a `DirectDraw` object for managing surfaces and display modes, then a separate `Direct3D` object for 3D rendering. D3D8 collapsed all of this into `IDirect3D8` and `IDirect3DDevice8`.

But it's still *very* different from what modern developers are used to:

```
Modern GPU API:                    | D3D8:
─────────────────────────────────  | ──────────────────────────────
Command buffers                    | Immediate mode (draw calls execute now)
Pipeline state objects             | Individual SetRenderState() calls
Descriptor sets / bind groups      | SetTexture(stage, texture)
HLSL → SPIR-V → compiled          | Assembly pixel/vertex shaders
Explicit memory management         | Driver manages everything
```

Each draw call in D3D8 is a *synchronous* command to the GPU. There's no batching, no command list recording. You call `DrawPrimitive()` and the GPU does it. Right now. The entire frame's rendering happens between `BeginScene()` and `EndScene()`, with a `Present()` at the end to flip the swap chain.

## What 44 Exports Tell You

The retail `D3DDrv.dll` exports exactly 44 symbols — all belonging to a single class: `UD3DRenderDevice`. These are the *only* entry points the engine uses to talk to the renderer:

| Export | Purpose |
|--------|---------|
| `SetRes` | Create or reset the D3D device at a given resolution |
| `Lock` / `Unlock` | Begin and end a frame (BeginScene / EndScene) |
| `Present` | Flip the swap chain (show the frame) |
| `Flush` | Clear texture caches |
| `GetCachedResource` | Look up a texture/surface in the resource hash |
| `GetPixelShader` / `GetVertexShader` | Retrieve cached shader programs |
| `OpenVideo` / `CloseVideo` / `DisplayVideo` | Bink video playback |
| `UpdateGamma` / `RestoreGamma` | Monitor gamma correction |
| `GetAvailableResolutions` | Enumerate display modes |
| `ReadPixels` | Screenshot: copy back buffer to CPU memory |

And that's it. The entire D3D8 pipeline — device creation, texture uploading, shader compilation, material rendering, Bink video decode — is hidden behind these 44 functions.

## The Ghidra Puzzle

Here's where things get interesting. When you run Ghidra on the retail D3DDrv.dll, you get about 22,000 lines of decompiled code. But there's a catch: the Ghidra export script that was used to dump the analysis *excluded* the named exported methods. It only captured the unnamed internal functions — the ones Ghidra calls things like `FUN_10001020` or `FUN_10002eb0`.

This means we have detailed decompilation of the *guts* of the renderer — the material compilation pipeline (7,231 bytes!), the SSE-optimised memory copy routine (480 bytes of hand-tuned assembly), the texture stage management logic — but **not** the actual implementations of `SetRes`, `Lock`, `Present`, etc.

So how do you reconstruct 44 methods without their source code?

### The UT99 Rosetta Stone

Epic Games released the full source code of Unreal Tournament 99, including its D3D7 rendering driver (`Direct3D7.cpp`, 3,005 lines). Since Ravenshield's engine is a direct descendant of UT99's Unreal Engine 1, the D3D7 driver is essentially the *previous version* of what D3DDrv.dll implements.

The D3D7 → D3D8 API delta is well-documented:

| D3D7 | D3D8 |
|------|------|
| `IDirectDraw7 + IDirect3D7` | `IDirect3D8` (merged) |
| `IDirectDrawSurface7` (textures) | `IDirect3DTexture8` |
| DWORD-based render states | Same, but different enum names |
| No pixel shaders | `CreatePixelShader()` returns a DWORD handle |
| Fixed-function TnL only | Hardware vertex shaders available |
| Gamma via `IDirectDrawGammaControl` | `SetGammaRamp()` on the device |

By taking the UT99 D3D7 driver as a structural template and applying the D3D8 API differences, we can reconstruct each exported method with reasonable confidence. The Ghidra internal analysis then provides validation: offset layouts (e.g., "render pass is 0x438 bytes with 8 texture stages of 0x80 bytes each"), resource hash table size (4096 entries), and shader cache architecture.

## Architecture of the Reconstruction

The D3D8 module now consists of five files:

- **D3DDrvPrivate.h** — Private header: Win32/D3D8/D3DX includes, enums, forward declarations
- **D3DDrvClasses.h** — The `UD3DRenderDevice` class with 22 virtual methods, 3 non-virtual helpers
- **FD3DResource.h** — GPU resource cache entry: `CacheID`, hash chain, `IDirect3DBaseTexture8*`
- **FD3DShaders.h** — Pixel and vertex shader wrappers holding D3D8 DWORD handles
- **FD3DRenderInterface.h** — The render interface returned by `Lock()`, with texture stage state, render passes, and transformation matrices
- **D3DDrv.cpp** — The 1,300+ line implementation of all 44 exports

### The Resource Cache

Every texture, surface, and render target in the engine is identified by a 64-bit `CacheID`. These are stored in a 4096-slot hash table — the same design used by UT99's `FTexInfo` cache. When the engine needs a texture, `GetCachedResource()` does a hash lookup:

```cpp
INT HashIndex = (INT)((CacheID >> 0) ^ (CacheID >> 16) ^ (CacheID >> 32)) & 0xFFF;
```

If found, it returns the existing D3D8 texture reference. If not, it creates a new cache entry and the engine uploads the texture data. Simple, fast, and O(1) average case.

### Bink Video: A Library Lost to Time

Ravenshield's intro cinematics and in-game briefing videos use RAD Game Tools' Bink codec. The retail binary statically imports 8 functions from `binkw32.dll`:

- `BinkOpen` / `BinkClose` — Open and close video files
- `BinkDoFrame` / `BinkNextFrame` / `BinkWait` — Decode and advance frames
- `BinkCopyToBuffer` — Copy decoded pixels to a system-memory buffer

Since we don't have the Bink SDK (it was commercially licensed), the reconstruction loads these functions dynamically via `LoadLibrary` + `GetProcAddress` at runtime. If `binkw32.dll` isn't present, video playback is gracefully disabled.

## The 3,930-Stub Audit

Phase 9B was a reckoning. We ran a comprehensive grep across every source file looking for empty function bodies, `EXEC_STUB` macros, `return 0` stubs, and TODO markers. The result?

**3,930+ stubs** across 18 modules.

The breakdown is sobering:

| Category | Count | Notes |
|----------|-------|-------|
| Linker stubs (`/alternatename` pragmas) | 2,612 | Engine symbol redirections |
| UnrealScript native stubs (`EXEC_STUB`) | 365 | Script-callable functions |
| Sound system stubs (SNDDSound3D + SNDext) | 409 | Entirely empty |
| WinDrv viewport stubs | 43 | Critical path blockers |
| R6Engine virtual overrides | 200+ | R6-specific game logic |

The good news: most of these stubs are *correct*. A linker stub that redirects to `dummy_stub_func` is doing exactly what it needs to do — providing a symbol so the DLL links, while the actual implementation lives in the retail DLL loaded at runtime. The `EXEC_STUB` natives are placeholders for UnrealScript functions that will be reconstructed in a later phase.

The audit lives in `STUB_AUDIT.md` at the repo root.

## Before The First Frame: Wiring Up the Game Loop

The most impactful change in Phase 9 is invisible: making the launcher actually call the engine.

In Phase 8, the game loop looked like this:

```cpp
while (GIsRunning) {
    // TODO: Engine->Tick(DeltaTime);
    if (GWindowManager)
        GWindowManager->Tick(DeltaTime);
    // TODO: Engine->GetMaxTickRate();
    FLOAT MaxTickRate = 60.0f; // Placeholder
}
```

The problem was that `Engine->Init()`, `Engine->Tick()`, and `Engine->GetMaxTickRate()` are **virtual method calls**, and the compiler needs to know the exact vtable slot to generate a correct indirect call. If the virtual method declaration order in `UEngine` doesn't exactly match the retail Engine.dll's vtable, the game will call the wrong function and crash.

We reconstructed the full 54-slot vtable by reading raw function pointers from the retail DLL in Ghidra:

| Slot | Offset | Method |
|------|--------|--------|
| 25 | 0x064 | `Tick(FLOAT)` |
| 28 | 0x070 | `Init()` |
| 43 | 0x0AC | `GetMaxTickRate()` |

With the correct virtual method ordering in `UEngine`'s declaration, these calls now compile to the right vtable offsets — and the game loop is live:

```cpp
Engine->Init();              // Creates client, audio, renderer
// ...
Engine->Tick(DeltaTime);     // Advances the world state
FLOAT MaxTickRate = Engine->GetMaxTickRate();
```

### Running.ini: Crash Recovery

A small but important detail: the retail launcher creates a file called `Running.ini` when the game starts and deletes it on clean exit. If the file exists on startup, it means the previous run crashed. The reconstruction now detects this and offers safe-mode startup — just like the original.

## What's Next

The renderer has its skeleton. The game loop calls real engine code. The audit gives us a roadmap of every remaining stub in the codebase.

Phase 10 begins the long road of UnrealScript native function reconstruction — turning those 365 `EXEC_STUB` entries into actual gameplay logic. That's where things like `Actor.SetLocation()`, `Pawn.MakeNoise()`, and `Level.SpawnActor()` start working.

We're getting closer to pixels on screen. One vtable slot at a time.
