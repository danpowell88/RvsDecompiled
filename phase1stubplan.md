## Plan: Complete Phase 1

Finish Phase 1 by treating it as four coupled deliverables rather than just "remove the last 28 pragmas": complete the remaining real Engine implementations, move Phase 1 code into UT99-style ownership files, eliminate the last retail build/staging dependencies, then verify self-sufficient Release builds and staged binaries against the Phase 1 acceptance criteria. The recommended approach is to do this bottom-up: first inventory and relocate code ownership, then replace the remaining Engine redirects with real implementations or justified compiler-emission shims, then complete the CMake/task switchover, and finally run a strict verification pass.

**Steps**
1. Phase A: Freeze the exact Phase 1 target set.
   Confirm the plan boundary from c:\Users\danpo\Desktop\rvs\STUB_PLAN.md: Phase 1 includes 1A through 1E only. Exclude EXEC_STUB gameplay/renderer/boot work that belongs to Phases 2–4, even if those files still contain stubs.
   Record the exact unfinished Phase 1 items now present: the 28 remaining Engine alternatenames in c:\Users\danpo\Desktop\rvs\src\engine\EngineStubs1.cpp, the remaining Core __FUNC_NAME__ redirects in c:\Users\danpo\Desktop\rvs\src\core\CoreStubs.cpp, downstream Window/R6Abstract retail import-lib references, and the staging task still copying retail system DLLs.

2. Phase B: Re-own Phase 1 code by subsystem before changing behavior.
   Move Phase 1-capable implementations out of generic batch files into their natural UT99-style homes so the cleanup is structurally sound before the final redirect removal.
   Move material/property accessors from batch implementation files into c:\Users\danpo\Desktop\rvs\src\engine\UnMaterial.cpp.
   Move channel/network-related constructors, serializers, and lifecycle methods into c:\Users\danpo\Desktop\rvs\src\engine\UnNet.cpp.
   Keep TLazyArray<BYTE> explicit-instantiation and forced-emission logic centralized in one Engine file, preferably c:\Users\danpo\Desktop\rvs\src\engine\EngineBatchImpl4.cpp unless a dedicated container-oriented Engine file already exists and can own it cleanly.
   Move brush/coordinate helper implementations to c:\Users\danpo\Desktop\rvs\src\engine\EngineExtra.cpp or a dedicated c:\Users\danpo\Desktop\rvs\src\engine\UnBrush.cpp if that yields a cleaner UT99-like split without creating artificial fragmentation.
   Keep Core-level __FUNC_NAME__ workaround ownership centralized in c:\Users\danpo\Desktop\rvs\src\core\CoreStubs.cpp only.
   Deduplicate any method bodies that now exist both in EngineBatchImpl files and natural owner files; after each move, leave a single owning definition.

3. Phase C: Replace the remaining 28 Engine alternatenames with real Phase 1 implementations where possible.
   Work through every remaining entry in c:\Users\danpo\Desktop\rvs\src\engine\EngineStubs1.cpp and classify it into one of three buckets before editing.
   Bucket 1: real Phase 1 methods that should be implemented now and moved into their owning source files. This currently includes the remaining brush helpers, FMipmap/TLazyArray support methods, ULevelSummary/PostLoad or simple accessors/serializers, and network channel static constructors if they are still unresolved by compiler emission.
   Bucket 2: compiler-emission problems rather than real handwritten logic. Solve these by forcing correct symbol emission from class definitions or template instantiations, not by adding new dummy implementations. This includes TLazyArray<BYTE> special members and any MI/vftable-related secondary-base emission issues.
   Bucket 3: residual compiler-internal __FUNC_NAME__ symbols. Only leave redirects when the symbol is genuinely an MSVC 7.1 versus modern MSVC naming artifact and there is no meaningful function body to implement. If such redirects remain, convert them from generic dummy redirects into explicit documented compatibility shims with named data exports, following the Core pattern rather than opaque dummy storage where feasible.
   Remove resolved alternatenames from c:\Users\danpo\Desktop\rvs\src\engine\EngineStubs1.cpp as each symbol is covered by a real implementation or justified emission shim.
   Keep c:\Users\danpo\Desktop\rvs\src\engine\EngineStubs2.cpp through c:\Users\danpo\Desktop\rvs\src\engine\EngineStubs4.cpp clean and do not reintroduce generic redirect clutter there.

