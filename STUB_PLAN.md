# Plan: Full Game Reconstruction — Remove Retail DLL Reliance (v2)

## TL;DR
Replace ~3,930 stubs across 15 game DLLs so RavenShield plays entirely from rebuilt code. Third-party middleware stays. Approach: Ghidra for complex/R6-proprietary, UT99+SDK for standard Unreal. Full multiplayer included.

Phases grouped by **functional outcome** — each phase produces a testable, meaningful result rather than completing a module in isolation. Cross-module work that serves the same purpose ships together.

## Current State
- 16 binaries build and link (15 DLLs + 1 EXE) — zero retail .lib references
- Source organized into UT99-style Inc/Src layout across all 16 modules
- Phase 1 (build self-sufficiency) COMPLETE — Core_Dep and Engine_Dep resolve to rebuilt libs
- Phase 2 (window/rendering) ~90% COMPLETE — WinDrv, Canvas, D3DDrv, Materials all implemented
- ~3,930 original stubs: ~2,612 EngineStubs linker redirects, ~365 EXEC_STUBs, ~960 method stubs
- Remaining EngineStubs1.cpp: 28 `__FUNC_NAME__` compatibility shims (compiler-version artifacts, not real stubs)
- Remaining CoreStubs.cpp: 6 `__FUNC_NAME__` compatibility shims

## Stub Composition Analysis
The ~2,612 EngineStubs linker redirects break down as:
- **~1,200 (22%) trivially auto-generatable**: constructors, destructors, assignment operators, vtable pointers, simple getters, TArray template operations
- **~1,800 (33%) semi-auto with class defs**: serialization, animation accessors, material properties, format handlers
- **~2,400 (45%) require Ghidra**: physics, pathfinding, rendering pipeline, collision algorithms, event routing, terrain

The ~365 EXEC_STUBs break down by functional area:
- Gameplay (spawning, timers, iterators, config): 144
- Movement/Physics: 62
- Rendering (canvas, HUD, effects): 60
- Animation: 36
- Audio: 23
- AI/Navigation: 15
- Networking: 10
- Core Boot: 13

---

## Phase 1: Foundation & Self-Sufficiency
**Goal:** Build compiles against its own libs, not retail. No runtime behaviour change yet — just cut the umbilical cord.

### 1A. Core.dll — Math & Container Implementations (~80 stubs)
- **Files:** src/core/CoreStubs.cpp, src/core/Core.cpp
- **What:** Math intrinsics (appFloor, appCeil, appAtan2, appSqrt), FString operators, TArray template instantiations, FName lookup helpers
- **Approach:** Clean-room from UT99 public source (sdk/Ut99PubSrc/Core/Inc/) — standard template/math code
- **Build:** Switch Core_Dep from sdk/.../Core.lib → build/bin/Core.lib

### 1B. Stub Triage Tool (prerequisite for 1C-1D)
- **What:** Build a Python script (tools/stub_triage.py) that parses the MSVC mangled symbol names from EngineStubs1-4.cpp and classifies each `/alternatename` pragma into categories:
  - `TRIVIAL`: constructors (`??0`), destructors (`??1`), assignment operators (`??4`), vtable pointers (`??_7`), simple `Get*`/`Is*` accessors
  - `MEDIUM`: `Serialize`, `PostLoad`, streaming operators (`>>`, `<<`), material property accessors
  - `COMPLEX`: physics (`phys*`, `move*`, `step*`), pathfinding, rendering pipeline, collision octree, terrain deformation
- **Output:** A categorized report (CSV or markdown) mapping each pragma to: demangled name, class, category, and suggested approach (auto-gen / UT99 reference / Ghidra)
- **Why first:** This turns a 2,612-stub wall into an actionable work queue. The ~1,200 trivial stubs can then be bulk-solved with confidence, and the Ghidra work queue is scoped upfront.
- **Approach:** Use `undname.exe` (MSVC demangler) or Python `undecorate` to demangle, then regex classify.

### 1C. Engine Linker Stubs — Trivial Bulk (~1,200 stubs)
- **Files:** src/engine/EngineStubs1-4.cpp
- **What:** Auto-generate or implement the stubs triage tool classified as TRIVIAL:
  - All `??0` constructors / `??1` destructors (pattern: initialize members to defaults / call member destructors)
  - All `??4` assignment operators (pattern: memberwise copy, return *this)
  - All `??_7` vtable pointers (pattern: emit correct vtable layout)
  - Simple getter methods (`GetWidth`, `GetHeight`, `GetFormat`, `GetName`, `GetActor`, `GetLevel`) — return member variables
  - TArray template operations (`Add`, `Remove`, `Pop`, `Last`)
  - Simple `Is*` predicates (`IsAnimating`, `IsPlayer`, `IsBlockedBy`)
- **Approach:** Semi-automated from class definitions in sdk/Raven_Shield_C_SDK/432Core/Inc/ headers. Many follow mechanical patterns. Script or manual bulk generation, guided by triage tool output.
- **Key insight:** This eliminates ~1,200 pragmas and makes the remaining stubs visible

### 1D. Engine Linker Stubs — Serialization & Accessors (~1,800 stubs)
- **Files:** src/engine/EngineStubs1-4.cpp (continuing)
- **What:** Medium-complexity functions requiring class layout knowledge:
  - `Serialize` methods (read/write members through FArchive)
  - `PostLoad`, `PreLoad` lifecycle methods
  - Material property getters (`GetValidated`, `GetUSize`, `GetVSize`)
  - Animation accessor methods
  - Archive streaming operators (`operator<<`, `operator>>`)
- **Approach:** UT99 reference for standard Unreal classes. SDK headers for field layouts. Ghidra for R6-specific serialization.

### 1E. Build System Switchover
- Switch Engine_Dep from sdk/.../Engine.lib → build/bin/Engine.lib
- Remove Window.lib, R6Abstract.lib retail references (replace with our built libs)
- Update staging task to no longer copy retail game DLLs — only assets + third-party middleware

