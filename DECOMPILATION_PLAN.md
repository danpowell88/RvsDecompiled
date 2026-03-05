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

## Phase 0: Pre-Work — Environment & Tooling

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
1. Initialize Docusaurus 3.x at `blog/`
2. Posts: *"What Is Decompilation?"*, *"Meet Ravenshield"*, *"The Toolbox"*

---

## Phase 1: Ghidra Analysis — Batch Processing

### 1A. Batch Import
1. Write `ghidra/scripts/batch_import.py` — headless import of all 16 binaries, auto-analysis, type library application
2. Run `analyzeHeadless` against all binaries
3. Generate per-binary report: function count, export table, string references, import table

### 1B. Symbol Recovery
1. Write `ghidra/scripts/symbol_recovery.py` — match MSVC mangled export names (`?Func@Class@@...`) against SDK headers
2. Write `ghidra/scripts/cross_reference.py` — build inter-DLL dependency graph from import tables
3. Generate function-level cross-reference matrix showing exactly which DLL calls which

### 1C. UT99 Source Matching *(Core.dll and Engine.dll only)*
1. Write `ghidra/scripts/ut99_matcher.py` — compare decompiled functions against UT99 source using string literals, constants, call patterns
2. Flag functions as: identical to UT99 / modified from UT99 / unique to Ravenshield
3. Functions matching UT99 can be directly ported from source — massive time savings

### 1D. Export Raw Decompilation
1. Write `ghidra/scripts/export_cpp.py` — export per-class `.cpp`/`.h` files to `ghidra/exports/{module}/`
2. This is the raw starting material, NOT final code

Blog Post: *"First Contact — What Ghidra Found"*

---

## Phase 2: Core.dll — Foundation Layer

Zero game dependencies. Every other module depends on Core. Best UT99 reference coverage.

**Conversion order (sub-components, least deps first):**
1. Memory subsystem — `FMallocWindows`, `FMallocAnsi` (standalone)
2. Output devices — `FOutputDeviceFile`, `FOutputDeviceWindowsError` (minimal deps)
3. File managers — `FFileManagerWindows`, `FFileManagerGeneric`
4. Name table — `FName`, `FNameEntry` (hash table, 4096 buckets)
5. Math library — `FVector`, `FRotator`, `FPlane`, `FMatrix`, `FQuat`
6. Object system — `UObject`, `UClass`, `UField`, `UProperty`
7. Package system — `UPackage`, `ULinker`, `ULinkerLoad/Save`
8. Script VM — `FFrame`, bytecode interpreter
9. Serialization — `FArchive`, file readers/writers
10. Miscellaneous — codecs, exporters, factories, commandlets

~10 commits. Blog Post: *"Building the Foundation — Core.dll"*

---

## Phase 3: Engine.dll — Actor Framework

Required by all game modules. Largest module (~500+ functions) but extensively referenced.

**Conversion order:**
1. `AActor` — foundation of everything in the world
2. `APawn`, `AController`, `APlayerController` — player presence
3. `AGameInfo` — game rules framework
4. `ULevel`, `ALevelInfo` — map management
5. `URenderDevice`, `UCanvas`, `AHUD` — rendering interfaces
6. Physics, collision detection
7. `UNetDriver`, `UNetConnection` — networking, replication
8. `UMaterial`, `UTexture`, `UShader` — materials
9. `UAudioSubsystem` — audio interface
10. `UMesh`, `USkeletalMesh` — mesh/animation
11. `ABrush`, `UModel` — BSP geometry
12. `AEmitter`, `AProjector` — effects

~12 commits. Blog Post: *"The Actor Model — How Unreal Engine Thinks"*

---

## Phase 4: Support Modules *(can be parallelized)*

| Module | Size | Key Reference | Commits |
|--------|------|--------------|---------|
| **Fire.dll** | Tiny (7 classes) | UT99 source equivalent | 1-2 |
| **Window.dll** | Small | UT99 Window source | 2-3 |
| **IpDrv.dll** | Medium (5 UC classes + GameSpy) | `sdk/GameSpySDK/src/GameSpy/` full source | 3-4 |

Blog Post: *"The Little Modules That Could"*

---

## Phase 5: Driver Layer

| Module | Complexity | Key Reference | Commits |
|--------|-----------|--------------|---------|
| **WinDrv.dll** | Medium | C SDK headers, UT99 driver | 3-4 |
| **D3DDrv.dll** | High (GPU state machine) | DX8 headers, UT99 D3D7 driver | 5-6 |

Blog Post: *"Pixels and Packets — The Driver Layer"*

---

## Phase 6: R6 Game Modules — Bottom-Up Through Dependency Graph

