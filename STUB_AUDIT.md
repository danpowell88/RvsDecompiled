# Phase 9B – Comprehensive Stub & Incomplete Implementation Audit

> **Generated:** Phase 9B of the Decompilation Plan  
> **Scope:** All files under `src/`  
> **Legend:**  
> - **Stub** – Empty body or returns a default value (0, NULL, "")  
> - **EXEC_STUB** – UnrealScript native function stub (P_FINISH only, no logic)  
> - **Linker Stub** – `/alternatename` pragma redirecting to `dummy_stub_func`  
> - **TODO** – Has a TODO comment indicating future work needed  
> - **Partial** – Has some logic but is incomplete  
> - **Implemented** – Considered complete (included for context where relevant)

---

## Summary

| Module | File(s) | Stub Count | Primary Stub Type |
|--------|---------|------------|-------------------|
| Core | CoreStubs.cpp | ~80 | Linker + exec stubs |
| Engine (EXEC_STUB) | UnActor, UnPawn, UnRender, UnEffects, UnLevel, EngineExtra | ~365 | EXEC_STUB macro |
| Engine (Linker) | EngineStubs1–4.cpp | 2,612 | /alternatename pragma |
| Engine (Other) | Engine.cpp, UnNet.cpp, UnModel.cpp, UnMesh.cpp, UnMaterial.cpp | ~25 | Virtual method stubs |
| D3DDrv | D3DDrv.cpp | ~5 | Empty methods |
| WinDrv | WinDrv.cpp | ~43 | Virtual method stubs |
| Window | Window.cpp + WindowClasses.h | 17 classes | DECLARE_WINDOW_STUB |
| Fire | Fire.cpp | 0 | (Mostly implemented) |
| IpDrv | IpDrv.cpp | ~37 | exec + method stubs |
| Launch | Launch.cpp | 7 | TODO Phase 9B |
| R6Abstract | R6Abstract.cpp | ~32 | Virtual method stubs |
| R6Engine | R6Engine.cpp | ~200+ | Empty virtual overrides |
| R6Game | R6Game.cpp | ~25 | Method + exec stubs |
| R6GameService | R6GameService.cpp | ~60+ | Method stubs |
| R6Weapons | R6Weapons.cpp | ~10 | Virtual method stubs |
| DareAudio | DareAudio.cpp | ~5 | UObject interface stubs |
| SNDDSound3D | SNDDSound3D.cpp | ~377 | return 0 / empty body |
| SNDext | SNDext.cpp | ~32 | return 0 / empty body |
| **TOTAL** | | **~3,930+** | |

---

## Core

| File | Line(s) | Function / Group | Status | Notes |
|------|---------|-----------------|--------|-------|
| CoreStubs.cpp | 50–200 | Math utility exports (appFloor, appCeil, appSqrt, appAtan2, etc.) | Stub | Linker /alternatename to dummy or minimal wrappers |
| CoreStubs.cpp | 200–800 | FString, TArray, TMap operators & methods | Stub | Linker stubs for template instantiations |
| CoreStubs.cpp | 800–1222 | UObject/UClass/UPackage virtual methods | Stub | Many /alternatename directives |
| CoreStubs.cpp | 1222–1400 | UCommandlet stubs (Main, StaticConstructor) | Stub | Empty bodies, return 0 |
| CoreStubs.cpp | 1452 | execVRand, execVSize, execRand, etc. | EXEC_STUB | P_FINISH only |

---

## Engine – EXEC_STUB Functions

### UnActor.cpp (162 EXEC_STUBS)