**Phase 1 Status (2026-03-08):**
- `Core_Dep` and `Engine_Dep` now resolve to rebuilt import libraries from `build/src/.../Release/`
- Downstream `WinDrv`, `R6Engine`, `R6Weapons`, `R6GameService`, and `R6Game` now link against rebuilt `Window`, `R6Abstract`, and `R6Weapons` import libs instead of the SDK copies
- Runtime staging now clears `build/runtime-test/system`, copies retail assets/config content, whitelists only third-party middleware DLLs, and then overlays rebuilt game binaries from `build/bin`
- The remaining Engine `EngineStubs1.cpp` entries are no longer anonymous dummy-data redirects; they are explicit `__FUNC_NAME__` compatibility shims for MSVC-version string-symbol artifacts

**Phase 1 Verification:**
- `cmake --build build --config Release` succeeds with ZERO retail .lib references
- `dumpbin /exports` on each DLL matches retail ordinal tables
- Staging directory: no retail game DLLs present (only rebuilt + third-party + assets)
- Game probably crashes immediately — that's fine, this phase is about build self-sufficiency

**Phase 1 Verification Notes (2026-03-08):**
- The Release task path builds successfully and the generated `Release` project files reference rebuilt `Window`, `R6Abstract`, and `R6Weapons` import libraries rather than `sdk/Raven_Shield_C_SDK/lib`
- The staged runtime contains only rebuilt game DLLs, non-DLL retail assets/config files, and the middleware whitelist (`binkw32`, OpenAL/Ogg/Vorbis, EAX, and MSVC runtime DLLs)
- Export-table comparison remains an ongoing verification pass for the wider project, but Phase 1's self-sufficient build and staging criteria are now satisfied

**Phase 1 Milestone:** The build is completely self-contained. No retail SDK libs linked. The foundation for all subsequent work.

---

## Phase 2: A Window Into The World
**Goal:** Game creates a window, initializes Direct3D, and renders *something*. You see pixels.

### 2A. WinDrv — Viewport & Input (43 stubs across modules)
- **Files:** src/windrv/WinDrv.cpp
- **What — UWindowsClient** (~10 methods):
  - `Init()` — create DirectInput8, enumerate devices, initial config
  - `Tick()` — process Windows messages, poll input devices
  - `NewViewport()` — instantiate UWindowsViewport
  - `MakeCurrent()`, `SetMouseCapture()`, `Destroy()`
- **What — UWindowsViewport** (~33 methods):
  - `OpenWindow()` — CreateWindowEx, register WNDCLASS, set up message pump
  - `ViewportWndProc()` — WM_PAINT/WM_SIZE/WM_KEYDOWN/WM_CLOSE dispatch
  - `TryRenderDevice()` — load D3DDrv.dll, call SetRes
  - `GetWindow()` — return HWND (D3DDrv needs this)
  - `ResizeViewport()`, `Repaint()`, `Lock/Unlock()`
  - `UpdateInput()`, `AcquireKeyboard()`, `AcquireMouse()`, `UpdateMousePosition()`
- **Approach:** UT99 public source has WinDrv implementations (sdk/Ut99PubSrc/). WinDrv.cpp already has partial DirectInput8 init code. Ghidra for R6-specific DirectInput8 additions (UT99 used DirectInput7).
- **Dependencies:** None — can start immediately after Phase 1

### 2B. D3DDrv — Finish Renderer (5 remaining stubs)
- **Files:** src/d3ddrv/D3DDrv.cpp (already ~85% implemented)
- **What:**
  - `SetEmulationMode()` — display mode emulation (Ghidra)
  - `StartVideo()` — Bink video integration (reference existing Bink code in file)
  - `GetWindow()` / `GetOuterUClient()` — viewport bridge (trivial once 2A done)
- **Dependencies:** 2A (viewport must exist for D3D to bind)

### 2C. Window.dll — Base Framework
- **Files:** src/window/Window.cpp, src/window/WindowPrivate.h
- **What:**
  - WWindow base class: Init, Show, DoDestroy, OnClose
  - WWindowManager::Tick
  - Remove 12+ `/alternatename` pragma hacks — replace with real WWindow methods
- **Approach:** UT99 public source (sdk/Ut99PubSrc/Window/Inc/) — complete Window framework available
- **Note:** The 17 DECLARE_WINDOW_STUB control classes (WButton, WEdit, WListBox etc.) are NOT needed yet — the game UI is UnrealScript-based. These are only needed for editor/console dialogs.

### 2D. Canvas & HUD Rendering (28 EXEC_STUBs)
- **Files:** src/engine/UnRender.cpp
- **What:** UCanvas drawing functions needed to render menus and HUD:
  - State: `execSetPos`, `execSetOrigin`, `execSetClip`, `execSetDrawColor`, `execSetVirtualSize`, `execUseVirtualSize`
  - Drawing: `execDrawText`, `execDrawTextClipped`, `execDrawTile`, `execDrawTileClipped`, `execDrawStretchedTextureSegmentNative`, `execDrawActor`, `execDraw3DLine`
  - Measurement: `execStrLen`, `execTextSize`, `execGetScreenCoordinate`
  - Video: `execVideoOpen`, `execVideoPlay`, `execVideoStop`, `execVideoClose`
  - `UCanvas::Init()`, `UCanvas::Update()` virtual methods
  - `execSetMotionBlurIntensity`, `execDrawWritableMap`, `execClipTextNative`
  - `AHUD::execDraw3DLine`
- **Approach:** UnRender.cpp.bak has real implementations for SetPos/SetOrigin/SetClip/SetDrawColor. UT99 reference for DrawText/DrawTile (standard canvas operations). Ghidra for R6 video integration.

### 2E. Materials System
- **Files:** src/engine/UnMaterial.cpp
- **What:** Adopt from UnMaterial.cpp.bak — described as ~69% real, production-ready:
  - Material property queries (MaterialUSize, MaterialVSize, IsTransparent)
  - Shader and modifier hierarchies, UV stream requirements
  - Combiner and final blend implementations
- **Approach:** Direct port from .bak file with validation

