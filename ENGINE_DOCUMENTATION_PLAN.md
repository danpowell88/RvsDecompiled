# Plan: Ravenshield Engine Documentation

## TL;DR
Build comprehensive engine documentation in the existing Docusaurus `blog/docs/` section, replacing tutorial placeholders. Documentation targets modders/game devs and programmers learning about game engine architecture. Uses Mermaid for all diagrams. Organized into 7 sections covering architecture, modules, guides, and reference material.

## Audience
- **Modders/Game developers** — people who want to modify Ravenshield or build mods
- **Educational/General programmers** — people learning about game engine architecture, C++, or Unreal Engine 2

## Documentation Structure

### Section 1: Getting Started
**Purpose:** Onboarding — what this project is, how to get it running.

Files to create:
- `docs/intro.md` (replace existing) — Project overview, goals, what Ravenshield is, link to blog for history
- `docs/getting-started/prerequisites.md` — Required tools (MSVC, CMake, DirectX 8 SDK, Windows SDK), system requirements
- `docs/getting-started/building.md` — Step-by-step build instructions, both MSVC 7.1 and modern MSVC paths
- `docs/getting-started/project-structure.md` — Walkthrough of repo layout: src/, sdk/, ghidra/, tools/, retail/, blog/
- `docs/getting-started/running.md` — How to run the rebuilt game, DLL replacement workflow, testing against retail

### Section 2: Architecture Overview
**Purpose:** Big-picture understanding of how the engine works. The crown jewel section.

Files to create:
- `docs/architecture/overview.md` — High-level engine architecture, the "16 binaries" model, plugin-based design philosophy
  - Mermaid: Full module dependency graph
  - Mermaid: Runtime DLL loading sequence
- `docs/architecture/unreal-engine-2.md` — UE2 fundamentals for people who've never seen it: Actor model, tick loop, packages, UnrealScript
- `docs/architecture/object-system.md` — UObject, UClass, UField, UProperty hierarchy, reflection, garbage collection, serialization
  - Mermaid: Object system class hierarchy
  - Mermaid: Object lifecycle (create → register → initialize → GC)
- `docs/architecture/memory-management.md` — FMallocWindows pooled allocator (49 size classes), allocation flow, VirtualAlloc fallback
  - Mermaid: Memory allocation decision flowchart
- `docs/architecture/script-vm.md` — UnrealScript bytecode interpreter, GNatives dispatch table, exec_* functions, compact index encoding
  - Mermaid: Script execution flow (bytecode → GNatives → native C++)
- `docs/architecture/networking.md` — UNetDriver/UNetConnection, property replication, channels, client-server model
  - Mermaid: Network replication data flow
- `docs/architecture/rendering-pipeline.md` — URenderDevice interface → D3DDrv implementation, BSP + mesh rendering, material system
  - Mermaid: Rendering pipeline stages
- `docs/architecture/audio-system.md` — UAudioSubsystem interface, DARE audio engine, 3D spatialization
- `docs/architecture/input-system.md` — UClient → UWindowsClient → DirectInput8, viewport management, key binding
- `docs/architecture/game-loop.md` — Main tick loop: input → script → physics → AI → render → network, frame timing
  - Mermaid: Game loop sequence diagram

### Section 3: Module Reference
**Purpose:** Per-module deep dives. One page per DLL.

Files to create:
- `docs/modules/core.md` — Core.dll: object system, names, math, script VM, memory. Key classes, export count, dependencies
- `docs/modules/engine.md` — Engine.dll: 348 classes, actor framework, level management, rendering, physics, networking
- `docs/modules/fire.md` — Fire.dll: procedural textures (fire, water, ice, wave), 7 classes
- `docs/modules/window.md` — Window.dll: Win32 GUI framework, R6-specific signature changes from UT99
- `docs/modules/ipdrv.md` — IpDrv.dll: TCP/IP networking, GameSpy integration, server browser
- `docs/modules/windrv.md` — WinDrv.dll: Windows viewport, DirectInput8, HWND management
- `docs/modules/d3ddrv.md` — D3DDrv.dll: Direct3D 8 rendering backend, UD3DRenderDevice
- `docs/modules/r6abstract.md` — R6Abstract.dll: Base R6 classes (17 classes), tactical gameplay concepts
- `docs/modules/r6engine.md` — R6Engine.dll: AI, doors, characters, interactions
- `docs/modules/r6game.md` — R6Game.dll: Game modes, missions, campaign structure
- `docs/modules/r6weapons.md` — R6Weapons.dll: Ballistics, recoil, firing modes, ammunition
- `docs/modules/r6gameservice.md` — R6GameService.dll: Server browser, mods, patching
- `docs/modules/dareaudio.md` — DareAudio.dll: 3D audio subsystem
- `docs/modules/launcher.md` — RavenShield.exe: Bootstrap, DLL loading, message pump