| File | Line(s) | Function Group | Status | Notes |
|------|---------|---------------|--------|-------|
| UnActor.cpp | 46–60 | Movement: execMove, execSetLocation, execSetRotation, execSetPhysics, execAutonomousPhysics, execMoveSmooth, execSetBase | EXEC_STUB | 7 stubs |
| UnActor.cpp | 60–80 | Animation: execPlayAnim, execLoopAnim, execTweenAnim, execFinishAnim, execHasAnim, execStopAnimating, execFreezeAnimAt, execSetAnimFrame, execAnimIsInGroup | EXEC_STUB | 9 stubs |
| UnActor.cpp | 80–100 | Bone/Skeletal: execGetBoneCoords, execGetBoneLocation, execGetBoneRotation, execSetBoneLocation, execSetBoneRotation, execAttachToBone, execGetMeshName, etc. | EXEC_STUB | ~15 stubs |
| UnActor.cpp | 100–120 | Sound: execPlaySound, execPlayMusic, execStopAllSounds, execFadeSound, execAddSoundBank, execGetSoundDuration | EXEC_STUB | ~10 stubs |
| UnActor.cpp | 120–140 | Iterators: execAllActors, execDynamicActors, execChildActors, execBasedActors, execTouchingActors, execRadiusActors, execVisibleActors, execVisibleCollidingActors, execTraceActors, execConnectedDoors | EXEC_STUB | ~10 stubs |
| UnActor.cpp | 140–170 | Trace/Collision: execTrace, execFastTrace, execSpawn, execDestroy, execSetTimer, execSetCollision, execSetCollisionSize, execSetDrawScale, execSetDrawScale3D, execSetStaticMesh, execSetDrawType | EXEC_STUB | ~15 stubs |
| UnActor.cpp | 170–185 | R6-Specific: execGetGameManager, execGetModMgr, execPlanningMode, execGetPlanningInfo, execLoadingScreen, execSetShadow, execIsDedicatedServer | EXEC_STUB | ~10 stubs |
| UnActor.cpp | 185–209 | Math/Misc: execAdd_ColorColor, execMultiply_ColorFloat, execSubtract_ColorColor, execSleep, execFinishInterpolation, execError, execGotoState, execSetPropertyText, execGetPropertyText, execGetEnum, execDynamicLoadObject, execFindObject, execGetURLMap, execPlayerCanSeeMe | EXEC_STUB | ~25 stubs |

### UnPawn.cpp (59 EXEC_STUBS)

| File | Line(s) | Function Group | Status | Notes |
|------|---------|---------------|--------|-------|
| UnPawn.cpp | 11–20 | APawn: execReachedDestination, execIsFriend, execIsEnemy, execIsNeutral, execIsAlive, execFindPathTo, execFindPathToward | EXEC_STUB | 7 stubs |
| UnPawn.cpp | 20–40 | AController: execMoveTo, execMoveToward, execFinishRotation, execWaitForLanding, execLineOfSightTo, execCanSee, execCanSeeByPoints, execFindPathTo, execFindPathToward, execFindBestInventoryPath, execFindRandomDest, execPickWallAdjust, execActorReachable, execPointReachable | EXEC_STUB | ~20 stubs |
| UnPawn.cpp | 40–60 | APlayerController: execFindStairRotation, execResetKeyboard, execConsoleCommand, execClientTravel, execPunkBusterCommand, execGetPlayerNetworkAddress, execGetServerNetworkAddress, execClientPlaySound, execClientPlayForceFeedback, execClientStopForceFeedback, execClientMessage, etc. | EXEC_STUB | ~25 stubs |
| UnPawn.cpp | 60–71 | AAIController: execWaitToSeeEnemy, execPollWaitToSeeEnemy + misc | EXEC_STUB | ~7 stubs |

### UnRender.cpp (27 EXEC_STUBS)

| File | Line(s) | Function Group | Status | Notes |
|------|---------|---------------|--------|-------|
| UnRender.cpp | 10–35 | UCanvas: execSetPos, execSetOrigin, execSetClip, execSetDrawColor, execDrawText, execDrawTile, execDrawActor, execDrawTileClipped, execDrawTextClipped, execTextSize, execStrLen, execDrawPortal | EXEC_STUB | ~15 stubs |
| UnRender.cpp | 35–40 | UCanvas: execGetVideoSetting, execSetVideoSetting, execGetVideoSettingCount | EXEC_STUB | 3 stubs |
| UnRender.cpp | 40–42 | AHUD: execDraw3DLine + UCanvas virtual interface stubs | EXEC_STUB / Stub | Remaining stubs |

### UnEffects.cpp (9 EXEC_STUBS)

| File | Line(s) | Function Group | Status | Notes |
|------|---------|---------------|--------|-------|
| UnEffects.cpp | 11–15 | AEmitter: execKill, AProjector: execAbandon, execAttachProjector, execDetachProjector, execReattachProjector | EXEC_STUB | 5 stubs |
| UnEffects.cpp | 15–21 | UParticleEmitter: execSpawnParticle + remaining | EXEC_STUB | 4 stubs |