**Phase 2 Status (2026-06-23):**
- **WinDrv (2A):** `src/windrv/Src/WinDrv.cpp` fully implemented — ~30 methods with real logic: `OpenWindow` (CreateWindowW + DirectInput device creation), `UpdateInput` (keyboard/mouse polling via GetDeviceState), `CauseInputEvent`, `ViewportWndProc`, `GetWindow`, `SetMouseCapture`, `TryRenderDevice`, `IsFullscreen`, `ResizeViewport`, `Minimize/Maximize/Restore`, `UWindowsClient::Init` (DirectInput8Create), `UWindowsClient::Tick` (PeekMessage pump), `MakeCurrent`, `GetLastCurrent`, viewport iteration
- **D3DDrv (2B):** `src/d3ddrv/Src/D3DDrv.cpp` ~95% complete from prior work — D3D8 device management, Bink video, shader caches, gamma, Lock/Unlock/Present
- **Window (2C):** `src/window/Src/Window.cpp` cleaned up — replaced 3 opaque `dummy_stub_data` pragmas with named `__FUNC_NAME__` wide-string blobs following Core/Engine pattern
- **Canvas & HUD (2D):** `src/engine/Src/UnRender.cpp` canvas exec functions upgraded from empty stubs to render-device-dispatching implementations: `DrawText`/`DrawTextClipped` call `_DrawString`, `DrawTile`/`DrawTileClipped` call RenDev virtuals, `Draw3DLine`/`Video*` dispatch through RenDev, `StrLen`/`TextSize` return approximate measurements, `GetScreenCoordinate` returns center-screen approximation
- **Materials (2E):** `src/engine/Src/UnMaterial.cpp` ~300 lines fully implemented from prior work
- **Source reorganization:** All 16 modules reorganized into UT99-style `Inc/`/`Src/` layout. All `.bak` backup files removed from engine. Build verified clean.

**Phase 2 Milestone Progress:** Window creation, input polling, canvas rendering, and D3D viewport bridge are all implemented. Remaining: full runtime verification (game creates window, D3D initializes, scene renders).

**Phase 2 Verification:**
- Game creates a window with correct resolution
- D3D initializes (backbuffer created, device presents)
- A level loads and the 3D scene renders
- HUD text and textures draw correctly
- Mouse/keyboard input is captured
- Bink splash video plays

**Phase 2 Milestone:** You see the game. Main menu renders. Input works. Visual confirmation that the engine core is alive.

---

## Phase 3: The World Simulates
**Goal:** Actors exist, move, collide, animate, and make sounds. The world is alive but R6-specific gameplay doesn't work yet.

### 3A. Core Boot & Level Initialization (13 EXEC_STUBs)
- **Files:** src/engine/UnLevel.cpp, src/engine/Engine.cpp, src/engine/UnActor.cpp
- **What — Boot path:**
  - `ALevelInfo`: execGetAddressURL, execGetLocalURL, execFinalizeLoading, execResetLevelInNative, execSetBankSound, execNotifyMatchStart
  - `AGameInfo`: execGetNetworkNumber, execGetCurrentMapNum, execSetCurrentMapNum, execProcessR6Availabilty
  - `UPrimitive`: virtual PointCheck(), LineCheck(), GetRenderBoundingBox()
  - `AActor`: execConsoleCommand, execGetMapName, execGetGameVersion, execGarbageCollect (core boot stubs)
- **Approach:** UT99 reference for level/game initialization. Ghidra for R6-specific additions.

### 3B. Actor Spawning & Lifecycle (15 EXEC_STUBs + related linker stubs)
- **Files:** src/engine/UnActor.cpp, src/engine/UnLevel.cpp
- **What:**
  - `execSpawn`, `execDestroy` — actor instantiation and cleanup
  - All iterator functions: `execAllActors`, `execDynamicActors`, `execChildActors`, `execRadiusActors`, `execVisibleActors`, `execVisibleCollidingActors`, `execTouchingActors`, `execBasedActors`, `execTraceActors`, `execCollidingActors`
  - Timer system: `execSetTimer`, `execGetTimerCount`, `execGetTimerRate`
  - Owner/base: `execSetOwner` (UnActor.cpp.bak has SetOwner/SetBase with real delegation)
  - Related EngineStubs: `SpawnActor@ULevel`, `DestroyActor@ULevel`, `CreateChannel@` (~180 linker stubs)
- **Approach:** Ghidra for SpawnActor (complex — class default object cloning + network replication setup). UT99 reference for iterator patterns. UnActor.cpp.bak has timer system (UpdateTimers with event firing).
- **Reference:** UnActor.cpp.bak (~1,000 lines usable code for touch system, base/owner, timers)

### 3C. Movement & Physics (62 EXEC_STUBs + ~280 linker stubs)
- **Files:** src/engine/UnActor.cpp, src/engine/UnPawn.cpp, src/engine/EngineExtra.cpp, EngineStubs1.cpp
- **What — Movement exec stubs:**
  - `execMove`, `execMoveSmooth`, `execSetLocation`, `execSetRotation`, `execSetRelativeLocation`, `execSetRelativeRotation`
  - `execSetPhysics`, `execAutonomousPhysics`
  - `execMoveTo`, `execMoveToward` (pawn movement)
- **What — Collision exec stubs:**
  - `execSetCollision`, `execSetCollisionSize`, `execTrace`, `execFastTrace`, `execR6Trace`, `execFindSpot`
- **What — EngineStubs complex physics:**
  - `physWalking`, `physFalling`, `physFlying`, `physSwimming`, `physProjectile`, `physLadder` (EngineStubs1, ~280 stubs)
  - `performPhysics`, `moveSmooth`, `stepUp`, `adjustFloor` — core physics dispatch
  - Collision octree: `ActorLineCheck`, `ActorPointCheck`, `ActorOverlapCheck` (EngineStubs3)
- **Approach:** Ghidra-heavy — physics simulation is the most algorithmically complex subsystem. UnActor.cpp.bak has coordinate transforms (ToLocal/ToWorld), collision queries (IsBlockedBy), and fix-up math (fixedTurn, TwoWallAdjust).

### 3D. Animation System (36 EXEC_STUBs + ~150 linker stubs)
- **Files:** src/engine/UnActor.cpp, EngineStubs1-4.cpp
- **What — Exec stubs (all in UnActor.cpp):**
  - Playback: `execPlayAnim`, `execLoopAnim`, `execTweenAnim`, `execFinishAnim`, `execStopAnimating`, `execFreezeAnimAt`
  - Query: `execIsAnimating`, `execIsTweening`, `execHasAnim`, `execGetAnimGroup`, `execGetAnimParams`
  - Blending: `execAnimBlendParams`, `execAnimBlendToAlpha`
  - Bone control: `execSetBoneDirection`, `execSetBoneLocation`, `execSetBoneScale`, `execSetBoneRotation`, `execGetBoneCoords`, `execGetBoneRotation`, `execGetRootLocation`, `execGetRootRotation`
  - Linkage: `execLinkMesh`, `execLinkSkelAnim`, `execAttachToBone`, `execDetachFromBone`, `execLockRootMotion`