### Section 4: Key Classes Reference
**Purpose:** Quick reference for the most important classes.

Files to create:
- `docs/classes/uobject.md` — The root of everything: creation, serialization, properties, GC
- `docs/classes/actor.md` — AActor: transform, tick, collision, replication, spawning/destroying
- `docs/classes/pawn.md` — APawn: movement, health, inventory, controller attachment
- `docs/classes/controller.md` — AController: AI vs player, state machines, possession
- `docs/classes/player-controller.md` — APlayerController: input handling, camera, HUD
- `docs/classes/game-info.md` — AGameInfo: match rules, scoring, player login flow
- `docs/classes/level.md` — ULevel: map loading, actor iteration, BSP, zones
- `docs/classes/materials.md` — UMaterial/UTexture hierarchy, material combiners, shaders
- `docs/classes/mesh.md` — UMesh/USkeletalMesh/UStaticMesh: mesh loading, LODs, animation
- `docs/classes/render-device.md` — URenderDevice: the rendering interface contract
- `docs/classes/net-driver.md` — UNetDriver/UNetConnection: networking abstractions

### Section 5: How-To Guides
**Purpose:** Task-oriented guides for modders and developers. Every asset type gets a guide with free tools and real examples.

**Modding Fundamentals:**
- `docs/guides/modding-overview.md` — Mod folder structure, .mod files, .ini paths, mod unlocker, hooks system. Includes free tools reference table
- `docs/guides/sdk-setup.md` — SDK ToolBelt setup, code versions (1.56/1.60/Hybrid), UCC.exe, compilation workflow
- `docs/guides/unrealscript-basics.md` — UnrealScript crash course for C++ devs: syntax, states, native functions, replication blocks. Tool: VS Code

**Asset Modification Guides (per asset type, free tools + examples):**
- `docs/guides/textures.md` — Modifying .utx textures: extract with UModel (free), edit in GIMP (free), reimport via UnrealEd/1.56 import. Covers _T/_shader/_TSM naming. Example: reskinning a weapon
- `docs/guides/static-meshes.md` — Modifying .usx static meshes: extract with UModel, edit in Blender (free) with ASE export, reimport. Example: modifying a map prop
- `docs/guides/skeletal-meshes-animations.md` — Modifying .ukx skeletal meshes + .PSK/.kaw/.ka ragdoll: extract with UModel, edit in Blender with PSK/PSA import plugin. Example: modifying character model or adding animation
- `docs/guides/sounds.md` — Modifying .uax + .SB0/.SS0/.SP0 audio: extract with UModel, edit in Audacity (free), export as Ogg Vorbis. Covers weapon sounds, ambience, voices, music
- `docs/guides/maps.md` — Map editing (.rsm): UnrealEd (bundled), map .ini config (objectives, spawns), preview .tga thumbnails. Example: modifying objective locations
- `docs/guides/configuration.md` — Editing .ini files: RavenShield.ini, Default.ini, Server.ini, per-map .ini. Key gameplay/rendering/network/asset path settings
- `docs/guides/tactical-plans.md` — Editing .tpt tactical plans and .tph loadout templates. File format, in-game editor, manual editing. Example: custom plan template
- `docs/guides/arm-patches.md` — Creating arm patches (.tga): create in GIMP, correct dimensions/format, folder placement. Example: custom team emblem

**Gameplay Modification Guides:**
- `docs/guides/adding-a-weapon.md` — End-to-end: UnrealScript weapon class, ballistics properties, 1st/3rd person models, sounds, R6Weapons integration. References WDK bullet modding system
- `docs/guides/adding-a-game-mode.md` — Subclassing R6GameInfo, hooks registration, server config. References SDK sample mods (HeadShot, StealthGameType, SixteenPlayerCoop)
- `docs/guides/hooks.md` — All mod hooks: Default Pawn, RainbowAI, PlayerController, HUD, Menu. Config-driven injection, limitations, examples from SDK

**Decompilation Workflow Guides:**
- `docs/guides/debugging.md` — Debugging: log output, Visual Studio debugger attachment, Ghidra cross-reference, retail DLL comparison
- `docs/guides/replacing-a-dll.md` — Rebuild one DLL and swap into retail for testing
- `docs/guides/binary-comparison.md` — Byte parity verification: bindiff.py, funcmatch.py, section comparison

### Section 6: Decompilation Reference
**Purpose:** How the decompilation works, for contributors.