### 6A. R6Abstract.dll — *Start here for game code* (17 classes, smallest R6 module)
- Abstract bases: `R6AbstractPawn`, `R6AbstractWeapon`, `R6AbstractGameInfo`
- 2-3 commits

### 6B. R6Weapons.dll — Bullet physics, damage, recoil, firing modes
- Reference: C SDK headers + UnrealScript + `sdk/Goodies/Weapons Development Kit/`
- 4-5 commits

### 6C. R6Engine.dll — 160+ classes, conversion sub-order:
1. `R6Pawn` base → 2. Interactive objects (doors, ladders) → 3. Characters (Rainbow, Terrorist, Hostage) → 4. AI system → 5. Level managers → 6. Cinematics
- 8-10 commits

### 6D. R6Game.dll — 110+ classes, conversion sub-order:
1. `R6GameInfo` base → 2. Deathmatch (simplest rules) → 3. Team modes → 4. Objective modes → 5. Campaign/CoOp → 6. Operative definitions → 7. Console
- 8-10 commits

### 6E. R6GameService.dll — 6 classes (server list, mod info, patches)
- 2-3 commits

Blog Posts: *"The Heart of Rainbow Six"*, *"Weapons, Walls, and Doors"*

---

## Phase 7: Audio System — Lowest Reference Quality, Hardest to Reconstruct

| Module | Notes | Commits |
|--------|-------|---------|
| **DareAudioScript.dll** | Scripting bridge, smallest audio module | 2-3 |
| **DareAudio.dll** | Main audio — pure Ghidra, no source reference | 5-6 |
| **DareAudioRelease.dll** | Likely shares code with DareAudio, diff first | 2-3 |
| **SNDDSound3D*.dll, SNDext*.dll** | DirectSound wrappers, ret vs VSR are minimal diffs | 3-4 |

Blog Post: *"How Games Hear — The DARE Audio System"*

---

## Phase 8: RavenShield.exe — Bootstrap/Launcher

WinMain, command-line parsing, engine init, window creation, message pump, DLL loading. 3-4 commits.

Blog Post: *"Press Start — Launching the Engine"*

---

## Phase 9: UnrealScript & Assets Rebuild

1. Compile all 20+ `.uc` packages from `sdk/1.56 Source Code/` using original `UCC.exe`
2. Compilation order per `retail/system/Default.ini` `EditPackages`: Core → Engine → Editor → UnrealEd → IpDrv → UWindow → Fire → Gameplay → R6Abstract → R6Engine → R6Characters → R6Description → R6SFX → R6GameService → R6Game → R6Menu → R6Window → R61stWeapons → R6Weapons → R6WeaponGadgets → R63rdWeapons
3. Verify `.u` output matches originals
4. Include Athena Sword expansion packages

Blog Post: *"Scripting a Rainbow — UnrealScript Rebuilt"*

---

## Phase 10: Integration & Testing

1. **Incremental replacement** — swap one DLL at a time, test game still boots
2. **Boot test** — main menu with all rebuilt DLLs
3. **Training mission** — single-player functional test
4. **Campaign** — first 3 missions
5. **Multiplayer** — LAN server + client, all game modes
6. **OpenRVS compatibility** — verify community mod loads
7. **Binary comparison report** — run `bindiff.py`/`funcmatch.py`, document match percentages and intentional divergences

Blog Posts: *"It Lives!"*, *"The Comparison — How Close Did We Get?"*

---

## Phase 11: Progressive Modernization

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
6. Rebuilt `.u` packages load without errors in `ravenshield.log`
7. Each blog milestone post published before advancing to next phase

---

## Decisions

- Third-party DLLs are external dependencies (linked, not decompiled)
- MSVC 7.1 primary target for byte parity; modern MSVC added in Phase 11
- Game runtime only — UnrealEd.exe and UCC.exe excluded
- UnrealScript compiled from existing 1.56 source using original UCC.exe
- Readability wins over byte-match when they conflict — divergences documented
- Azure assumed for any CI/CD needs
- Never push git without user confirmation

---

## Further Considerations

1. **Athena Sword expansion** — Additional `.u` packages in `retail/Mods/AthenaSword/`. Include in Phase 9 UnrealScript rebuild and Phase 10 testing, but exclude from C++ decompilation scope.

2. **OpenRVS community mod** — `retail/system/OpenRVS.u` and `openrvs.ini` indicate active community. Verify compatibility in Phase 10 testing.

3. **Steam integration** — Original has Steam hooks (`installscript.vdf`, `steam_appid.txt`). Rebuilt binaries won't have Steam DRM stubs. Add a thin Steam API stub if needed, document as known difference.