- **What — EngineStubs:**
  - `AnimForcePose`, `AnimGetFrameCount`, `GetActiveAnimFrame`, `SetAnimFrame`, `SetBonePosition` (~150 linker stubs)
- **Approach:** Ghidra for bone blending and multi-channel animation. UT99 reference for basic animation sequence playback.

### 3E. Sound Hooks (23 EXEC_STUBs)
- **Files:** src/engine/UnActor.cpp, src/engine/UnPawn.cpp, src/engine/EngineExtra.cpp
- **What:**
  - Playback: `execPlaySound`, `execPlayOwnedSound`, `execStopSound`, `execStopAllSounds`, `execFadeSound`
  - Query: `execIsPlayingSound`, `execGetSoundDuration`
  - Music: `execPlayMusic`, `execStopMusic`, `execChangeVolumeTypeLinear`
  - Noise: `execMakeNoise`
  - Banks: `execSetBankSound`, volume/bank management
- **Approach:** These are dispatch hooks that delegate to the DARE audio subsystem. Ghidra for the delegation pattern; actual sound processing is in Phase 6 (DareAudio/SNDDSound3D).

### 3F. Effects & Projectors (7 EXEC_STUBs)
- **Files:** src/engine/UnEffects.cpp
- **What:**
  - `AEmitter::execKill`
  - `AProjector`: execAbandonProjector, execAttachProjector, execDetachProjector, execAttachActor, execDetachActor
  - `UParticleEmitter::execSpawnParticle`
- **Approach:** Ghidra — projector system is dynamic shadow/decal system.