### UnLevel.cpp (20 EXEC_STUBS)

| File | Line(s) | Function Group | Status | Notes |
|------|---------|---------------|--------|-------|
| UnLevel.cpp | 16–25 | ALevelInfo: execGetAddressURL, execGetLocalURL, execFinalizeLoading, execSetBankSound, execNotifyMatchStart, execPBNotifyServerTravel, execIsWritableMap, execPrepareMapModDownloads | EXEC_STUB | 8 stubs |
| UnLevel.cpp | 25–37 | AGameInfo: execGetNetworkNumber, execParseKillMessage, execProcessR6Availabilty, execAbortScoreSubmission, execGetMapListName, execDetourToMainMenu, execInitGameInfoGameService, execAreThereArmoredDoors, execGetMasterServerManager | EXEC_STUB | 12 stubs |

### EngineExtra.cpp (95 EXEC_STUBS)

| File | Line(s) | Function Group | Status | Notes |
|------|---------|---------------|--------|-------|
| EngineExtra.cpp | 193–230 | AActor Karma: execKGetActorGravScale, execKSetActorGravScale, execKGetCOMPosition, execKGetCOMVelocity, execKGetInertiaTensor, execKSetMass, execKAddImpulse, execKSetStayUpright, execKSetBlockKarma, etc. (34 K* funcs) | EXEC_STUB | 34 stubs |
| EngineExtra.cpp | 230–260 | Zone/Volume/Fluid/Warp: execEncompasses, execZoneActors, execWarp, execUnWarp, execPling | EXEC_STUB | 5 stubs |
| EngineExtra.cpp | 260–280 | AStatLog/AStatLogFile: execGetMapFileName, execBatchLocal, execFlushLog, execLogEventString, etc. | EXEC_STUB | 15 stubs |
| EngineExtra.cpp | 280–300 | R6-Specific: AR6ColBox, AR6DecalGroup (4), AR6DecalManager (2), AR6eviLTesting | EXEC_STUB | 8 stubs |
| EngineExtra.cpp | 300–324 | UInteraction (4), UInteractionMaster, UR6AbstractGameManager (9), UR6FileManager (4), UR6ModMgr (7) | EXEC_STUB | 33 stubs |

---

## Engine – Linker Stubs (EngineStubs1–4.cpp)

| File | Lines | Directive Count | Categories Covered | Status | Notes |
|------|-------|----------------|-------------------|--------|-------|
| EngineStubs1.cpp | ~588 | 588 | Physics, events, actor methods, rendering, networking, animation, skeletal mesh, terrain | Linker Stub | All → `dummy_stub_func` |
| EngineStubs2.cpp | ~800 | 800 | Set* functions, collision, client travel, terrain brushes, matinee, canvas, level loading | Linker Stub | All → `dummy_stub_func` |
| EngineStubs3.cpp | ~800 | 800 | Destructors, TArray operators, constructors, operator= for UObject-derived classes | Linker Stub | All → `dummy_stub_func` / `dummy_stub_data` |
| EngineStubs4.cpp | ~424 | 424 | Get* functions, input, terrain, level, scene nodes, mesh instances, HUD | Linker Stub | All → `dummy_stub_func` |
| **Total** | | **2,612** | | | These satisfy the linker but contain no real logic |

---

## Engine – Other Stub Files

| File | Line(s) | Function / Group | Status | Notes |
|------|---------|-----------------|--------|-------|
| Engine.cpp | 30+ | UPrimitive virtual function stubs (PointCheck, LineCheck, GetRenderBoundingSphere) | Stub | Empty bodies, return 0 |
| UnNet.cpp | 2+ | UPackageMap, UChannel, UControlChannel, UActorChannel, UFileChannel stubs | Stub | Minimal constructors, empty methods |
| UnModel.cpp | 2+ | UModel, UPolys class stubs | Stub | Minimal vtable satisfaction |
| UnMesh.cpp | 2+ | UMesh, USkeletalMesh, UAnimation class stubs | Stub | Minimal vtable satisfaction |
| UnMaterial.cpp | 2+ | UMaterial, UTexture, UBitmapMaterial class stubs | Stub | Minimal vtable satisfaction |

---

## D3DDrv

