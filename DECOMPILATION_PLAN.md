# Plan: Ravenshield Full Game Decompilation & Reconstruction

Decompile all Rainbow Six: Ravenshield game runtime binaries (15 DLLs + 1 EXE) using Ghidra, rebuild into maintainable C++ using MSVC 7.1 for initial byte parity, then progressively refactor for readability. The workspace already contains exceptional reference material: the Raven_Shield_C_SDK (21 reverse-engineered headers + 13 import libs), full UT99 public source, 1000+ UnrealScript files from the 1.56 leak, the complete GameSpy SDK, and the era-correct MSVC 7.1 toolchain with matching Windows/DirectX SDKs. Third-party DLLs (binkw32, OpenAL, ogg/vorbis, eax, MSVC runtimes) remain external dependencies. A Docusaurus blog tracks milestones.

---

## Scope

**16 binaries to decompile & reconstruct:**

| Category | Binaries | Reference Quality |
|----------|----------|-------------------|
| Core Engine | `Core.dll`, `Engine.dll`, `Window.dll` | Excellent (UT99 source + 432Core headers) |
| Game Logic | `R6Abstract.dll`, `R6Engine.dll`, `R6Game.dll`, `R6Weapons.dll`, `R6GameService.dll` | Excellent (C SDK headers + full UnrealScript) |
| Drivers | `D3DDrv.dll`, `WinDrv.dll`, `IpDrv.dll` | Good (UT99 D3D7 driver + GameSpy SDK) |
| Audio | `DareAudio.dll`, `DareAudioRelease.dll`, `DareAudioScript.dll`, `SNDDSound3D*.dll`, `SNDext*.dll` | Low (no source reference — pure Ghidra) |
| Effects | `Fire.dll` | Excellent (UT99 source) |
| Executable | `RavenShield.exe` | Good (UT99 launcher reference) |

**External deps (NOT decompiled):** binkw32, OpenAL32, ogg/vorbis/vorbisfile, eax, MFC71, msvcp71, msvcr71, MSVCRT

---

## Phase 0: Pre-Work — Environment & Tooling ✅ COMPLETE

### 0A. Repository & Project Structure
1. Initialize git repo with `.gitignore` (exclude retail binaries, Ghidra databases, build output)
2. Create source tree: `src/{core,engine,window,r6abstract,r6engine,r6game,r6weapons,r6gameservice,d3ddrv,windrv,ipdrv,dareaudio,fire,launch}/`
3. Create tooling directories: `ghidra/{scripts,exports,project}/`, `tools/{compare,import}/`, `blog/`
4. Commit: *"Initial project structure"*

### 0B. Ghidra Installation & Plugins
1. Install Ghidra 11.x + JDK 21
2. Install plugins: C++ decompiler exporter, MSVC mangling support, Python scripting bridge
3. Create Ghidra project at `ghidra/project/RavenShield.gpr`

### 0C. Ghidra Type Libraries from SDK *(highest-impact pre-work step)*
1. Parse all 21 headers from `sdk/Raven_Shield_C_SDK/inc/` into a Ghidra Data Type Archive — these define all class layouts, vtable shapes, struct sizes, and enum values with `#pragma pack(push,4)`
2. Parse 50+ headers from `sdk/Raven_Shield_C_SDK/432Core/Inc/` — defines `FName`, `UObject`, `UClass`, `FVector`, `FRotator`, `FMatrix`, memory allocators, file managers
3. Parse 98 headers from `sdk/Ut99PubSrc/Core/Inc/` and `sdk/Ut99PubSrc/Engine/Inc/` — closest open-source engine reference
4. Parse Windows SDK + DirectX 8 headers from `tools/toolchain/winsdk/Include/` and `tools/toolchain/dxsdk/Include/`
5. Build Ghidra script `ghidra/scripts/apply_types.py` to auto-apply these type libraries to analyzed binaries

### 0D. Import Libraries for External Dependencies
1. Run `dumpbin /exports` on each external DLL → generate `.def` files → `lib /def:` to produce `.lib` files
2. Verify against existing 13 `.lib` files in `sdk/Raven_Shield_C_SDK/lib/`

### 0E. CMake Build System
1. Root `CMakeLists.txt` targeting MSVC 7.1 — C++98, `/Zc:wchar_t-`, `-D_UNICODE -DUNICODE`, `#pragma pack(push,4)` enforcement
2. Include paths: 432Core/Inc, Ut99PubSrc/Core/Inc, Ut99PubSrc/Engine/Inc
3. Link paths: Raven_Shield_C_SDK/lib/, external import libs
4. Per-module `CMakeLists.txt` stubs (one per DLL target)
5. Reference build pattern from `sdk/Ut99PubSrc/CMakeLists.txt` — `add_library(MODULE)`, `target_compile_definitions(ThisPackage=...)`, `target_link_libraries(Core Engine)`

### 0F. Binary Comparison Tooling
1. `tools/compare/bindiff.py` — section-level byte comparison (.text, .rdata, .data), reports match % per function
2. `tools/compare/funcmatch.py` — function-level instruction comparison using export table offsets, normalized for relocations

### 0G. Docusaurus Blog
1. ✅ Initialize Docusaurus 3.x at `blog/`
2. ✅ Posts: *"What Is Decompilation?"*, *"Meet Ravenshield"*, *"The Toolbox"*

---

## Phase 1: Ghidra Analysis — Batch Processing ✅ COMPLETE