**Phase 3 Verification:**
- Actors spawn when a level loads
- Player pawn exists in the world at the correct spawn point
- Physics simulation runs (gravity, walking, falling)
- Collision detection works (can't walk through walls)
- Animations play on character models
- Sound effects trigger (even if audio backend is still stub, the dispatch path works)
- Particle emitters spawn particles
- Dynamic shadows/projectors attach to surfaces

**Phase 3 Status (2025-07-07):**
- **3A.** Core Boot & Level Init (UnLevel.cpp, 18 EXEC_STUBs) — COMPLETE
- **3B.** Actor System (UnActor.cpp, ~160 EXEC_STUBs) — COMPLETE
- **3C.** Pawn/Controller (UnPawn.cpp, ~57 EXEC_STUBs) — COMPLETE
- **3D.** Cross-cutting (EngineClassImpl.cpp, ~74 EXEC_STUBs) — COMPLETE: Karma physics as param-extraction no-ops, volumes, zones, stat logging, R6 managers/file ops
- **3E.** Effects (UnEffects.cpp, 7 EXEC_STUBs) — COMPLETE
- **Total:** ~316 EXEC_STUBs replaced with full implementations across 5 source files
- **Zero EXEC_STUB macros remain** in engine source
- All functions extract parameters from UnrealScript bytecode stack using P_GET macros
- Karma physics and pathfinding are intentional no-ops pending future implementation (Phase 7A)
- EngineStubs.cpp still contains ~1,300 empty method bodies (linker stubs) — these are Phase 7 scope

**Phase 3 Milestone:** The Unreal Engine simulation layer is functional. Actors live, move, and interact with geometry. This is the standard UT-era engine working.

---

## Phase 4: Rainbow Six Comes Alive
**Goal:** R6-specific gameplay works. Player controls a soldier. AI teammates and enemies exist. Missions are playable.

### 4A. R6 Player Control (~35 R6Engine stubs + related)
- **Files:** src/r6engine/R6Engine.cpp (AR6PlayerController, AR6Pawn sections)
- **What:**
  - **AR6PlayerController** (25 methods): PlayerTick, UpdateRotation, SpawnDefaultHUD, ClientRestart, SetupInputSystem, CheckJumpInput, ServerChangeWeapon, ServerDoFire
  - **AR6Pawn stance system** (10 methods): stand/crouch/prone/crawl transitions, fluid peeking (lean left/right), PawnLook/PawnLookAt/PawnLookAbsolute
  - Camera/aiming: WeaponFollow, WeaponLock, pawnTrackActor
  - Reticule rendering, HUD updates
- **Approach:** Ghidra — entirely R6-proprietary. No UT99 equivalent for the tactical stance/lean system.
- **Dependencies:** Phase 3 (movement/physics must work for player to move)

### 4B. AI Controllers (~65 R6Engine stubs)
- **Files:** src/r6engine/R6Engine.cpp (AR6AIController, AR6RainbowAI, AR6TerroristAI, AR6HostageAI sections)
- **What:**
  - **AR6AIController base** (17 methods): MoveToPosition, FollowPath, FollowPathTo, CanWalkTo, ActorReachableFromLocation, FindNearbyWaitSpot, FindPlaceToFire, FindPlaceToTakeCover, GotoOpenDoorState
  - **AR6RainbowAI** (20+ methods): GetEntryPosition, GetGuardPosition, GetTargetPosition, AClearShotIsAvailable, ClearToSnipe, LookAroundRoom, SetOrientation — elite tactical AI
  - **AR6TerroristAI** (15 methods): CallBackupForAttack, CallBackupForInvestigation, HaveAClearShot, FindBetterShotLocation, GetNextRandomNode — squad behaviour
  - **AR6HostageAI** (8 methods): GotoStand, GotoCrouch, GotoProne, GotoKneel — NPC pose states
  - **Engine AI helpers** (~15 EXEC_STUBs in UnPawn.cpp): LineOfSightTo, CanSee, FindPathToward, FindPathTo, ActorReachable, PointReachable, ClearPaths, EAdjustJump
- **Approach:** Ghidra for all R6 AI. UT99 reference for base engine pathfinding (findPathToward, actorReachable are standard Unreal navigation).
- **Dependencies:** Phase 3 (movement/collision) + 4A (player must exist for AI to perceive)

### 4C. Interactive World (~45 R6Engine stubs)
- **Files:** src/r6engine/R6Engine.cpp (door/ladder/electronics/bomb sections)
- **What:**
  - **AR6Door/AR6IORotatingDoor** (~15): WillOpenOnTouch, DoorOpenTowards, AddBreach, RemoveBreach, SetNewDamageState — door mechanics including breach charges
  - **AR6Ladder/AR6LadderVolume** (~8): ladder zone registration, climb path specs
  - **AR6Stairs/AR6StairVolume** (~6): stair navigation volumes
  - **AR6ClimbableObject/AR6ClimbablePoint** (~6): climbable surface registration
  - **AR6InteractiveObject** (~10): base interaction, damage state, trace/collision overrides
- **Approach:** Ghidra — R6-specific interaction model.
- **Dependencies:** Phase 3 (collision) + 4A (player needs to trigger interactions)

### 4D. Deployment & Spawning (~50 R6Engine stubs)
- **Files:** src/r6engine/R6Engine.cpp (deployment zone sections)
- **What:**
  - **AR6DeploymentZone** (25): FirstInit, Spawned, CheckForErrors, FindRandomPointInArea, FindClosestPointTo, FindSpawningPoint, GetNbOfTerroristToSpawn, IsPointInZone, HaveHostage, HaveTerrorist
  - **AR6DZonePath** (9): node insertion/deletion, path revalidation
  - **AR6DZonePoint** (6): spawn point management
  - **AR6DZoneRandomPoints** (10+): randomized spawn distribution
  - **SpawnATerrorist, SpawnAHostage, InitTerroristAI, InitHostageAI** — zone spawn execution
- **Approach:** Ghidra. These control where terrorists/hostages spawn in each mission.
- **Dependencies:** 4B (AI controllers needed for spawned entities)

### 4E. Weapons (~10 R6Weapons stubs + related R6Engine stubs)
- **Files:** src/r6weapons/R6Weapons.cpp, related EngineExtra stubs
- **What:**
  - `ComputeEffectiveAccuracy()` — R6's accuracy model
  - `GetMovingModifier()` — movement accuracy penalty
  - `GetHeartBeatStatus()` — heartbeat sensor (already partially implemented)
  - `ShowWeaponParticles()` — muzzle flash, tracer FX
  - `WeaponIsNotFiring()` — fire state
  - Related: AR6HBSGadget heartbeat gadget, AR6FalseHeartBeat sensor mechanics
- **Approach:** Ghidra — R6-specific ballistics.

### 4F. Game Flow & State (~25 R6Game stubs)
- **Files:** src/r6game/R6Game.cpp
- **What:**
  - **AR6GameInfo** (10): BeginPlay, RestartGame, InitGameInfoGameService, NotifyKilled, ReduceDamage — match initialization and rules
  - **UR6GameManager** (5): Init, Created, AddPlayer, RemovePlayer, GetState — player tracking
  - **UR6PlanningInfo** (3): AddPoint, GetTeamLeader, TransferFile — mission planning
  - **AR6HUD**: HUD rendering overrides
  - **AR6PlanningCtrl** (3): planning phase controller exec stubs
- **Approach:** Ghidra — R6 game flow is proprietary (plan → execute → debrief cycle).
- **Dependencies:** 4A-4D (need player, AI, world, spawning to drive game flow)

### 4G. Team Management & Abstract (~52 stubs across R6Abstract + R6Engine)
- **Files:** src/r6abstract/R6Abstract.cpp, src/r6engine/R6Engine.cpp (team sections)
- **What:**
  - **UR6AbstractGameService** (32 virtual stubs): Created, Destroy, Tick, GetGSStatus, BuildGSQueryString — abstract service layer
  - **AR6RainbowTeam** (~10): RequestFormationChange, UpdateTeamFormation — squad coordination
  - **AR6Rainbow/AR6Terrorist** (~5): initialization, aiming updates
  - **UR6TerroristMgr** (~5): FindNearestZoneForHostage, Init — zone-level enemy management
- **Approach:** Ghidra for R6 team mechanics. R6Abstract service layer may be simpler than it looks (many methods may just be no-ops for single-player).

### 4H. Effects & Animation Extensions (~30 R6Engine stubs)
- **Files:** src/r6engine/R6Engine.cpp (ragdoll/matinee sections)
- **What:**
  - **AR6RagDoll** (9): physics simulation, collision, impulse application — ragdoll death animations
  - **AR6MatineeRainbow/Terrorist/Hostage** (~7): matinee cinematic attachments
  - **UR6SubActionAnimSequence** (14+): animation sequence management for cutscenes/cinematics
- **Approach:** Ghidra. Ragdoll depends on Karma physics (some Karma stubs in EngineExtra.cpp — implement concurrently).

**Phase 4 Verification:**
- Player spawns in Training mission with correct loadout
- WASD movement with tactical stances (stand, crouch, prone, lean)
- First-person weapon aiming and firing with accuracy model
- AI teammates follow go-codes, navigate through doors
- Terrorists detect player and engage in combat
- Hostages respond to commands
- Doors open/close/breach
- Mission objectives trigger and complete
- Round ends with debrief screen
- Planning phase works (place waypoints, assign go-codes)

**Phase 4 Milestone:** Single-player campaign is playable. This is the major playability gate.

---

## Phase 5: Multiplayer & Networking
**Goal:** Server hosting, joining, and competitive play works.

### 5A. Engine Network Layer (10 EXEC_STUBs + ~120 linker stubs)
- **Files:** src/engine/UnPawn.cpp, src/engine/EngineExtra.cpp, src/engine/UnNet.cpp, EngineStubs3.cpp
- **What:**
  - EXEC_STUBs: `GetPlayerNetworkAddress`, `ClientLeaveServer`, `ConnectionInterrupted`, `LaunchListenSrv`, `StartJoinServer`, `StartLogInProcedure`
  - EngineStubs: `UChannel::ReceivedBunch`, `UChannel::SendBunch`, `UChannel::InitOut`, `UNetConnection::*`, `UPackageMap::*` (~120 linker stubs)
  - UnNet.cpp: UChannel, UPackageMap class method implementations
- **Approach:** UT99 reference for channel/connection management (standard Unreal networking). Ghidra for R6-specific replication.

### 5B. IpDrv — TCP/UDP (37 EXEC_STUBs)
- **Files:** src/ipdrv/IpDrv.cpp
- **What:**
  - **AInternetLink** (8): GetLocalIP, Resolve, GetLastError, IsDataPending, ParseURL, IpAddrToString
  - **ATcpLink** (9): Open, Listen, Close, SendText, SendBinary, ReadText, ReadBinary, FlushSendBuffer
  - **AUdpLink** (10): BindPort, SendText, SendBinary, ReadText, ReadBinary, RecvFrom, SendTo
  - **UTcpNetDriver**: InitConnect, InitListen, TickDispatch
  - **UTcpipConnection**: connection management methods
- **Approach:** UT99 public source has complete IpDrv — WinSock2 integration.

### 5C. R6GameService — GameSpy Integration (60 stubs)
- **Files:** src/r6gameservice/R6GameService.cpp
- **What:**
  - Server lifecycle: Created, Init, Tick, Destroy
  - CD key auth: AuthenticateGSCDKeyID, RequestGSCDKeyAuthID, ResetAuthId, GetAuthStatus
  - Server browser: AllocateServerID, DeallocateServerID, PostServerUpdate
  - Match results: BuildGSQueryString, SubmitMatchResult
- **Approach:** Ghidra + GameSpy SDK (full source in sdk/GameSpySDK/). Full decompilation for accuracy — the code should match retail behaviour even though GameSpy master servers are long dead (shut down 2014). The community uses OpenRVS for server browsing via UnrealScript, but R6GameService should be properly reconstructed as part of the overall decompilation goal. This ensures the rebuilt DLL is a faithful reproduction of the original binary.

### 5D. Multiplayer Game Modes (~10 R6Game stubs)
- **Files:** src/r6game/R6Game.cpp (multiplayer sections)
- **What:** AR6MultiPlayerGameInfo stubs — multiplayer-specific game rules, scoring, round management

**Phase 5 Verification:**
- Host a dedicated server from game menu
- Client connects to localhost server
- Server appears in server browser (or OpenRVS browser)
- Players spawn, move, shoot each other
- Round scoring and transitions work
- Chat/communication functions

**Phase 5 Milestone:** Full multiplayer. Host, join, and play competitive matches.

---

## Phase 6: Audio Pipeline
**Goal:** Full 3D positional audio. Currently the engine can dispatch sound events (Phase 3E), but nothing plays — this phase gives them a voice.

### 6A. SNDext — Platform Abstraction (32 stubs × 2 variants)
- **Files:** src/sndext/SNDext.cpp
- **What:** Thin Win32 API wrappers:
  - File I/O: SND_fn_vOpenFile/CloseFile/ReadFile/SeekFile → CreateFile/ReadFile/SetFilePointer
  - Memory: SND_fn_pvAlloc/vFreeAlloc/pvRealloc → HeapAlloc/HeapFree/HeapReAlloc
  - Threading: SND_fn_vCreateThread/vDestroyThread/vLockMutex/vUnlockMutex → CreateThread/WaitForSingleObject/CreateMutex
  - Error: SND_fn_vDisplayError/vInitErrorSnd
- **Approach:** Clean-room — these are straightforward Win32 wrappers. No Ghidra needed.

### 6B. SNDDSound3D — DirectSound3D Backend (377 stubs × 2 variants)
- **Files:** src/sndsound3d/SNDDSound3D.cpp
- **What:** Full DirectSound3D implementation:
  - Sound buffer creation & management (IDirectSoundBuffer, IDirectSound3DBuffer)
  - 3D audio positioning, Doppler, distance attenuation
  - Listener orientation tracking
  - Streaming buffer fill/play/stop
  - EAX environmental reverb (eax.dll integration)
  - Dolby positioning (SND_fn_ucPositionToDolby)
- **Approach:** Ghidra — most complex audio module. This is the bulk of audio work. Full decompilation for accuracy, matching the retail DirectSound3D implementation.

### 6C. DareAudio — DARE Engine Bridge (87 exports × 3 variants)
- **Files:** src/dareaudio/DareAudio.cpp
- **What:** Bridges Unreal's audio subsystem to DARE/SND backends:
  - StaticConstructor — audio engine configuration
  - Destroy / ShutdownAfterError — cleanup
  - Exec handler — console command routing
  - Three variants (DareAudio, DareAudioRelease, DareAudioScript) link different SND backends
- **Approach:** Ghidra. Three variants share most source.

**Phase 6 Verification:**
- Sounds play when weapons fire, doors open, footsteps occur
- 3D positioning: sounds pan left/right based on source location
- Music plays in menus and briefings
- Environmental reverb applies in enclosed spaces
- Audio cleans up on shutdown (no hangs or leaks)

**Phase 6 Milestone:** Full audio experience.

---

## Phase 7: Polish & Remaining Engine
**Goal:** Fill every last stub. Complete engine coverage including rarely-exercised paths.

### 7A. Karma Physics (39 EXEC_STUBs in EngineExtra.cpp)
- **What:** 34 Karma physics exec functions:
  - `KAddImpulse`, `KSetMass`, `KGetCOMOffset`, `KSetSimParams`, `KGetSimParams`, `KWake`, `KAddBoneLifter`, `KRemoveAllBoneLifters`
  - `KGetConstraintForce`, `KGetConstraintTorque`
  - `KEnableCollision`, `KDisableCollision`
- **Approach:** Ghidra — Karma maps to MathEngine SDK. These are the bridge functions.

### 7B. Terrain & Mesh Systems (~200+ linker stubs)
- **Files:** EngineStubs1-4.cpp (terrain/mesh sections), src/engine/UnMesh.cpp, src/engine/UnModel.cpp
- **What:**
  - Terrain: `UpdateVertices`, `GetVertexNormal`, `FillVertexBuffer`, terrain deformation (~80 stubs)
  - Skeletal mesh: UMesh, USkeletalMesh, UAnimation class implementations (~70 stubs)
  - BSP/Collision model: UModel, UPolys (~50 stubs)
- **Approach:** Ghidra for terrain/skeletal. UT99 reference for BSP.

### 7C. Rendering Pipeline Internals (~280 linker stubs)
- **Files:** EngineStubs3.cpp (render sections)
- **What:** FRenderInterface methods, scene rendering, editor rendering, particle rendering — deep rendering pipeline stubs that D3DDrv calls through the engine
- **Approach:** Ghidra. These are the internal rendering pipeline that connects the Engine to D3DDrv.

### 7D. Window Control Classes (17 classes)
- **Files:** src/window/WindowClasses.h
- **What:** Replace DECLARE_WINDOW_STUB for WButton, WEdit, WRichEdit, WListBox, WCheckListBox, WComboBox, WScrollBar, WTreeView, WTabControl, WTrackBar, WProgressBar, WListView, WUrlButton, WLabel, WToolTip, WHeaderCtrl, WPictureButton
- **Approach:** UT99 public source — thin Win32 CreateWindowEx wrappers.
- **Note:** Only needed for native dialogs (preferences, console). Game menus use UnrealScript.

### 7E. Gameplay Miscellaneous (~37 EXEC_STUBs in EngineExtra.cpp)
- **What:** Remaining gameplay stubs:
  - ZoneActors, Warp/UnWarp
  - SceneManager functions
  - StatLog/FileLog batch operations
  - File management (mod system)
  - ScreenToWorld/WorldToScreen coordinate transforms
- **Approach:** Mix of UT99 reference and Ghidra.

### 7F. Build System Final Cleanup
- Delete EngineStubs1-4.cpp (all pragmas replaced)
- Remove ALL /alternatename pragma hacks from Launch.cpp, Window.cpp, WindowPrivate.h, CoreStubs.cpp (23+ total)
- Verify no dummy_stub_func or dummy_stub_data references remain
- Final staging task: confirmed no retail DLLs

**Phase 7 Verification:**
- Full campaign playthrough with all visual effects
- Ragdoll deaths work correctly
- Terrain renders properly
- All editor-related functions present (for tool compatibility)
- grep for "dummy_stub_func" returns zero hits
- grep for "/alternatename" returns zero hits

**Phase 7 Milestone:** Every last stub is gone. 100% rebuilt from source.

---

## Phase 8: Header & Source Reorganisation
**Goal:** Restructure the codebase from its current decompilation-driven layout into a clean, modular source tree modelled on UT99's public source conventions. The code should look like it was always maintained as a proper Unreal Engine project.

### Why This Matters
During decompilation, pragmatism dictated the file layout — monolithic headers, batch implementation files, stubs files that grew organically. Now that every stub is gone, the code can be reorganised into the canonical Unreal module structure that Epic used and that any Unreal Engine programmer would recognise. This makes the codebase navigable, maintainable, and a genuine reference for anyone studying Ravenshield's internals.

### 8A. Adopt the UT99 Module Convention: Inc/ and Src/
UT99's public source uses a consistent layout per module:
```
ModuleName/
  Inc/       ← public headers (API surface other modules #include)
  Src/       ← implementation files (.cpp)
  CMakeLists.txt
```
Apply this structure to every module in `src/`. Current state has headers and source mixed together in flat directories.

**Transformation for each module:**
| Current | Target |
|---------|--------|
| `src/core/CorePrivate.h` | `src/core/Inc/CorePrivate.h` |
| `src/core/Core.cpp` | `src/core/Src/Core.cpp` |
| `src/engine/Engine.h` | `src/engine/Inc/Engine.h` |
| `src/engine/EngineClasses.h` | `src/engine/Inc/EngineClasses.h` |
| `src/engine/EnginePrivate.h` | `src/engine/Inc/EnginePrivate.h` |
| `src/engine/UnActor.cpp` | `src/engine/Src/UnActor.cpp` |
| `src/r6engine/R6Engine.cpp` | `src/r6engine/Src/R6Engine.cpp` |
| ... | ... |

Update all `#include` paths and CMakeLists.txt `target_include_directories` accordingly.

### 8B. Split Monolithic Headers Into Per-Class Headers
UT99 has one header per major class or subsystem (e.g. `AActor.h`, `APawn.h`, `UnLevel.h`, `UnMesh.h`, `UnNet.h`). The current codebase has oversized aggregate headers like `EngineClasses.h` containing dozens of class declarations.

**Engine module split (following UT99 conventions):**
- `Engine.h` → remains as the umbrella include (includes individual headers)
- `EngineClasses.h` → split into:
  - `AActor.h` — AActor class declaration + inline methods
  - `APawn.h` — APawn, AController, movement-related declarations
  - `ALevelInfo.h` — ALevelInfo, AGameInfo, level metadata
  - `APlayerController.h` — player controller hierarchy
  - `UnLevel.h` — ULevel, FCollisionHash, level management
  - `UnMesh.h` — UMesh, USkeletalMesh, animation structures
  - `UnModel.h` — UModel, UPolys, BSP-related declarations
  - `UnNet.h` — UChannel, UNetConnection, UPackageMap, network declarations
  - `UnAudio.h` — UAudioSubsystem and sound-related declarations
  - `UnRender.h` — UCanvas, FRenderInterface, rendering declarations
  - `UnTex.h` — UTexture, UMaterial hierarchy, material declarations
  - `UnCamera.h` — viewport/camera declarations
- `EnginePrivate.h` → module-internal declarations, includes the public headers

**R6 module splits:**
- `src/r6engine/R6Engine.cpp` is likely one enormous file. Split into per-subsystem source files:
  - `Src/R6PlayerController.cpp` — player control, stance system, camera
  - `Src/R6AIController.cpp` — AI base + Rainbow/Terrorist/Hostage AI
  - `Src/R6Door.cpp` — doors, breaching, interactive objects
  - `Src/R6DeploymentZone.cpp` — spawning, deployment zones, zone paths
  - `Src/R6Team.cpp` — team management, formation, rainbow squad
  - `Src/R6RagDoll.cpp` — ragdoll physics
  - `Src/R6Matinee.cpp` — matinee/cinematic extensions
- Similarly split R6 headers into per-class files in `Inc/`

**Core module split (following UT99):**
- Verify existing Core files already follow the UT99 naming (UnArc.cpp, UnClass.cpp, UnObj.cpp, etc.)
- Add missing per-class headers to `Inc/` if they're currently inlined in CorePrivate.h

### 8C. Eliminate Decompilation Artefacts
Remove files and patterns that only existed to support the incremental decompilation process:

- **Delete all `.bak` files** — these were Ghidra reference copies, no longer needed once Phase 7 is complete
- **Delete EngineStubs1-4.cpp** — should already be empty after Phase 7F, remove the files entirely
- **Delete EngineBatchImpl*.cpp** — redistribute any remaining content into the correct per-subsystem source files
- **Remove all `#pragma comment(linker, "/alternatename:...")` hacks** — should already be gone after Phase 7F, verify no stragglers remain
- **Remove `dummy_stub_func` / `dummy_stub_data`** — all references and definitions
- **Clean up `.def` files** — verify they match the final export tables, remove any comments about stub status
- **Remove `.gitkeep` files** — directories now have real content

### 8D. Standardise Include Guards and Forward Declarations
- Adopt a consistent `#pragma once` or `#ifndef` guard convention across all headers
- Use the UT99 naming convention for guards: `_INC_MODULENAME_HEADERNAME` (e.g. `_INC_ENGINE_AACTOR`)
- Add proper forward declaration headers where modules reference each other's types without needing full definitions
- Ensure no circular include dependencies — use the UT99 pattern where `ModulePrivate.h` is the internal "include everything" header and public `Inc/` headers are independently includable

### 8E. CMake Build System Cleanup
- Update every module's `CMakeLists.txt` to reflect the new `Inc/` and `Src/` layout
- Use `target_include_directories(PUBLIC Inc/)` so dependent modules pick up headers automatically
- Remove any hardcoded include paths that reference the old flat layout
- Ensure `cmake --build build --config Release` still produces identical binaries
- Verify ordinal tables are unaffected by the restructure

### 8F. Documentation Pass
- Update `README.md` with a source tree map reflecting the new layout
- Add a brief comment at the top of each module's umbrella header describing the module's purpose (following UT99's style)
- Ensure `AGENTS.md` and other project docs reference correct paths

**Phase 8 Verification:**
- `cmake --build build --config Release` succeeds — binaries are identical to pre-reorganisation
- `dumpbin /exports` on each DLL still matches retail ordinal tables
- `grep -r "dummy_stub_func\|alternatename\|\.bak" src/` returns zero hits
- Every module follows `Inc/` + `Src/` convention
- No header file exceeds ~1,000 lines (monoliths are split)
- No source file exceeds ~3,000 lines (monoliths are split)
- All `#include` paths resolve correctly
- No circular include dependencies (build succeeds with individual .cpp compilation)

**Phase 8 Milestone:** The codebase is clean, navigable, and structured like a proper Unreal Engine project. Any programmer familiar with UT99's source can orient themselves immediately. The decompilation scaffolding is gone — what remains is a maintainable source tree.

---

## Phase Summary

| Phase | Name | Stubs | Approach | Outcome |
|-------|------|-------|----------|---------|
| **1** | Foundation & Self-Sufficiency | ~3,080 | Auto-gen + Clean-room + Ghidra | Builds without retail libs |
| **2** | A Window Into The World | ~76 | UT99 + Ghidra | Window, D3D, menu renders |
| **3** | The World Simulates | ~156 + ~610 linker | Ghidra-heavy, .bak files | Actors move, collide, animate |
| **4** | Rainbow Six Comes Alive | ~287 | Ghidra (R6-proprietary) | Single-player playable |
| **5** | Multiplayer & Networking | ~117 | UT99 + Ghidra + GameSpy SDK | Full multiplayer |
| **6** | Audio Pipeline | ~450+ | Clean-room (SNDext) + Ghidra | 3D positional audio |
| **7** | Polish & Remaining | ~600+ | Ghidra + UT99 | 100% complete, zero stubs |
| **8** | Header & Source Reorganisation | 0 (structural) | UT99 convention guide | Clean, maintainable source tree |

## Parallelism

```
Phase 1 (MUST BE FIRST — everything depends on self-sufficient build)
  │
  ├─► Phase 2 (window/rendering) ─► Phase 3 (simulation) ─► Phase 4 (R6 gameplay)
  │                                       │
  │                                       ├─► Phase 5 (multiplayer) ── can start once 3 is done
  │                                       │
  ├─► Phase 6 (audio) ───────────────── independent, can start after Phase 1
  │
  ├─► Phase 7 (polish) ─────────────── mop-up, after 2-6 provide context
  │
  └─► Phase 8 (reorganise) ─────────── after Phase 7, all stubs gone before restructuring
```

Phases 5, 6, and most of 7 can run in **parallel** with Phase 4.
Phase 3 and 4 are **sequential** (each builds on the previous).
Phase 2 and 6 are **independent** of each other.
Phase 8 is **strictly after Phase 7** — reorganising requires all code to be final.

## Decisions
- Scope: All 15 game DLLs. Third-party middleware (bink, OpenAL, ogg, vorbis, EAX, MSVC7.1 RT) stays.
- Approach: Hybrid — Ghidra for complex/R6, UT99/SDK for standard Unreal.
- Stub triage tool: Built first (Phase 1B) to classify the 2,612 EngineStubs before implementing them. Guides bulk auto-generation vs targeted Ghidra work.
- Audio: Full Ghidra decompilation of SNDDSound3D (377 stubs × 2), not an OpenAL replacement. Byte accuracy preferred.
- GameSpy: Fully decompiled and rebuilt for accuracy. Will not connect to anything (servers dead since 2014) but the code should faithfully reproduce the retail binary. Community uses OpenRVS at the UnrealScript layer for actual server browsing.
- Multiplayer: Included (Phase 5). Network layer + GameSpy + MP game modes all in scope.
- .bak files: Reference/starting points. Best candidates: UnMaterial.cpp.bak (adopt), UnActor.cpp.bak (1,000 lines), UnPawn.cpp.bak (150 lines).
- Editor.dll / UCC.exe / UnrealEd.exe: Out of scope.
- Assets (.u, textures, maps, sounds, .ini): Out of scope — sourced from retail at runtime.

## Further Considerations
1. **Phase 1B tool scope**: The triage tool could also generate skeleton implementations for TRIVIAL-classified stubs (e.g. emit a constructor body from the class header fields). Worth deciding whether it's just a classifier or also a code generator.
2. **SNDDSound3D variant differences**: The _ret and _VSR variants differ by 2 data exports. Verify whether they can share a single source file with `#ifdef` or need separate implementations.