| File | Line | Function | Status | Notes |
|------|------|----------|--------|-------|
| D3DDrv.cpp | 820 | SetEmulationMode() | Stub | Intentionally empty – display mode setup |
| D3DDrv.cpp | 327 | (comment) UViewport stub lacks GetWindow() | TODO | Viewport integration incomplete |
| D3DDrv.cpp | 603 | (comment) UViewport stub does not yet expose GetOuterUClient() | TODO | Client access incomplete |
| D3DDrv.cpp | 1015–1018 | StartVideo() | Stub | No-op |
| D3DDrv.cpp | 1023–1026 | StopVideo() | Partial | Delegates to CloseVideo only |
| D3DDrv.cpp | 1106–1110 | HandleFullScreenEffects() | Stub | Empty guard/unguard body |

---

## WinDrv

### UWindowsViewport (~30 stubs)

| File | Line(s) | Function | Status | Notes |
|------|---------|----------|--------|-------|
| WinDrv.cpp | 78 | Destroy() | Stub | Empty body |
| WinDrv.cpp | 81 | ShutdownAfterError() | Stub | Empty body |
| WinDrv.cpp | 84 | Exec(cmd, Ar) | Stub | return 0 |
| WinDrv.cpp | 93 | Lock(FPlane, FPlane, FPlane, FPlane, BYTE, DWORD) | Stub | return 0 |
| WinDrv.cpp | 102 | Unlock() | Stub | Empty body |
| WinDrv.cpp | 105 | IsFullscreen() | Stub | return 0 |
| WinDrv.cpp | 108 | ResizeViewport(flags, x, y, cx, cy) | Stub | return 0 |
| WinDrv.cpp | 117 | SetModeCursor() | Stub | Empty body |
| WinDrv.cpp | 120 | UpdateWindowFrame() | Stub | Empty body |
| WinDrv.cpp | 123 | OpenWindow(parent, temp, x, y, cx, cy) | Stub | Empty body |
| WinDrv.cpp | 132 | CloseWindow() | Stub | Empty body |
| WinDrv.cpp | 135 | UpdateInput(reset) | Stub | Empty body |
| WinDrv.cpp | 144 | GetWindow() | Stub | return NULL – **critical** for D3DDrv |
| WinDrv.cpp | 150 | SetMouseCapture(capture, clip, focus) | Stub | Empty body |
| WinDrv.cpp | 159 | Repaint(blit) | Stub | Empty body |
| WinDrv.cpp | 168 | TryRenderDevice(api, x, y, cx, fullscreen) | Stub | Empty body – **critical** for rendering |
| WinDrv.cpp | 177 | Hold/Minimize/Maximize/Restore | Stub | 4 empty methods |
| WinDrv.cpp | 192 | CheckCD(name) | Stub | Empty body |
| WinDrv.cpp | 198 | AcquireKeyboard() / ReleaseKeyboard() | Stub | 2 empty methods |
| WinDrv.cpp | 210 | KeyPressed(key) | Stub | return 0 |
| WinDrv.cpp | 218 | ToggleFullscreen() / EndFullscreen() | Stub | 2 empty methods |
| WinDrv.cpp | 230 | CauseInputEvent(key, action) | Stub | return 0 |
| WinDrv.cpp | 239 | SetTopness() | Stub | Empty body |
| WinDrv.cpp | 245 | GetViewportButtonFlags(flags) | Stub | return 0 |
| WinDrv.cpp | 254 | JoystickInputEvent(joy, key, delta, bAxis) | Stub | return 0 |
| WinDrv.cpp | 265 | ViewportWndProc(msg, wParam, lParam) | Stub | return 0 – **critical** for message pump |

### UWindowsClient (~13 stubs)