Files to create:
- `docs/decompilation/methodology.md` — Overall approach: Ghidra analysis → SDK matching → stub → implement → verify
- `docs/decompilation/tools.md` — Custom toolchain: Ghidra scripts, compare tools, ordinal analysis
- `docs/decompilation/conventions.md` — Coding conventions, IMPLEMENT_CLASS/IMPLEMENT_FUNCTION macros, naming, header organization
- `docs/decompilation/known-divergences.md` — Documented byte-parity divergences and why they exist
- `docs/decompilation/native-ordinals.md` — Native function ordinal mapping, how to verify, known issues (link to NATIVE_ORDINALS.md)
- `docs/decompilation/contributing.md` — How to pick up a module and start decompiling it

### Section 7: Glossary & Reference
**Purpose:** Quick-lookup reference material.

Files to create:
- `docs/reference/glossary.md` — Key terms: Actor, Pawn, Controller, Package, Native, Ordinal, BSP, etc.
- `docs/reference/ini-reference.md` — Key .ini settings that control engine behavior
- `docs/reference/export-tables.md` — DLL export counts and ordinal ranges per module
- `docs/reference/build-flags.md` — Compiler flags, preprocessor defines, their effects

---

## Sidebar Organization (sidebars.ts)

```
docs/
├── intro.md
├── getting-started/          (category: "Getting Started")
│   ├── prerequisites.md
│   ├── building.md
│   ├── project-structure.md
│   └── running.md
├── architecture/             (category: "Architecture")
│   ├── overview.md
│   ├── unreal-engine-2.md
│   ├── object-system.md
│   ├── memory-management.md
│   ├── script-vm.md
│   ├── game-loop.md
│   ├── networking.md
│   ├── rendering-pipeline.md
│   ├── audio-system.md
│   └── input-system.md
├── modules/                  (category: "Module Reference")
│   ├── core.md
│   ├── engine.md
│   ├── fire.md
│   ├── window.md
│   ├── ipdrv.md
│   ├── windrv.md
│   ├── d3ddrv.md
│   ├── r6abstract.md
│   ├── r6engine.md
│   ├── r6game.md
│   ├── r6weapons.md
│   ├── r6gameservice.md
│   ├── dareaudio.md
│   └── launcher.md
├── classes/                  (category: "Key Classes")
│   ├── uobject.md
│   ├── actor.md
│   ├── pawn.md
│   ├── controller.md
│   ├── player-controller.md
│   ├── game-info.md
│   ├── level.md
│   ├── materials.md
│   ├── mesh.md
│   ├── render-device.md
│   └── net-driver.md
├── guides/                   (category: "How-To Guides")
│   ├── modding-overview.md
│   ├── sdk-setup.md
│   ├── unrealscript-basics.md
│   ├── textures.md
│   ├── static-meshes.md
│   ├── skeletal-meshes-animations.md
│   ├── sounds.md
│   ├── maps.md
│   ├── configuration.md
│   ├── tactical-plans.md
│   ├── arm-patches.md
│   ├── adding-a-weapon.md
│   ├── adding-a-game-mode.md
│   ├── hooks.md
│   ├── debugging.md
│   ├── replacing-a-dll.md
│   └── binary-comparison.md
├── decompilation/            (category: "Decompilation")
│   ├── methodology.md
│   ├── tools.md
│   ├── conventions.md
│   ├── known-divergences.md
│   ├── native-ordinals.md
│   └── contributing.md
└── reference/                (category: "Reference")
    ├── glossary.md
    ├── ini-reference.md
    ├── export-tables.md
    └── build-flags.md
```

## Mermaid Diagrams (21 planned)

### Architecture Diagrams (13)
1. **Module dependency graph** — All 16 binaries with arrows showing import dependencies
2. **Runtime DLL loading sequence** — Sequence diagram of launcher → Core → Engine → drivers → game modules
3. **Object system class hierarchy** — UObject tree with UField/UStruct/UClass/UProperty branches
4. **Object lifecycle** — State machine: Allocate → Register → Initialize → BeginPlay → Tick → PendingKill → GC
5. **Memory allocation flowchart** — Request → pool lookup → freelist check → new pool or VirtualAlloc
6. **Script execution flow** — Bytecode fetch → GNatives dispatch → exec_* → return to VM
7. **Network replication data flow** — Server tick → property diff → serialize → channel → client apply
8. **Rendering pipeline** — Scene traversal → BSP → static mesh → skeletal mesh → post-process → present
9. **Game loop sequence** — Input → script tick → physics → AI → render → network → sleep
10. **Actor spawning sequence** — SpawnActor → allocate → initialize → register → BeginPlay
11. **Pawn/Controller relationship** — Possess/UnPossess state diagram
12. **Package loading flow** — FindPackage → ULinkerLoad → deserialize → register objects
13. **Build pipeline** — CMake → MSVC → link import libs → DLL output → verify vs retail