4. Phase D: Normalize Core Phase 1 ownership.
   Review c:\Users\danpo\Desktop\rvs\src\core\CoreStubs.cpp and split any non-compatibility code that belongs in a natural Core subsystem file.
   Keep real math helpers in c:\Users\danpo\Desktop\rvs\src\core\UnMath.cpp when they are math/geometry primitives.
   Keep archive/serialization mechanics in c:\Users\danpo\Desktop\rvs\src\core\UnStream.cpp when they are FArchive-related.
   Leave only genuinely transitional compatibility material in c:\Users\danpo\Desktop\rvs\src\core\CoreStubs.cpp: compiler-emission helpers, __FUNC_NAME__ compatibility exports, and any unavoidable import/export bridging.
   Deduplicate by removing any duplicated out-of-line bodies that were introduced during prior batch generation.

5. Phase E: Complete Build System Switchover.
   Leave Core_Dep and Engine_Dep as rebuilt-import-lib interface targets in c:\Users\danpo\Desktop\rvs\CMakeLists.txt; they are already switched and should not regress.
   Replace the retail Window import-lib dependency in c:\Users\danpo\Desktop\rvs\src\windrv\CMakeLists.txt with the built Window import lib, following the existing pattern already used by c:\Users\danpo\Desktop\rvs\src\launch\CMakeLists.txt.
   Replace retail R6Abstract import-lib references in c:\Users\danpo\Desktop\rvs\src\r6engine\CMakeLists.txt, c:\Users\danpo\Desktop\rvs\src\r6weapons\CMakeLists.txt, c:\Users\danpo\Desktop\rvs\src\r6gameservice\CMakeLists.txt, and c:\Users\danpo\Desktop\rvs\src\r6game\CMakeLists.txt with the built R6Abstract import lib, following the same direct-path pattern used for R6Engine in R6Game and Engine in DareAudio.
   Replace the retail R6Weapons import-lib dependency in c:\Users\danpo\Desktop\rvs\src\r6game\CMakeLists.txt with the built R6Weapons import lib.
   Update c:\Users\danpo\Desktop\rvs\.vscode\tasks.json so the staged runtime no longer copies retail game DLLs from retail\system. Keep only rebuilt binaries, assets, and true third-party middleware in the stage step. If a whitelist is required, explicitly whitelist only non-game middleware rather than copying the full retail system directory.

6. Phase F: Recheck all work against the real Phase 1 acceptance criteria.
   Reconfigure and perform a clean Release build using the repo's configured CMake tasks.
   Inspect linker inputs or generated project files to confirm there are zero retail game import-library references for Core, Engine, Window, R6Abstract, and R6Weapons in the final Phase 1 graph.
   Confirm the 28 remaining Engine alternatenames are gone or reduced only to explicitly documented compiler-internal compatibility cases that cannot be replaced meaningfully.
   Run export verification against rebuilt DLLs and compare ordinal coverage with the existing .def files and current repo verification scripts.
   Stage the runtime and confirm no retail game DLLs are present in build\runtime-test\system, apart from deliberately allowed third-party middleware.
   Update c:\Users\danpo\Desktop\rvs\STUB_PLAN.md to reflect the actual finished Phase 1 state and any narrow documented divergences, and add a dev blog post under c:\Users\danpo\Desktop\rvs\blog if the completion represents a meaningful milestone per AGENTS.md.

7. Parallelism and execution order.
   Phases B and the classification part of C can run in parallel as long as symbol ownership is tracked carefully.
   Phase D can run in parallel with Engine ownership cleanup because Core and Engine are mostly independent.
   Phase E blocks final verification because link-graph correctness is part of the milestone.
   Phase F only starts after Phases B through E are stable.