### 1A. Batch Import
1. ✅ Write `ghidra/scripts/batch_import.py` — headless import of all 16 binaries, auto-analysis, type library application
2. ✅ Run `analyzeHeadless` against all binaries
3. ✅ Generate per-binary report: function count, export table, string references, import table — 16/16 JSON reports in `ghidra/exports/reports/`

### 1B. Symbol Recovery
1. ✅ Write `ghidra/scripts/symbol_recovery.py` — match MSVC mangled export names (`?Func@Class@@...`) against SDK headers — 16/16 symbol reports generated
2. ✅ Write `ghidra/scripts/cross_reference.py` — build inter-DLL dependency graph from import tables — 16/16 per-binary xref reports + aggregate
3. ✅ Generate function-level cross-reference matrix showing exactly which DLL calls which — 581 function-level cross-references identified

### 1C. UT99 Source Matching *(Core.dll and Engine.dll only)*
1. ✅ Write `ghidra/scripts/ut99_matcher.py` — compare decompiled functions against UT99 source using string literals, constants, call patterns
2. ✅ Flag functions as: identical to UT99 / modified from UT99 / unique to Ravenshield — 2/2 reports generated (0% match expected — UT99 public source is headers-only)
3. Functions matching UT99 can be directly ported from source — massive time savings

### 1D. Export Raw Decompilation
1. ✅ Write `ghidra/scripts/export_cpp.py` — export per-class `.cpp`/`.h` files to `ghidra/exports/{module}/` — 16/16 binary directories exported
2. This is the raw starting material, NOT final code

Blog Post: *"First Contact — What Ghidra Found"* ✅ Written

---

## Phase 2: Core.dll — Foundation Layer ✅ COMPLETE

Zero game dependencies. Every other module depends on Core. Best UT99 reference coverage.

**Status:** Reconstructed ~9,900 lines across 20 source files in `src/core/`.

**Conversion order (sub-components, least deps first):**
1. ✅ Memory subsystem — `FMallocWindows`, `FMallocAnsi` (standalone)
2. ✅ Output devices — `FOutputDeviceFile`, `FOutputDeviceWindowsError` (minimal deps)
3. ✅ File managers — `FFileManagerWindows`, `FFileManagerGeneric`
4. ✅ Name table — `FName`, `FNameEntry` (hash table, 4096 buckets)
5. ✅ Math library — `FVector`, `FRotator`, `FPlane`, `FMatrix`, `FQuat`
6. ✅ Object system — `UObject`, `UClass`, `UField`, `UProperty`
7. ✅ Package system — `UPackage`, `ULinker`, `ULinkerLoad/Save`
8. ✅ Script VM — `FFrame`, bytecode interpreter, ~230 native functions
9. ✅ Serialization — `FArchive`, `FCompactIndex`, file readers/writers
10. ✅ Miscellaneous — `UCommandlet`, `UTextBuffer`, `USystem`, `ULanguage`

~10 commits. Blog Post: *"Building the Foundation — Core.dll"* ✅ Written

---

## Phase 3: Engine.dll — Actor Framework ✅ COMPLETE

Required by all game modules. Largest module (~6,290 exports, ~238 autoclass registrations).

**Status:** Builds with 0 errors (3,569 warnings). All 6,290 retail exports present. 348 unique classes, 5,694 symbols recovered.

| File | Classes | Exec Functions | Status |
|------|---------|---------------|--------|
| `EnginePrivate.h` | — | — | ✅ Done |
| `Engine.cpp` | IMPLEMENT_PACKAGE + globals + AUTOGENERATE | — | ✅ Done |
| `UnActor.cpp` | AActor + 30 actor subclasses | 114+ indexed + ~80 INDEX_NONE | ✅ Done |
| `UnPawn.cpp` | APawn, AController, APlayerController, AAIController | 55 (49 indexed) | ✅ Done |
| `UnLevel.cpp` | ULevelBase, ULevel, ALevelInfo, AZoneInfo, AGameInfo + 4 RepInfo | 18 | ✅ Done |
| `UnRender.cpp` | URenderDevice, UCanvas, AHUD | 25 | ✅ Done |
| `UnNet.cpp` | UNetDriver, UNetConnection, 4 channel classes, UPackageMapLevel | 0 (virtual only) | ✅ Done |
| `UnMaterial.cpp` | 25 material/texture classes | 0 (virtual only) | ✅ Done |
| `UnAudio.cpp` | UAudioSubsystem, USound, UMusic | 0 (virtual only) | ✅ Done |
| `UnMesh.cpp` | UMesh, ULodMesh, USkeletalMesh, USkeletalMeshInstance, UStaticMesh, UStaticMeshInstance | 0 (virtual only) | ✅ Done |
| `UnModel.cpp` | UModel, UPolys | 0 (virtual only) | ✅ Done |
| `UnEffects.cpp` | AEmitter, AProjector, AShadowProjector, UParticleEmitter | 7 | ✅ Done |
| `Engine.def` | — (6,290 ordinal exports) | — | ✅ Done |

**Total:** 12 main source files + 6 supporting files (EngineExtra.cpp, EngineEvents.cpp, EngineStubs1-4.cpp), ~200+ IMPLEMENT_CLASS macros, ~220+ exec function stubs, 6,290 export ordinals.

Blog Post: *"The Actor Model — How Unreal Engine Thinks"* ✅ Written

---

## Phase 4: Support Modules ✅ COMPLETE