### Asset Pipeline Flowcharts (8) — one per asset guide
14. **Texture pipeline** — .utx → UModel extract → .tga/.bmp → GIMP edit → reimport via UnrealEd/1.56 → .utx → test in game
15. **Static mesh pipeline** — .usx → UModel extract → .psk/.3d → Blender edit → ASE export → UnrealEd reimport → .usx → test in game
16. **Skeletal mesh & animation pipeline** — .ukx → UModel extract → .psk/.psa → Blender edit (ActorX plugin) → export → UnrealEd reimport → .ukx → test in game
17. **Sound pipeline** — .uax + .SB0 → UModel extract → .ogg/.wav → Audacity edit → Ogg Vorbis export → UnrealEd reimport → .uax → test in game
18. **Map pipeline** — .rsm → UnrealEd open → edit geometry/actors/lighting → rebuild BSP → save .rsm → edit map .ini → test in game
19. **UnrealScript pipeline** — .uc source → UCC.exe compile → .u package → copy to System/ → update .ini → test in game
20. **Weapon creation pipeline** — Define .uc class → create 1st/3rd person mesh → create sounds → set ballistics → compile → package → hook registration → test
21. **Mod distribution pipeline** — Source .uc + assets → compile → mod folder structure → .mod config → .ini paths → mod unlocker (SP) → distribute .zip

## Implementation Notes

- **Delete** all tutorial-basics/ and tutorial-extras/ content
- **Update** sidebars.ts to use autogenerated from new folder structure (current config already does this)
- **Update** docusaurus.config.ts navbar if needed (current "Docs" link should work)
- Each `_category_.json` provides sidebar label and position for ordering
- All diagrams use ```mermaid code blocks (Docusaurus has built-in Mermaid support via @docusaurus/theme-mermaid)
- May need to add `@docusaurus/theme-mermaid` to package.json and enable in docusaurus.config.ts
- Cross-link extensively between architecture pages, module pages, and class pages
- For modules not yet decompiled (R6*, DareAudio, Launcher), document what's known from SDK headers + Ghidra analysis and mark as "Not Yet Decompiled"

## Relevant Files to Modify
- `blog/docs/intro.md` — Replace with project overview
- `blog/docs/tutorial-basics/*` — Delete all
- `blog/docs/tutorial-extras/*` — Delete all
- `blog/sidebars.ts` — Keep autogenerated (already works)
- `blog/docusaurus.config.ts` — Add Mermaid theme plugin
- `blog/package.json` — Add @docusaurus/theme-mermaid dependency

## Verification
1. Run `npx docusaurus build` in blog/ — must build with zero errors
2. Run `npx docusaurus start` — visually verify each section renders, sidebar navigates correctly
3. Verify all Mermaid diagrams render properly
4. Check all cross-links between docs resolve
5. Verify no tutorial placeholder content remains

## Decisions
- Auto-generated sidebar from filesystem structure (no manual sidebar entries needed)
- R6 modules (not yet decompiled) get placeholder docs with what's known from SDK + Ghidra
- Blog stays for dev journal; Docs section is the technical reference
- Glossary covers both UE2 terms and R6-specific terms
- How-to guides target modders; architecture + decompilation sections target contributors and learners

## Phases & Priority

### Phase 1: Foundation (do first)
- Intro, Getting Started section (4 docs)
- Architecture overview + game loop (2 docs)
- Sidebar setup, Mermaid plugin

### Phase 2: Architecture Deep Dives
- Object system, memory management, script VM (3 docs)
- Networking, rendering, audio, input (4 docs)
- ~9 Mermaid diagrams

### Phase 3: Module Reference
- All 14 module pages
- Focus detail on completed modules (Core, Engine, Fire, Window, IpDrv, WinDrv, D3DDrv)
- Placeholder content for future modules

### Phase 4: Key Classes
- 11 class reference pages
- Code examples from actual decompiled source

### Phase 5: Guides & Reference
- 3 modding fundamentals docs (overview, SDK setup, UnrealScript basics)
- 8 asset modification guides (textures, static meshes, skeletal meshes/animations, sounds, maps, configuration, tactical plans, arm patches)
- 3 gameplay modification guides (adding weapon, adding game mode, hooks)
- 3 decompilation workflow guides (debugging, replacing DLL, binary comparison)
- 4 reference pages (glossary, INI, exports, build flags)
- Total: 21 docs (can be parallelized — asset guides are independent of each other)

### Phase 6: Decompilation Section
- 6 contributor-focused docs
- Methodology, conventions, contributing guide