**Relevant files**
- c:\Users\danpo\Desktop\rvs\STUB_PLAN.md — source of truth for the Phase 1 scope and acceptance criteria.
- c:\Users\danpo\Desktop\rvs\CMakeLists.txt — already switched Core_Dep and Engine_Dep; preserve this behavior while cleaning downstream module links.
- c:\Users\danpo\Desktop\rvs\src\core\CoreStubs.cpp — keep only unavoidable compatibility/export-emission helpers and Core __FUNC_NAME__ shims.
- c:\Users\danpo\Desktop\rvs\src\core\UnMath.cpp — preferred home for surviving Core math helpers and related utility bodies.
- c:\Users\danpo\Desktop\rvs\src\core\UnStream.cpp — preferred home for Core archive/serialization bodies.
- c:\Users\danpo\Desktop\rvs\src\engine\EngineStubs1.cpp — current remaining 28 Engine alternatenames; should end Phase 1 nearly empty or with only documented compiler artifacts.
- c:\Users\danpo\Desktop\rvs\src\engine\EngineStubs2.cpp — keep clean; do not reintroduce generic redirects.
- c:\Users\danpo\Desktop\rvs\src\engine\EngineStubs3.cpp — keep clean; do not reintroduce generic redirects.
- c:\Users\danpo\Desktop\rvs\src\engine\EngineStubs4.cpp — keep clean; do not reintroduce generic redirects.
- c:\Users\danpo\Desktop\rvs\src\engine\UnMaterial.cpp — target home for material property/accessor implementations now stranded in batch files.
- c:\Users\danpo\Desktop\rvs\src\engine\UnNet.cpp — target home for channel static constructors, serializers, and other network ownership cleanup.
- c:\Users\danpo\Desktop\rvs\src\engine\EngineExtra.cpp — current home for miscellaneous Engine helpers; likely owner for brush helper implementations unless split into UnBrush.cpp.
- c:\Users\danpo\Desktop\rvs\src\engine\EngineBatchImpl2.cpp — likely source of Phase 1 bodies to relocate and deduplicate.
- c:\Users\danpo\Desktop\rvs\src\engine\EngineBatchImpl4.cpp — current home for TLazyArray<BYTE> emission forcing and related low-level symbol-emission glue.
- c:\Users\danpo\Desktop\rvs\src\windrv\CMakeLists.txt — replace retail Window.lib with built Window.lib.
- c:\Users\danpo\Desktop\rvs\src\r6abstract\CMakeLists.txt — built R6Abstract module providing the import lib Phase 1 should consume.
- c:\Users\danpo\Desktop\rvs\src\r6engine\CMakeLists.txt — replace retail R6Abstract.lib dependency.
- c:\Users\danpo\Desktop\rvs\src\r6weapons\CMakeLists.txt — replace retail R6Abstract.lib dependency.
- c:\Users\danpo\Desktop\rvs\src\r6game\CMakeLists.txt — replace retail R6Abstract.lib and retail R6Weapons.lib dependencies with built import libs.
- c:\Users\danpo\Desktop\rvs\src\r6gameservice\CMakeLists.txt — replace retail R6Abstract.lib dependency.
- c:\Users\danpo\Desktop\rvs\.vscode\tasks.json — remove retail system DLL copying from the runtime staging task.
- c:\Users\danpo\Desktop\rvs\tools\stub_triage.py — reuse for symbol classification, not as a substitute for final structural cleanup.
- c:\Users\danpo\Desktop\rvs\tools\check_exports.py — likely verification helper for ordinal/export comparison.

**Verification**
1. Run the repo configure/build tasks in Release and confirm a clean link of Core, Engine, Window, R6Abstract, R6Weapons, R6Engine, R6Game, R6GameService, WinDrv, D3DDrv, and RavenShield.
2. Search the repo and generated build files for retail game import-lib references after the switchover. Zero acceptable references remain for Core.lib, Engine.lib, Window.lib, R6Abstract.lib, and R6Weapons.lib from the SDK path.
3. Search src/core and src/engine for remaining generic alternatename redirects. Any survivors must be explicitly documented compiler-compatibility cases, not unresolved real methods.
4. Compare rebuilt DLL exports against their .def files and current export-audit tooling to verify ordinal coverage is unchanged.
5. Run the stage task and inspect build\runtime-test\system to verify no retail game DLLs were copied into the runtime directory.
6. Perform a focused code review pass after the mechanical cleanup to catch duplicate bodies, misplaced ownership, and any regressions introduced by moving code out of EngineBatchImpl files.

**Decisions**
- Included scope: only STUB_PLAN Phase 1 work as defined by 1A through 1E, plus the user-requested structural cleanup required to finish that work cleanly.
- Excluded scope: EXEC_STUB gameplay, rendering, physics, AI, and boot-path behavior from Phases 2–4, except where a currently unresolved symbol turns out to be a genuine Phase 1 build blocker.
- Preferred architecture: UT99-style ownership files first, generic batch/stub files last-resort only.
- "Without stubs where possible" means replacing dummy redirects with either real method bodies or explicit compiler-emission shims; purely cosmetic compiler-internal symbol compatibility may remain if documented and isolated.

**Further Considerations**
1. If a small number of Engine __FUNC_NAME__ symbols survive, document them as compiler-version artifacts rather than counting them as unfinished gameplay work.
2. If c:\Users\danpo\Desktop\rvs\src\engine\EngineExtra.cpp keeps becoming a dumping ground during relocation, create c:\Users\danpo\Desktop\rvs\src\engine\UnBrush.cpp for brush-specific ownership rather than preserving another generic batch bucket.
3. Use existing built-import-lib path patterns consistently across modules to avoid reintroducing SDK-path special cases.