| Module | Size | Key Reference | Status |
|--------|------|--------------|--------|
| **Fire.dll** | Tiny (7 classes) | UT99 source equivalent | ✅ Built |
| **Window.dll** | Small | UT99 Window source | ✅ Built |
| **IpDrv.dll** | Medium (5 UC classes + GameSpy) | `sdk/GameSpySDK/src/GameSpy/` full source | ✅ Built |

**Fire.dll:** 4 source files (`FirePrivate.h`, `FireClasses.h`, `Fire.cpp`, `Fire.def`). FSpark/FDrop/KeyPoint operator= stubs, UFractalTexture::Init. Links to Core.lib + Engine.lib.

**Window.dll:** 4 source files (`WindowPrivate.h`, `WindowClasses.h`, `Window.cpp`, `Window.def`). Wraps the UT99 Window.h framework with R6 compatibility shims: appMsgf R6 overload + macro, FPreferencesInfo move→copy ALTERNATENAME redirects, 20 SuperProc statics, 15 HBRUSH globals, Shell_NotifyIcon/SHGetSpecialFolderPath wrappers, UWindowManager class. 319 R6-specific .def exports commented out (pending reconstruction).

**IpDrv.dll:** 4 source files (`IpDrvPrivate.h`, `IpDrvClasses.h`, `IpDrv.cpp`, `IpDrv.def`). UTcpNetDriver, UTcpipConnection, ATcpLink, AUdpLink, AInternetLink classes with virtual method stubs. 26 IMPLEMENT_FUNCTION calls (native indices TBD). 3 UTcpipConnection vftable .def entries commented out (UObject MI not reconstructed).

**Known divergences:**
- Window.dll: 319 R6-specific exports not yet reconstructed
- IpDrv.dll: 3 UTcpipConnection vftable entries deferred (UObject multiple inheritance)
- IpDrv.dll: 26 native function indices set to -1 (placeholder)
- CSDK: Localize extended to 6 params, ResetConfig to 3 params (R6 signatures with UT99-compatible defaults)

Blog Post: *"The Little Modules That Could"*

---

## Phase 5: Driver Layer ✅ COMPLETE

| Module | Status | Exports | Classes | Notes |
|--------|--------|---------|---------|-------|
| **WinDrv.dll** | ✅ Builds | 89 ordinals | UWindowsViewport, UWindowsClient, WWindowsViewportWindow | DirectInput8 statics as `@@2` data members; ToggleFullscreen/EndFullscreen non-virtual (QAEXXZ) |
| **D3DDrv.dll** | ✅ Builds | 44 ordinals | UD3DRenderDevice | Based off D3D8; bitfields assigned in ctor body; StaticConstructor empty (UBoolProperty vtable fix) |

Key fixes: `POINTER_64 __ptr64` before `<windows.h>` (DX8 SDK include order conflict); `EInputAction`/`EInputKey` enums in EngineClasses.h for correct mangled signatures; stub types `FRenderInterface`, `FRenderCaps`, `FResolutionInfo`, `EHardwareEmulationMode`, `ETextureFormat` added to EngineClasses.h.

Blog Post: *"Pixels and Packets — The Driver Layer"* (`2025-01-08-pixels-and-packets.md`)

---

## Phase 6: R6 Game Modules — Bottom-Up Through Dependency Graph ✅ COMPLETE

Five R6-specific DLLs — the game layer that turns Unreal Engine into Rainbow Six. All build with 0 errors. Export tables match retail binaries (1,986 of 1,987 ordinals — 1 reserved due to scope-numbering divergence).

| Module | Classes | Exports | Native Funcs | Key Systems |
|--------|---------|---------|-------------|-------------|
| **R6Abstract.dll** | 13 | 207 | 5 | Abstract bases: pawns, weapons, gadgets, game info, HUD, corpses, zones, noise, game service, patch service |
| **R6Weapons.dll** | 9 | 132 | 2 | Weapon mechanics (`AR6Weapons`), bullets (`AR6Bullet`), gadgets, grenades, demolitions, HBS, reticule, smoke |
| **R6Engine.dll** | 50 | 1,125 (1 reserved) | 92 | Pawns, AI controllers (Rainbow/Terrorist/Hostage), doors, deployment zones, ladders, stairs, ragdolls, matinee, heartbeat, sound replication |
| **R6Game.dll** | 16 | 263 | 24 | Game rules (`AR6GameInfo`), multiplayer modes, HUD, planning, action points, file managers, operatives, campaigns |
| **R6GameService.dll** | 5 | 259 | 41 | GameSpy server list (`UR6GSServers`), LAN discovery, mod info, EviL patch service |
| **Total** | **93** | **1,987** | **164** | |

### 6A. R6Abstract.dll ✅
- 13 classes, 207 ordinal exports (all match retail)
- 5 native function stubs (INDEX_NONE — dispatched by name)
- 22 `UR6AbstractGameService` virtual method stubs (overridden in R6GameService)
- Event dispatchers: `eventGetSkill`, `eventR6MakeNoise`, `eventSpawnSelectedGadget`
- Source: `R6Abstract.cpp` (210 lines), `R6AbstractClasses.h` (310 lines)

### 6B. R6Weapons.dll ✅
- 9 classes, 132 ordinal exports (all match retail)
- 2 native function stubs
- Accuracy system: `FstAccuracyType` (5 movement-state accuracy values + reticule time + weapon jump)
- Bullet physics: `AR6Bullet` with energy, penetration factor, range conversion, explosion radius
- Source: `R6Weapons.cpp` (174 lines), `R6WeaponsClasses.h` (~300 lines)