| File | Line(s) | Function | Status | Notes |
|------|---------|----------|--------|-------|
| WinDrv.cpp | 309 | StaticConstructor() | Stub | Empty body |
| WinDrv.cpp | 313 | Destroy() | Stub | Empty body |
| WinDrv.cpp | 319 | ShutdownAfterError() | Stub | Empty body |
| WinDrv.cpp | 325 | PostEditChange() | Stub | Empty body |
| WinDrv.cpp | 331 | NotifyDestroy(Other) | Stub | Empty body |
| WinDrv.cpp | 340 | Init(InEngine) | Stub | Empty body – **critical** for startup |
| WinDrv.cpp | 349 | ShowViewportWindows(show, cmd) | Stub | Empty body |
| WinDrv.cpp | 358 | EnableViewportWindows(enable, cmd) | Stub | Empty body |
| WinDrv.cpp | 370 | Tick(DeltaTime) | Stub | Empty body – **critical** for frame loop |
| WinDrv.cpp | 379 | Exec(cmd, Ar) | Stub | return 0 |
| WinDrv.cpp | 395 | NewViewport(name) | Stub | Empty body – **critical** for viewport creation |
| WinDrv.cpp | 401 | MakeCurrent(viewport) | Stub | Empty body |
| WinDrv.cpp | 410 | GetLastCurrent() | Stub | return NULL |

---

## Window

| File | Line(s) | Function / Class | Status | Notes |
|------|---------|-----------------|--------|-------|
| Window.cpp | – | InitWindowing() | Implemented | Registers WNDCLASS |
| Window.cpp | – | LoadFileToBitmap(name) | Implemented | Loads BMP from file |
| Window.cpp | – | UWindowManager::Tick() | Stub | Empty body |
| WindowClasses.h | – | DECLARE_WINDOW_STUB × 17 classes | Stub | WButton, WEdit, WRichEdit, WListBox, WCheckListBox, WComboBox, WScrollBar, WTreeView, WTabControl, WTrackBar, WProgressBar, WListView, WUrlButton, WLabel, WToolTip, WHeaderCtrl, WPictureButton |

---

## Fire

| File | Line(s) | Function | Status | Notes |
|------|---------|----------|--------|-------|
| Fire.cpp | – | FSpark/FDrop/KeyPoint operator= | Implemented | Actual logic |
| Fire.cpp | – | UFractalTexture::Init | Implemented | Actual logic |
| Fire.cpp | – | IMPLEMENT_CLASS × 7 | Implemented | Procedural texture registration |

> **Fire has no stubs** – it is one of the most complete modules.

---

## IpDrv

### Native Exec Stubs (27)

| File | Line(s) | Function Group | Status | Notes |
|------|---------|---------------|--------|-------|
| IpDrv.cpp | 40–80 | AInternetLink: execGetLocalIP, execStringToIpAddr, execIpAddrToString, execGetLastError, execResolve, execParseURL, execIsDataPending, execValidate | EXEC_STUB | 8 stubs (P_FINISH only) |
| IpDrv.cpp | 80–130 | ATcpLink: execOpen, execListen, execClose, execIsConnected, execSendText, execSendBinary, execReadText, execReadBinary, execBindPort | EXEC_STUB | 9 stubs |
| IpDrv.cpp | 130–180 | AUdpLink: execBindPort, execSendText, execSendBinary, execReadText, execReadBinary, execBroadcastText, execBroadcastBinary, execResolvePath, execReceivedText, execReceivedBinary | EXEC_STUB | 10 stubs |

### Method Stubs (~10)

| File | Line(s) | Function | Status | Notes |
|------|---------|----------|--------|-------|
| IpDrv.cpp | ~200 | ATcpLink::FlushSendBuffer() | Stub | return 0 |
| IpDrv.cpp | ~210 | ATcpLink::CheckConnectionAttempt() | Stub | Empty body |
| IpDrv.cpp | ~220 | ATcpLink::CheckConnectionQueue() | Stub | Empty body |
| IpDrv.cpp | ~230 | ATcpLink::PollConnections() | Stub | Empty body |
| IpDrv.cpp | ~240 | ATcpLink::ShutdownConnection() | Stub | Empty body |
| IpDrv.cpp | ~260+ | AUdpLink equivalent methods | Stub | Empty bodies |

---

## Launch

| File | Line | Function / Context | Status | Notes |
|------|------|--------------------|--------|-------|
| Launch.cpp | 136 | FExecHook::Exec – "TakeFocus" branch | TODO | Needs UEngine::Client member offset |
| Launch.cpp | 142 | FExecHook::Exec – "EditActor" branch | TODO | Needs AActor::Location, bDeleteMe, GetLevel() |
| Launch.cpp | 149 | FExecHook::Exec – "Preferences" branch | TODO | Needs WConfigProperties implementation |
| Launch.cpp | 320 | Engine->Init() call | TODO | Needs correct UEngine vtable layout |
| Launch.cpp | 360 | Engine->Tick(DeltaTime) call | TODO | Needs correct UEngine vtable layout |
| Launch.cpp | 372–373 | Engine->GetMaxTickRate() | TODO | Placeholder returns 60.0f; needs vtable |
| Launch.cpp | 503 | Engine->Client->Viewports(0)->Exec() | TODO | Needs UEngine::Client member |

