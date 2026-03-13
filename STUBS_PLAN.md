# Plan: Complete All ~2,967 Remaining Stubs

Systematically replace every stub across all 16 modules with real decompiled implementations, ordered easiest → hardest, respecting the dependency graph: **Core → Engine → Support DLLs → R6 modules → Audio → Polish**.

---

### Current State

| Module | Stubs | % Done | Status |
|--------|-------|--------|--------|
| D3DDrv | 1 | 96% | Nearly done |
| SNDext | 2 | 94% | Nearly done |
| Window | 3 | 93% | Nearly done |
| WinDrv | 9 | 78% | Input dispatch incomplete |
| Launch | 7 | 74% | Light work |
| Core | ~60 | 62% | Math, MD5, registry |
| R6Engine | ~480 | 40% | AI/pawn partial |
| Engine | ~1,695 | 32% | Largest — stubs across 20+ files |
| R6Game | ~90 | 25% | Game rules, HUD, campaign |
| R6Weapons | 39 | 13% | Ballistics, gadgets |
| R6Abstract | 22 | 12% | Skeleton base classes |
| R6GameService | 22 | 12% | GameSpy (defunct servers) |
| IpDrv | 58 | 12% | Socket I/O |
| Fire | 64 | 6% | Procedural textures |
| DareAudio | 57 | 2% | Audio bridge |
| SNDDSound3D | ~360 | 1% | DirectSound3D backend |

---

## TIER 1: LOW DIFFICULTY (~520 stubs, mostly no Ghidra)

### Phase 1 — Finish Near-Complete Modules (~16 stubs)
Trivial. Closes out D3DDrv, Window, WinDrv, SNDext, Launch.

1. **D3DDrv** — 1 stub: `SetEmulationMode()` in `src/D3DDrv/Src/D3DDrv.cpp`
2. **Window** — 3 stubs: `UWindowManager::Tick/Serialize/Destroy` in `src/Window/Src/Window.cpp`
3. **WinDrv** — 9 stubs: `UpdateInput()`, `ViewportWndProc()`, input capture in `src/WinDrv/Src/WinDrvViewport.cpp` *(parallel with above)*
4. **SNDext** — 2 stubs: `SND_fn_vDisplayError/Ex()` in `src/SNDext/Src/SNDext.cpp` *(parallel)*
5. **Launch** — 7 stubs: `FExecHook::Exec` branches in `src/Launch/Src/Launch.cpp` *(parallel)*

**Gate:** Game window opens, renders, accepts keyboard/mouse input.

### Phase 2 — Engine Trivial Methods (~400 stubs)
Mechanical — constructors, destructors, copy operators, getters, Serialize methods. No complex logic, pattern-based from field layouts.

1. **Constructors & destructors** (~120) — zero-init, `Super::` calls, `appMemzero` patterns
2. **Serialize methods** (~80) — `Ar << Field1 << Field2;` for UObject classes *(parallel)*
3. **PostLoad / PostEditChange** (~30) — rebuild cached data from serialized fields *(parallel)*
4. **operator= & copy ctors** (~60) — memberwise copy *(parallel)*
5. **Simple getters/accessors** (~110) — single-line member returns *(parallel)*

Primary target: empty `src/Engine/Src/EngineStubs.cpp` completely. Move implementations to owner files (e.g. `FSceneNode` → `src/Engine/Src/UnRender.cpp`).

**Gate:** `EngineStubs.cpp` near-empty; build still compiles.

### Phase 3 — Core Stubs & Linker Shim Cleanup (~100 stubs)
*Parallel with Phase 2.*

1. **Core math/utility** (~40) — `FLineExtentBoxIntersection`, `appMD5*` (RFC 1321), `RegGet/RegSet` (Windows registry) in `src/Core/Src/CoreStubs.cpp`
2. **Window control classes** (17) — `WButton`, `WEdit`, `WListBox`, etc. — Win32 `CreateWindowExW` wrappers in `src/Window/Src/Window.cpp` *(parallel)*
3. **Eliminate all 41 `/alternatename` pragmas** — delete `src/Engine/Src/EngineLinkerShims.cpp` as implementations replace shims *(after Phase 2)*

**Gate:** Zero `/alternatename` pragmas remain; `EngineLinkerShims.cpp` deleted.

---

## TIER 2: MEDIUM DIFFICULTY (~1,500 stubs, Ghidra required)