### 6C. R6Engine.dll ✅
- 50 classes, 1,125 ordinal exports + 1 reserved (1,126 retail total)
- Ordinal 796 reserved: `__FUNC_NAME__` static in `AR6FalseHeartBeat::IsBlockedBy` — MSVC scope-numbering divergence between retail MSVC 7.1 and our compiler
- 92 native function stubs across AR6AIController (17), AR6Pawn (25), AR6DeploymentZone (9), AR6PlayerController (8), AR6RainbowAI (10), AR6TerroristAI (8), and others
- AI controllers: Rainbow/Terrorist/Hostage with pathfinding, cover, detection, tactical queries
- Door system: `AR6IORotatingDoor` with lock HP, breach attachment, rotation physics
- Deployment zones: rectangle, circle, path, random points — hostage/terrorist spawning
- R6Charts: body part damage tables (Head/Torso/Limbs × Kill/Stun/Through)
- Matinee extensions: `UR6SubActionAnimSequence`, `UR6SubActionLookAt`
- Source: `R6Engine.cpp` (1,923 lines), `R6EngineClasses.h` (4,354 lines)

### 6D. R6Game.dll ✅
- 16 classes, 263 ordinal exports (all match retail)
- 24 native function stubs
- Game modes: `AR6GameInfo`, `AR6MultiPlayerGameInfo`
- HUD: `AR6HUD` with radar, character info, map drawing, colour management
- Planning: `AR6PlanningCtrl` with trace/click/XY queries, `UR6PlanningInfo` with team/point management
- Campaign: `UR6PlayerCampaign`, `UR6PlayerCustomMission`, `UR6FileManagerCampaign`
- Game manager: `UR6GameManager` with console commands, server management, GameSpy integration
- Source: `R6Game.cpp` (278 lines), `R6GameClasses.h` (~500 lines)

### 6E. R6GameService.dll ✅
- 5 classes, 259 ordinal exports (all match retail)
- 41 native function stubs (most in `UR6GSServers`)
- `UR6GSServers`: 60+ virtual method stubs — GameSpy client, server registration, CD key auth, matchmaking, ping management, router/lobby connection
- 10 event dispatchers bridging to UnrealScript (`eventFillCreateGameInfo`, `eventIsGlobalIDBanned`, etc.)
- `UeviLPatchService`: 6 native functions for the EviL auto-update system
- Source: `R6GameService.cpp` (652 lines), `R6GameServiceClasses.h` (~500 lines)

**Dependency chain:** Core → Engine → R6Abstract → { R6Weapons, R6Engine → { R6Game, R6GameService } }

**Known divergences:**
- All native function indices set to INDEX_NONE (-1) — dispatched by name at runtime. Correct retail indices can be extracted from `.u` packages in Phase 9.
- Method bodies are stubs — correct signatures and export symbols, but logic deferred to Phase 8C audit pass
- R6Engine ordinal 796: `__FUNC_NAME__` static in `AR6FalseHeartBeat::IsBlockedBy` — scope-numbering divergence between retail MSVC 7.1 (`?2?`) and our compiler. Functionally equivalent; cosmetic difference in debug string mangling.
- `AR6Bullet::BulletGoesThroughCharacter` body pending identification of Ghidra FUN_10042934

Blog Posts: ✅ *"The Game Layer — Rebuilding Rainbow Six's R6 Modules"* (`2025-01-09-the-game-layer.md`), ✅ *"Weapons, Walls, and Doors — What Makes R6 Tick"* (`2025-01-10-weapons-walls-and-doors.md`)

---

## Phase 7: Audio System — Lowest Reference Quality, Hardest to Reconstruct ✅ COMPLETE

All 7 audio DLLs built from stub source with export tables matching retail. Zero source reference — entire phase reconstructed from Ghidra export analysis and dumpbin output of retail binaries.

### Architecture

The audio system is a three-layer stack built by Ubi Soft Montreal's DARE (Digital Audio Rendering Engine) team:

```
DareAudio*.dll   (Unreal ↔ DARE bridge — UAudioSubsystem implementation)
    ↓ links
SNDDSound3DDLL_*.dll  (Platform audio backend — DirectSound3D)
    ↓ links
SNDext_*.dll     (Low-level platform abstraction — memory, file I/O, threading)
```

Three DareAudio variants exist (DareAudio, DareAudioScript, DareAudioRelease), each linking a different SND backend. In practice only two SND variants ship with retail (ret and VSR); the VBD variant referenced by DareAudioRelease doesn't exist, so it uses ret as a stand-in.

### 7A. SNDext — Platform Abstraction Layer ✅
- 2 SHARED DLL variants: `SNDext_ret.dll` (32 exports), `SNDext_VSR.dll` (32 exports, identical)
- Pure C __stdcall interface: memory allocation, file I/O, streaming, assertion, threading
- .def files with exact ordinals @1–@32 matching retail
- No link dependencies (leaf of the audio dependency chain)
- Source: `SNDext.cpp` (32 stubs), `SNDext_ret.def`, `SNDext_VSR.def`