---

## R6Abstract

| File | Line(s) | Function | Status | Notes |
|------|---------|----------|--------|-------|
| R6Abstract.cpp | 61–70 | UR6AbstractGameService::Created() | Stub | Empty body |
| R6Abstract.cpp | 61–70 | ::DisconnectAllCDKeyPlayers() | Stub | Empty body |
| R6Abstract.cpp | 61–70 | ::RequestGSCDKeyAuthID() | Stub | Empty body |
| R6Abstract.cpp | 61–70 | ::ResetAuthId() | Stub | Empty body |
| R6Abstract.cpp | 61–70 | ::ServerRoundFinish() | Stub | Empty body |
| R6Abstract.cpp | 61–70 | ::SubmitMatchResult() | Stub | Empty body |
| R6Abstract.cpp | 61–70 | ::UnInitializeGSClientSPW() | Stub | Empty body |
| R6Abstract.cpp | 70–85 | 11× INT-returning methods (return 0) | Stub | GetGSStatus, GetNbCDKeyID, BuildGSQueryString, AllocateServerID, DeallocateServerID, GetMasterServerManager, etc. |
| R6Abstract.cpp | 85–98 | 12× void methods with parameters | Stub | AuthenticateGSCDKeyID, PostServerUpdate, SetDNSResolution, UpdateGSPlayerScore, etc. |
| R6Abstract.cpp | 95–98 | 2× BYTE-returning methods (return 0) | Stub | GetAuthStatus, IsAuthenticating |
| R6Abstract.cpp | 45 | SetFunctionPtr() | Implemented | Function pointer assignment |
| R6Abstract.cpp | 55 | execGetState() | Implemented | Calls function pointer callback |

---

## R6Engine

| File | Line(s) | Function / Class Group | Status | Notes |
|------|---------|----------------------|--------|-------|
| R6Engine.cpp | 181–300 | AMP2IOKarma: CheckForErrors (empty), KMP2DynKarmaInterface (return 0) | Stub | 2 stubs |
| R6Engine.cpp | 300–400 | AR6AIController: ~20 empty overrides (AdjustFromWall, CanHear, NotifyBump, NotifyHitWall, etc.) | Stub | Most return 0 or void empty |
| R6Engine.cpp | 400–500 | AR6Pawn: ~15 stubs (GetHumanReadableName, IsHumanControlled, CheckSuperInViewRotation, etc.) | Stub | Mix of empty and return 0 |
| R6Engine.cpp | 500–700 | AR6PlayerController: ~25 stubs (PlayerTick, UpdateRotation, SpawnDefaultHUD, ClientRestart, etc.) | Stub | Key gameplay controller |
| R6Engine.cpp | 700–900 | AR6GameInfo subclasses: ~30 stubs across multiple game types | Stub | Match lifecycle management |
| R6Engine.cpp | 900–1100 | R6 Actors (AR6Bomb, AR6Camera, AR6Door, AR6Electronics, AR6Hostage, etc.): ~40 stubs each | Stub | Game-specific actor logic |
| R6Engine.cpp | 1100–1400 | R6 HUD/Menu/UI classes: ~20 stubs | Stub | Display layer |
| R6Engine.cpp | 1400–1700 | ProcessEvent thunks (eventTick, eventPostBeginPlay, etc.) | Implemented | Event dispatch wrappers |
| R6Engine.cpp | 1700–1926 | execMP2IOKarmaAllNativeFct (P_FINISH only) | EXEC_STUB | 1 native function stub |

> R6Engine.cpp is the largest single file (1,926 lines). The majority of its ~200+ method stubs are empty virtual overrides needed to satisfy the vtable layout. Implementing them requires the original game logic from Ghidra disassembly.

---

## R6Game