### Phase 4 — Engine Physics & Collision (~290 stubs)
*Depends on Phase 2. Ghidra: Engine.dll.*

1. Physics dispatch: `performPhysics` switch statement (~20) in `src/Engine/Src/UnPhysic.cpp`
2. Walking physics: `physWalking`, `stepUp`, `adjustFloor` (~40) *(depends on step 1)*
3. Falling/flying/swimming (~30) *(depends on step 1)*
4. Projectile & ladder (~20) *(depends on step 1)*
5. Collision system: `FCollisionHash`, `FOctreeNode`, `ULevel::SingleLineCheck` (~80) in `src/Engine/Src/UnActCol.cpp` + `src/Engine/Src/UnLevel.cpp`
6. Movement helpers: `moveSmooth`, `FindSpot`, `TwoWallAdjust` (~90) *(parallel with step 5)*
7. Volume/zone stubs (~9 from UnPhysic.cpp)

**Gate:** Actor movement works — walk, fall, swim, ladder. Collision traces return correct results.

### Phase 5 — Engine Animation & Skeletal Mesh (~200 stubs)
*Parallel with Phase 4. Ghidra: Engine.dll.*

1. Animation playback: `PlayAnim`, `LoopAnim`, `TweenAnim` (~40)
2. Bone control: `SetBonePosition`, `SetBoneRotation`, `GetBoneCoords` (~50)
3. Skeletal mesh instance bridge (~60)
4. LOD mesh & static mesh rendering (~50) *(parallel)*
5. LipSync: `ECLipSynchData` methods (~8) *(parallel)*

**Gate:** Characters animate; bone rotations work; LOD transitions correct.

### Phase 6 — Rendering, Scene Graph & Level Management (~320+ stubs)
*Depends on Phase 2; partially on 4 & 5.*

1. Scene node hierarchy: `FSceneNode` virtual methods (~80)
2. `FRenderInterface` Engine↔D3DDrv bridge (~60)
3. Actor rendering: `RenderEditorInfo`, bounding spheres (~50)
4. Terrain rendering: `UTerrainSector` LOD system (~50) *(parallel)*
5. Projectors & decals (~40) *(parallel)*
6. **ULevel core** (~49 in `src/Engine/Src/UnLevel.cpp`): `SpawnActor()`, `DestroyActor()`, `Tick()`, `MoveActor()` — **CRITICAL game loop**
7. UGameEngine / UInteractionMaster (~25 in `src/Engine/Src/UnGame.cpp`)
8. Camera system (~18 in `src/Engine/Src/UnCamera.cpp`)
9. NullDrv (~24 in `src/Engine/Src/NullDrv.cpp`) — many intentionally empty

**Gate:** Level loads; actors spawn and tick; basic rendering pipeline functional.

### Phase 7 — Networking, Events & Engine Mop-up (~435+ stubs)
*Depends on Phase 6 (ULevel).*

1. Network channels: `ReceivedBunch`, `SendBunch` (~80) in `src/Engine/Src/UnChan.cpp`
2. Network drivers (~20) in `src/Engine/Src/UnNetDrv.cpp`
3. **IpDrv transport** (~58): TCP/UDP WinSock2 in `src/IpDrv/Src/IpDrv.cpp` *(parallel)*
4. Actor event system, timer dispatch (~60)
5. Navigation/pathfinding (~47) in `src/Engine/Src/UnNavigation.cpp`
6. Karma physics bridge (~53) — may remain stubs if no Karma SDK
7. Engine mop-up: StatLog, Mover, editor methods (~185)

**Gate:** Multiplayer connects; AI pathfinding computes routes; touch events fire.

---

## TIER 3: HIGH DIFFICULTY (~1,350+ stubs, heavy Ghidra + domain knowledge)

### Phase 8 — R6 Game Modules (~699 stubs)
*Depends on Phases 4-7 (Engine systems must be functional). Ghidra: R6Abstract/R6Weapons/R6Engine/R6Game/R6GameService DLLs.*

1. **R6Abstract** base classes (~28) — mostly intentionally empty abstract methods
2. **R6Weapons** ballistics (~39): `ComputeEffectiveAccuracy()`, `GetMovingModifier()`, bullet physics *(depends on step 1)*
3. **R6Engine** — **THE BIG ONE** (~480 across 48 files):
   - 3a. Player controller (~40) *(parallel)*
   - 3b. Pawn mechanics: stance, peeking, vision (~30) *(parallel)*
   - 3c. AI controllers: pathfinding, firing positions (~60) *(parallel)*
   - 3d. Terrorist + Hostage AI (~40)
   - 3e. Doors & interactive objects (~50)
   - 3f. Deployment zones: spawning (~60)
   - 3g. Ragdoll & matinee (~40, depends on Phase 5)
   - 3h. Remaining: bomb, camera, electronics, HUD (~160)