### 7B. SNDDSound3D — DirectSound3D Backend ✅
- 2 SHARED DLL variants: `SNDDSound3DDLL_ret.dll` (265 exports), `SNDDSound3DDLL_VSR.dll` (342 exports)
- 344 total unique exports (union of both variants): 207 __stdcall, 133 __cdecl, 2 C++ mangled, 2 data (VSR-only)
- .def files control per-variant visibility with exact non-contiguous ordinal mapping
- Links: SNDext (matching variant), dsound, winmm
- C++ exports: `SND_fn_vDisableHardwareAcceleration(int)`, `SND_fn_vSetHRTFOption(_SND_tdeHTRFType)`
- VSR-only data exports: `liste_of_association`, `liste_of_voices`
- Generated by `tools/gen_snd3d_stubs.py` from dumpbin output
- Source: `SNDDSound3D.cpp` (344 stubs), `SNDDSound3DDLL_ret.def`, `SNDDSound3DDLL_VSR.def`

### 7C. DareAudio — Unreal Audio Subsystem Implementation ✅
- 3 MODULE DLL variants: `DareAudio.dll`, `DareAudioScript.dll`, `DareAudioRelease.dll` (87 exports each, identical export tables)
- Single UObject class: `UDareAudioSubsystem` inheriting `UAudioSubsystem` + `FExec` (dual-vtable multiple inheritance)
- 60+ virtual methods, 12 static __stdcall callbacks, 5 static data members
- Links: Core (SDK lib), Engine (rebuilt lib — needed for `UAudioSubsystem` default constructor not exported by SDK)
- Each variant links a different SNDDSound3D backend (DareAudio→ret, DareAudioScript→VSR, DareAudioRelease→ret)
- Source: `DareAudio.cpp`, `DareAudioClasses.h`, `DareAudioPrivate.h`, `DareAudio.def`