| File | Line(s) | Function | Status | Notes |
|------|---------|----------|--------|-------|
| R6Game.cpp | 61–80 | AR6ActionPoint::SetRotationToward() | Stub | Empty body |
| R6Game.cpp | 61–80 | AR6ActionPoint::TransferFile() | Stub | Empty body |
| R6Game.cpp | 80–120 | AR6GameInfo: AbortScoreSubmission, InitGameInfoGameService, MasterServerManager, PostBeginPlay (empty), GetMapListName (empty), DetourToMainMenu (empty) | Stub | 6 method stubs |
| R6Game.cpp | 120–180 | AR6GameInfo exec stubs: execGetNetworkNumber, execParseKillMessage, execProcessR6Availabilty, etc. | EXEC_STUB | 6 exec stubs |
| R6Game.cpp | 180–220 | UR6GameManager: ~15 method stubs (AddPlayer, RemovePlayer, Init, Created, GetState, etc.) | Stub | Core manager – high priority |
| R6Game.cpp | 220–278 | UR6PlanningInfo: AddPoint (empty), GetTeamLeader (return NULL), NoStairsBetweenPoints (return 0), TransferFile (empty), exec stubs | Stub | Planning system |

---

## R6GameService

| File | Line(s) | Function / Group | Status | Notes |
|------|---------|-----------------|--------|-------|
| R6GameService.cpp | 65–120 | UR6GSServers void stubs: Created, Destroy, Init, InitializeGSClient, UnInitializeGSClientSPW, PostServerUpdate, etc. (~25 methods) | Stub | Empty bodies |
| R6GameService.cpp | 120–200 | UR6GSServers INT stubs: GetGSStatus, GetNbCDKeyID, AllocateServerID, DeallocateServerID, GetMasterServerManager, etc. (~15 methods) | Stub | return 0 |
| R6GameService.cpp | 200–350 | UR6GSServers FString stubs: BuildGSQueryString, GetServerProperty, etc. (~5 methods) | Stub | return TEXT("") |
| R6GameService.cpp | 350–500 | CDKey/Auth methods: AuthenticateGSCDKeyID, DisconnectAllCDKeyPlayers, RequestGSCDKeyAuthID, ResetAuthId (~10 methods) | Stub | Empty bodies |
| R6GameService.cpp | 500–652 | Lobby/Registration/Ping/Score methods (~10 remaining) | Stub | Mix of empty and return 0 |

> R6GameService implements the GameSpy integration layer. All ~60+ methods are stubs. Low priority unless multiplayer is targeted.

---

## R6Weapons

| File | Line(s) | Function | Status | Notes |
|------|---------|----------|--------|-------|
| R6Weapons.cpp | 52 | ProcessState() | Partial | Delegates to Super::ProcessState() |
| R6Weapons.cpp | 55 | IsBlockedBy(Other) | Partial | Delegates to Super |
| R6Weapons.cpp | 61 | PreNetReceive() / PostNetReceive() | Partial | Delegates to Super |
| R6Weapons.cpp | 70 | TickAuthoritative(DeltaTime) | Partial | Delegates to Super |
| R6Weapons.cpp | 80 | GetHeartBeatStatus() | Stub | return 0 |
| R6Weapons.cpp | 85 | ShowWeaponParticles() | Stub | Empty body |
| R6Weapons.cpp | 90 | ComputeEffectiveAccuracy() | Stub | return 0.f |
| R6Weapons.cpp | 95 | GetMovingModifier() | Stub | return 0.f |
| R6Weapons.cpp | 100 | WeaponIsNotFiring() | Stub | return true |

---

## DareAudio

| File | Line(s) | Function | Status | Notes |
|------|---------|----------|--------|-------|
| DareAudio.cpp | ~50 | UDareAudioSubsystem::StaticConstructor() | Stub | Empty body |
| DareAudio.cpp | ~60 | ::PostEditChange() | Stub | Empty body |
| DareAudio.cpp | ~70 | ::Destroy() | Stub | Empty body |
| DareAudio.cpp | ~80 | ::ShutdownAfterError() | Stub | Empty body |
| DareAudio.cpp | ~90 | ::Exec(cmd, Ar) | Stub | return 0 |
| DareAudio.cpp | ~100–316 | Static data members (CurrentViewport, SoundVolume, etc.) | Implemented | Init to NULL/0 |

---

## SNDDSound3D