4. **R6Game** rules & campaign (~90): game modes, round management, HUD rendering *(depends on step 3)*
5. **R6GameService** GameSpy integration (~22) *(parallel with step 4, servers defunct — for code completeness)*

**Gate:** Full single-player mission playable from planning through extraction.

### Phase 9 — Audio Pipeline (~450 stubs)
*Independent of R6 modules. Depends on Phase 2. Ghidra: SNDDSound3DDLL_ret.dll (heavy).*

1. SNDDSound3D core playback: DirectSound buffers (~150) in `src/SNDDSound3D/Src/SNDDSound3D.cpp`
2. SNDDSound3D 3D audio: positioning, Doppler, attenuation (~100) *(depends on step 1)*
3. SNDDSound3D EAX/advanced: environmental reverb, streaming (~127) *(lowest priority)*
4. DareAudio bridge: connect Engine audio API to SNDDSound3D (~57) in `src/DareAudio/Src/DareAudio.cpp` *(depends on step 1)*

**Gate:** Sound effects and music play; 3D positional audio localizes to actors.

### Phase 10 — Fire (Procedural Textures) & Final Polish (~88 stubs)
*Lowest priority. Parallel with anything.*

1. **Fire.dll** procedural textures (~64): fire, water, wave, fluid, ice, wet effects in `src/Fire/Src/Fire.cpp` — self-contained pixel algorithms
2. NullDrv audit (~24): document which are intentionally empty
3. **Final sweep**: grep for remaining stubs, verify zero `/alternatename` pragmas, clean build

**Gate:** All procedural textures animate. **Zero stubs remain.** Full game rebuilt and playable.

---

### Dependency Graph

```
Core.dll (foundation — no deps)
  └─► Engine.dll (depends: Core)
        ├─► Fire.dll (Core, Engine)
        ├─► Window.dll (Core, Engine)
        ├─► IpDrv.dll (Core, Engine)
        ├─► WinDrv.dll (Core, Engine, Window)
        ├─► D3DDrv.dll (Core, Engine)
        ├─► R6Abstract.dll (Core, Engine)
        │     ├─► R6Weapons.dll (Core, Engine, R6Abstract)
        │     ├─► R6Engine.dll (Core, Engine, R6Abstract)
        │     ├─► R6GameService.dll (Core, Engine, R6Abstract)
        │     └─► R6Game.dll (Core, Engine, R6Abstract, R6Engine, R6Weapons)
        └─► RavenShield.exe (Core, Engine, Window)
  
  SNDext.dll (Core only — platform layer)
    └─► SNDDSound3D.dll (SNDext, DirectSound, WinMM)
          └─► DareAudio.dll (Core, Engine, SNDDSound3D)
```

---

### Decisions
- **Karma physics**: May remain as intentional stubs — proprietary MathEngine SDK
- **GameSpy**: Implemented for code completeness; servers are defunct. LAN (IpDrv) is the functional network target
- **NullDrv**: Many stubs intentionally empty by design (headless renderer) — document, don't "fix"
- **NATIVE_ORDINALS.md**: 42 wrong ordinals in `src/Core/Src/UnScript.cpp` — standalone fix, parallel with any phase
- **Ghidra batching**: Analyze per-DLL (Engine.dll for Phases 4-7, then R6Engine.dll for Phase 8, SNDDSound3D.dll for Phase 9) rather than switching binaries per-function

### Further Considerations
1. **File organization**: As stubs are replaced, move implementations from `EngineStubs.cpp` into owner files per existing convention. Goal: `EngineStubs.cpp` and `EngineLinkerShims.cpp` both deleted by end of Phase 3.
2. **Blog cadence**: Suggested triggers per AGENTS.md: Phase 1 (drivers complete), Phase 4 (physics), Phase 6.6 (SpawnActor/Tick — "the game loop"), Phase 8 (first playable mission), Phase 9 (sound).
3. **Binary comparison tooling**: Use existing Ghidra scripts in `ghidra/` and tools in `tools/` for function-level accuracy verification against retail DLLs after each phase.