### Build Notes
- SNDext and SNDDSound3D are SHARED (not MODULE) because downstream DLLs link against their import libs
- DareAudio links our rebuilt `Engine.lib` (not the SDK's) because the SDK Engine.lib doesn't export `UAudioSubsystem::UAudioSubsystem()` (ordinal 6339 in our Engine.dll)
- `target_include_directories(... BEFORE ...)` required on DareAudio to ensure local engine headers beat UT99 SDK headers
- LNK4197 warnings (duplicate export spec) are expected — DECLARE_CLASS + .def file both specify the same symbols; .def wins for ordinal assignment

### Forward-declared DARE types (placeholder definitions)
- `_SND_tdstVectorFloat` — 3D vector for sound positioning
- `_SND_tdstRollOffParam` — Distance attenuation curve parameters
- `_SND_tdstBlockEvent` — Sound event block descriptor
- `ESoundSlot`, `ESoundVolume`, `ELoadBankSound`, `ER6SoundState` — Audio enums (values TBD from Ghidra)

**Known divergences:**
- All method bodies are stubs — correct signatures and export symbols, but logic deferred to Phase 8C audit pass
- DARE struct layouts (`_SND_tdst*`) are forward-declared only — full field definitions require Ghidra analysis of SNDDSound3D
- Enum values for `ESoundSlot`, `ESoundVolume`, `ELoadBankSound`, `ER6SoundState` are placeholder (0-based sequential) — correct values from Ghidra or UnrealScript decompilation

Blog Post: *"How Games Hear — The DARE Audio System"*

---

## Phase 8: RavenShield.exe — Bootstrap/Launcher ✅ COMPLETE

WinMain, command-line parsing, engine init, window creation, message pump, DLL loading.

Blog Post: *"Press Start — Launching the Engine"*

### Status

| Component | File | Status |
|-----------|------|--------|
| LaunchPrivate.h | `src/launch/LaunchPrivate.h` | ✅ Complete — API linkage, system headers, R6 compat shims, Window.h include |
| Launch.cpp | `src/launch/Launch.cpp` | ✅ Complete — WinMain, InitEngine, MainLoop, FExecHook, splash screen |
| FMallocWindows.h | `src/launch/FMallocWindows.h` | ✅ Shim — redirects to UT99 version (CSDK has method bodies commented out) |
| LaunchRes.h / .rc | `src/launch/Res/` | ✅ Complete — splash dialog resource (IDDIALOG_Splash, IDICON_Mainframe) |
| CMakeLists.txt | `src/launch/CMakeLists.txt` | ✅ Complete — links Core, Engine, Window + system libs |

### Key Discoveries
- Retail exe is **SafeDisc v2** wrapped — Ghidra only sees the encrypted packer stub. Reconstruction based on import table analysis + UT99 reference code
- **GTimestamp** (`UBOOL`) used by inline `appSeconds()` is NOT exported from retail Core.dll — launcher provides the storage locally
- **WWindow::Show** is virtual in R6's Window.dll (`UAEXH`) but declared non-virtual in UT99's Window.h (`QAEXH`) — fixed via ALTERNATENAME pragma
- **StaticConstructObject** has mismatched 7th parameter type between CSDK headers (`UObject*`) and Core.lib (`INT`) — fixed via ALTERNATENAME pragma
- FMallocWindows method bodies commented out in CSDK — local shim redirects to UT99's inline version

### Stubbed Pending Phase 8C
- `Engine->Init()` — virtual call requires correct vtable slot ordering for UEngine/UGameEngine
- `Engine->Tick(DeltaTime)` — same vtable issue; main loop ticks GWindowManager but not engine
- `Engine->GetMaxTickRate()` — placeholder 60fps; requires vtable
- FExecHook: `TakeFocus`, `EditActor`, `Preferences` — require UEngine::Client member data at known offset

---

## Phase 8B: D3DDrv Render Loop Reconstruction

Phase 5 left `D3DDrv.dll` building with correct exports and struct layout but all ~170KB of GPU state machine logic stubbed out. This phase reconstructs the real implementation using Ghidra analysis of the retail binary as the primary source, with the UT99 D3D7 driver (`sdk/Ut99PubSrc/`) as structural reference (D3D7 → D3D8 API delta is well-documented).

**Dependency:** Requires Phase 8 (RavenShield.exe) so the full game can boot and rendering output can be validated against retail.

**Reconstruction order (sub-components, least deps first):**
1. `FD3DResource` — base resource wrapper (textures, vertex buffers, index buffers)
2. `FD3DPixelShader` / `FD3DVertexShader` — shader object wrappers around `IDirect3DPixelShader8` / `IDirect3DVertexShader8`
3. `FD3DRenderInterface` — render dispatch class; thunks in D3DDrv to `UD3DRenderDevice` state; reconstruct draw-call and state-change methods one vtable slot at a time
4. `UD3DRenderDevice::SetRes()` — device creation, swap chain setup, capability detection
5. `UD3DRenderDevice::Lock()` / `Unlock()` / `Present()` — frame begin/end, swap chain flip
6. Texture management — `SetTexture()`, mip generation, format conversion (matching `ETextureFormat` values)
7. Vertex pipeline — fixed-function vs shader selection, `FD3DVertexStream` setup, `DrawPrimitive` calls
8. Render state management — blending, Z-buffer, fog, lighting, culling state blocks
9. Bink video surface — `binkw32` integration for in-engine cinematic playback on a render target
10. SSE memcpy export (`FUN_10001020`) — confirm reconstructed vs retail byte output

**Validation approach:**
- Run reconstructed D3DDrv against retail maps; compare pixel output screenshots to retail captures
- Use `tools/compare/bindiff.py` section-level comparison on `.text` segment
- Known hard parts: vertex shader constants layout, texture stage combiner setup (D3D8 fixed-function combiner is verbose)

**Known divergences to document:**
- Any places where D3D8 API usage in retail can only be approximated rather than byte-matched (e.g., compiler-generated COM vtable thunks)
- Bink integration: `BinkGetSurfaces` / `BinkCopyToBuffer` calls are binary-stable but the surrounding render target lifetime management may diverge

**Estimated commits:** 8–12

Blog Post: *"Chasing Pixels — Reconstructing the D3D8 Render Loop"*

---

## Phase 8C: Stub & Byte-Parity Audit Pass

A systematic sweep across every reconstructed module. By this point all 16 binaries build, but many contain stub method bodies, placeholder native indices, commented-out `.def` entries, and documented divergences accumulated across Phases 2–8B. This phase addresses them methodically.

### 8C-1. Inventory
1. Grep all `src/` for known stub markers: `return 0;` / `return;` / `appErrorf(TEXT("stub"))` / `// TODO` / `// STUB` / `INDEX_NONE` / commented-out `.def` lines
2. Cross-reference against per-module "Known divergences" sections in this plan
3. Produce a single audit spreadsheet or markdown table: **module → function → stub reason → fixable? → priority**

### 8C-2. Fix Categories

| Category | Action |
|----------|--------|
| **Trivial stubs** (empty virtuals that genuinely do nothing in retail) | Verify via Ghidra that retail function is truly `retn` / `xor eax,eax; retn` — mark as confirmed-accurate, remove any misleading stub comments |
| **Deferred implementations** (real logic exists but wasn't reconstructed yet) | Pull from Ghidra decompilation, clean up, implement. Prioritise functions called on the hot path (tick, render, physics) |
| **Placeholder native indices** (`INDEX_NONE` / `-1`) | Look up correct indices from retail `.u` packages or Ghidra export tables; update `IMPLEMENT_FUNCTION` calls |
| **Commented-out .def exports** (e.g., Window.dll's 319, IpDrv's 3) | Reconstruct the missing symbols or add linker-level forwarding stubs (`= ?...`) so the export table matches retail |
| **Compiler artefact divergences** (COM vtable thunks, thiscall wrappers) | Document as intentional; verify the generated code is functionally equivalent even if bytes differ |

### 8C-3. Binary Comparison
1. Build all modules in Release with retail-matching compiler flags
2. Run `tools/compare/bindiff.py` on every DLL — report per-section match percentage
3. Run `tools/compare/funcmatch.py` on exported functions — report per-function match status
4. For each function below 95% match: inspect disassembly diff, determine if divergence is fixable or inherent (compiler version, optimisation artefacts)
5. Update the "Known divergences" documentation with final status for every flagged item

### 8C-4. Triage & Accept
- Functions confirmed as byte-identical → ✅
- Functions functionally identical but byte-divergent due to compiler artefacts → document, mark as accepted
- Functions with logic divergences → file as issues, fix if possible, otherwise document the delta with explanation

**Estimated commits:** 5–10 (many small targeted fixes across modules)

Blog Post: *"The Audit — Hunting Down Every Last Stub"*

---

## Phase 9: UnrealScript Decompilation & Reconstruction

Extract UnrealScript from the **1.60 retail** `.u` packages (not the 1.56 SDK leak). The 1.56/1.60 SDK source is used as a **reference only** for function naming, comments, and understanding intent — the canonical source of truth is the decompiled retail scripts.

### 9A. Script Extraction
1. Decompile all `.u` packages from `retail/system/` using a UnrealScript decompiler (e.g., UTPT, UE Explorer, or custom tooling)
2. Output to `src/unrealscript/{PackageName}/Classes/*.uc` — one file per class, mirroring Unreal's package/class convention
3. Package order per `retail/system/Default.ini` `EditPackages`: Core → Engine → Editor → UnrealEd → IpDrv → UWindow → Fire → Gameplay → R6Abstract → R6Engine → R6Characters → R6Description → R6SFX → R6GameService → R6Game → R6Menu → R6Window → R61stWeapons → R6Weapons → R6WeaponGadgets → R63rdWeapons
4. Include Athena Sword expansion packages from `retail/Mods/AthenaSword/`

### 9B. Annotation & Documentation
1. Cross-reference decompiled scripts against `sdk/1.56 Source Code/` — transpose function/variable names and comments where the 1.56 source provides clearer naming than the decompiler output
2. Add explanatory comments for readability and maintainability — document class purpose, non-obvious logic, magic numbers, state machine transitions, and AI behaviour
3. Do NOT blindly copy 1.56 source — the retail 1.60 may have bug fixes, balance changes, or structural differences. Always prefer the decompiled retail as the base, annotate from SDK reference

### 9C. Rebuild & Verification
1. Compile all `.uc` packages using `UCC.exe` from the build output
2. Verify compiled `.u` output matches retail originals (byte comparison where possible, functional equivalence where not)
3. CMake integration: `add_custom_command` to compile `.uc` packages as part of the build

Blog Post: *"Scripting a Rainbow — UnrealScript Rebuilt"*

---

## Phase 10: Asset Decompilation & Source Formats

Extract all game assets from retail proprietary formats into **lossless, modern, easily-editable source formats**. These live in `src/assets/` organised by asset type. The build system recompiles them into the game's expected formats.

### 10A. Textures
1. Extract all `.utx` texture packages → individual lossless images (PNG for RGBA, TGA for indexed/palettised, EXR for HDR if any)
2. Output to `src/assets/textures/{PackageName}/{TextureName}.png`
3. Build step: repackage into `.utx` using `UCC.exe` or custom tooling

### 10B. Static Meshes & Skeletal Meshes
1. Extract `.usx` (static meshes) and `.ukx` (skeletal meshes + animations) → glTF 2.0 or FBX
2. Output to `src/assets/meshes/{PackageName}/{MeshName}.gltf` and `src/assets/animations/{PackageName}/{AnimName}.gltf`
3. Preserve bone hierarchies, vertex weights, LOD levels, collision hulls
4. Build step: recompile into `.usx`/`.ukx`

### 10C. Sounds
1. Extract `.uax` sound packages → WAV (PCM) or FLAC for lossless preservation
2. Output to `src/assets/sounds/{PackageName}/{SoundName}.wav`
3. Build step: repackage into `.uax`

### 10D. Maps
1. Extract `.rsm` map files → Unreal `.t3d` text format (human-readable, diffable)
2. Output to `src/assets/maps/{MapName}.t3d` plus any embedded assets extracted per 10A-10C
3. Build step: compile `.t3d` back to `.rsm`

### 10E. Music & Video
1. Music: Extract any `.umx` → tracker format (IT/S3M/XM) or OGG/WAV as appropriate
2. Video: Bink `.bik` files — extract to lossless AVI or individual frames + audio. Bink re-encoding via RAD tools for build step
3. Output to `src/assets/music/` and `src/assets/videos/`

### 10F. UI & Miscellaneous
1. Localisation `.int`/`.frt`/etc. files — already text, copy to `src/assets/localization/`
2. Configuration `.ini` files — copy to `src/assets/config/`
3. Any remaining data files extracted to appropriate `src/assets/` subdirectory

Blog Post: *"Cracking Open the Art — Assets in Source Form"*

---

## Phase 11: Integration & Testing

1. **Incremental replacement** — swap one DLL at a time, test game still boots
2. **Boot test** — main menu with all rebuilt DLLs
3. **Training mission** — single-player functional test
4. **Campaign** — first 3 missions
5. **Multiplayer** — LAN server + client, all game modes
6. **OpenRVS compatibility** — verify community mod loads
7. **Binary comparison report** — run `bindiff.py`/`funcmatch.py`, document match percentages and intentional divergences

Blog Posts: *"It Lives!"*, *"The Comparison — How Close Did We Get?"*

---

## Phase 12: Source Cleanup — Self-Contained `src/`

Make `src/` fully self-contained: all compilable source code (C++ headers, UnrealScript, assets) lives in `src/` with no `#include` paths reaching into `sdk/`. The `sdk/` directory becomes purely archival reference material. Import libraries (`.lib`) remain external — they are binary artifacts from the retail game, not source code, and are progressively replaced by our own build output.

### 12A. Internalize C++ Headers
1. Copy all SDK headers currently referenced by `#include` paths into `src/` subdirectories:
   - `sdk/Raven_Shield_C_SDK/432Core/Inc/*.h` → `src/core/inc/`
   - Used headers from `sdk/Ut99PubSrc/Core/Inc/` → `src/core/inc/` (merge with CSDK copies where both exist)
   - Used headers from `sdk/Ut99PubSrc/Engine/Inc/` → `src/engine/inc/`
   - `sdk/Ut99PubSrc/Window/Inc/Window.h` + resources → `src/window/inc/`
   - `sdk/Ut99PubSrc/Fire/Inc/` → `src/fire/inc/`
   - GameSpy SDK headers used by IpDrv → `src/ipdrv/inc/`
2. Update all CMakeLists.txt `target_include_directories` to point to `src/*/inc/` instead of `sdk/`
3. Verify full build still passes with zero `sdk/` include paths
4. Carry forward all R6-specific modifications already applied (Localize 6-param, ResetConfig 3-param, appMsgf overload, etc.)

### 12B. Reconstruct Headers (Progressive)
1. As each module's implementation matures, replace copied SDK headers with clean purpose-built ones containing only declarations we've verified
2. Match ABI exactly: struct sizes, vtable layouts, member offsets, `#pragma pack` directives
3. Remove dead declarations, commented-out blocks, and SDK quirks
4. Clear convention: `src/{module}/inc/` = the authoritative header for that module

### 12C. Build System Cleanup
1. CMake: remove all `sdk/` include paths; only `src/` and `tools/toolchain/` paths remain
2. Document any remaining `sdk/` dependencies (import `.lib` files only) with path to eventual removal (each rebuilt DLL produces its own `.lib`)
3. Verify `cmake -S . -B build && cmake --build build` works without `sdk/` in include search paths

Blog Post: *"Cutting the Cord — A Self-Contained Source Tree"*

---

## Phase 13: Progressive Modernization

1. **Readability pass** — meaningful names, extract constants, consistent formatting
2. **Modern build target** — add MSVC 2022 / C++17 CMake preset alongside legacy MSVC 7.1
3. **Documentation** — module architecture, DLL interface contracts, UnrealScript ↔ native bridge docs, architecture diagrams

Blog Posts: *"Making It Readable"*, *"The Road Ahead"*

---

## Custom Tools to Build

| Tool | Path | Purpose |
|------|------|---------|
| `batch_import.py` | `ghidra/scripts/` | Headless Ghidra mass import + auto-analysis |
| `apply_types.py` | `ghidra/scripts/` | Apply SDK type archives to Ghidra analysis |
| `symbol_recovery.py` | `ghidra/scripts/` | Recover names from MSVC mangled exports + SDK header matching |
| `cross_reference.py` | `ghidra/scripts/` | Inter-DLL dependency graph from import tables |
| `ut99_matcher.py` | `ghidra/scripts/` | Match decompiled Core/Engine against UT99 source |
| `export_cpp.py` | `ghidra/scripts/` | Export decompilation as structured C++ per-class files |
| `bindiff.py` | `tools/compare/` | Section-level binary comparison, match % per function |
| `funcmatch.py` | `tools/compare/` | Function-level instruction comparison (normalized relocations) |
| `stub_generator.py` | `tools/import/` | Generate compilable stubs from SDK headers |

---

## Relevant Files

**SDK References (gold standard):**
- `sdk/Raven_Shield_C_SDK/inc/` — 21 class layout headers (vtables, structs, property flags)
- `sdk/Raven_Shield_C_SDK/432Core/Inc/` — 50+ Unreal core headers (FName, UObject, math, memory)
- `sdk/Raven_Shield_C_SDK/lib/` — 13 import libraries for linking
- `sdk/Ut99PubSrc/` — Full UT99 native C++ source with CMake build system
- `sdk/1.56 Source Code/` — 1000+ UnrealScript files (complete game logic)
- `sdk/GameSpySDK/src/GameSpy/` — Complete GameSpy networking source
- `sdk/Goodies/` — Hooks guide PDF, 5 sample mods, weapon dev kit

**Build Toolchain:**
- `tools/toolchain/msvc71/` — MSVC 7.1 compiler (byte-parity target)
- `tools/toolchain/winsdk/` — Windows Server 2003 SP1 SDK
- `tools/toolchain/dxsdk/` — DirectX 8 SDK

**Configuration References:**
- `retail/system/Default.ini` — Package load order, server packages, engine config
- `retail/system/R6ClassDefines.ini` — Class registration table

---

## Verification

1. Each `src/{module}/` compiles to a DLL with MSVC 7.1 linking against its dependencies
2. `dumpbin /exports` on rebuilt DLLs matches original export symbols
3. `bindiff.py` reports >90% .text section match for Core, Engine, R6Game
4. Single-DLL replacement boots game successfully (incremental integration)
5. Full replacement reaches main menu → completes training mission → LAN multiplayer works
6. Rebuilt `.u` packages from `src/unrealscript/` load without errors in `ravenshield.log`
7. Assets in `src/assets/` round-trip: decompile → edit → recompile → game loads correctly
8. Each blog milestone post published before advancing to next phase

---

## Decisions

- Third-party DLLs are external dependencies (linked, not decompiled)
- MSVC 7.1 primary target for byte parity; modern MSVC added in Phase 11
- Readability wins over byte-match when they conflict — divergences documented
---

## Further Considerations

1. **Athena Sword expansion** — Additional `.u` packages in `retail/Mods/AthenaSword/`. Include in Phase 9 UnrealScript decompilation and Phase 11 testing.

2. **OpenRVS community mod** — `retail/system/OpenRVS.u` and `openrvs.ini` indicate active community. Verify compatibility in Phase 11 testing.

3. **Steam integration** — Original has Steam hooks (`installscript.vdf`, `steam_appid.txt`). Rebuilt binaries won't have Steam DRM stubs. Add a thin Steam API stub if needed, document as known difference.