| File | Lines | Type | Count | Notes |
|------|-------|------|-------|-------|
| SNDDSound3D.cpp | 1–381 | INT-returning stubs (return 0) | ~179 | Sound engine backend functions |
| SNDDSound3D.cpp | 1–381 | void stubs (empty body) | ~198 | Sound engine backend functions |
| **Total** | | | **~377** | Entirely auto-generated stub code. Built as both `_ret` and `_vsr` variants. |

Key exported groups: SNDDSound3DInit, SNDDSound3DShutdown, SNDDSound3DCreateSource, SNDDSound3DDestroySource, SNDDSound3DPlay, SNDDSound3DStop, SNDDSound3DSetPosition, SNDDSound3DSetVelocity, SNDDSound3DSetVolume, SNDDSound3DSetFrequency, etc.

---

## SNDext

| File | Lines | Type | Count | Notes |
|------|-------|------|-------|-------|
| SNDext.cpp | 1–145 | Error handling (void, empty) | 4 | SNDextSetErrorCallback, SNDextSetDebugErrorLevel, etc. |
| SNDext.cpp | 1–145 | File I/O (return 0/NULL) | ~12 | SNDextFileOpen, SNDextFileClose, SNDextFileRead, etc. |
| SNDext.cpp | 1–145 | Memory (return 0/NULL) | ~8 | SNDextMemAlloc, SNDextMemFree, SNDextMemReAlloc, etc. |
| SNDext.cpp | 1–145 | Misc (return 0) | ~8 | SNDextGetTime, SNDextSleep, SNDextThreadCreate, etc. |
| **Total** | | | **~32** | Sound extension utility stubs |

---

## Priority Matrix for Implementation

### Critical Path (blocks game from running)

| Priority | Module | Function(s) | Why |
|----------|--------|------------|-----|
| **P0** | Launch | Engine->Init(), Engine->Tick(), GetMaxTickRate() | Game loop cannot execute |
| **P0** | WinDrv | UWindowsClient::Init(), ::Tick(), ::NewViewport() | No window/viewport created |
| **P0** | WinDrv | UWindowsViewport::OpenWindow(), GetWindow(), TryRenderDevice() | No rendering surface |
| **P0** | WinDrv | UWindowsViewport::ViewportWndProc() | No Windows message pump |

### High Priority (blocks gameplay)

| Priority | Module | Function(s) | Why |
|----------|--------|------------|-----|
| **P1** | Engine EXEC_STUB | Actor movement (Move, SetLocation, SetPhysics) | No physics/movement |
| **P1** | Engine EXEC_STUB | Spawn, Destroy, SetTimer | No actor lifecycle |
| **P1** | Engine EXEC_STUB | PlayAnim, LoopAnim, TweenAnim | No animation |
| **P1** | Engine EXEC_STUB | PlaySound, StopAllSounds | No audio |
| **P1** | R6Engine | AR6PlayerController stubs | No player control |
| **P1** | R6Game | UR6GameManager (Init, Created, AddPlayer) | No game session |

### Medium Priority (blocks features)

| Priority | Module | Function(s) | Why |
|----------|--------|------------|-----|
| **P2** | Engine EXEC_STUB | Canvas draw functions (DrawText, DrawTile) | No HUD |
| **P2** | Engine EXEC_STUB | Iterator functions (AllActors, RadiusActors) | No actor queries |
| **P2** | Engine EXEC_STUB | Pathfinding (FindPathTo, FindPathToward) | No AI navigation |
| **P2** | D3DDrv | StartVideo, HandleFullScreenEffects | No video/effects |
| **P2** | IpDrv | TCP/UDP send/receive | No networking |
| **P2** | Window | 17 DECLARE_WINDOW_STUB classes | No native UI controls |

### Low Priority (polish / multiplayer)

| Priority | Module | Function(s) | Why |
|----------|--------|------------|-----|
| **P3** | R6GameService | All ~60+ GameSpy stubs | Multiplayer only |
| **P3** | SNDDSound3D | All ~377 sound stubs | Needs DARE SDK knowledge |
| **P3** | SNDext | All ~32 utility stubs | Needs DARE SDK knowledge |
| **P3** | Engine EXEC_STUB | StatLog functions | Telemetry only |
| **P3** | Engine EngineStubs1–4 | 2,612 linker stubs | Replaced as real implementations arrive |
