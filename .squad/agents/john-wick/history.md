# Project Context

- **Owner:** Daniel Powell
- **Project:** Tom Clancy's Rainbow Six Ravenshield — Full Decompilation & Reconstruction
- **Stack:** C++98, MSVC 7.1, Unreal Engine (UT99 fork), x86 Windows, Ghidra, Docusaurus, CMake/nmake
- **Created:** 2026-03-22
- **My Role:** Lead Decompiler — Ghidra analysis, IMPL macro decisions, code review, architecture calls
- **Key References:**
  - Ground truth: `ghidra/exports/Engine/_global.cpp`, `ghidra/exports/Core/_global.cpp`, etc.
  - SDK (cross-reference only): `sdk/Raven_Shield_C_SDK/`
  - UT99 reference: `sdk/Ut99PubSrc/`
  - ImplSource macros: `src/Core/Inc/ImplSource.h`
- **Build command:** `cd build-71 && nmake /s 2>&1 | Where-Object { $_ -match "error " }`
- **Engine.dll base:** 0x10300000, Core.dll base: 0x10100000

## Learnings

<!-- Append new learnings below. -->

### 2026 — Full IMPL_DIVERGE Audit (78 reclassifications)

**Scope:** All 514 IMPL_DIVERGE instances across Engine, Core, R6Engine, Launch, Window.

**Key findings:**
- 420 unique reason strings total
- 78 misclassified as IMPL_DIVERGE (should be IMPL_TODO)

**Patterns that signal IMPL_TODO (not IMPL_DIVERGE):**

1. **"not yet reconstructed/implemented/ported"** — explicit "not yet" language always means IMPL_TODO. Found in UnTerrain.cpp (terrain struct layouts), UnActor.cpp (render subsystem), Window.cpp (UWindowManager ctor).

2. **"permanent stub until X is reconstructed"** — "until" is a future condition = IMPL_TODO by definition. Found in UnPawn.cpp (animation blend selection).

3. **"added for safety" / "added null guard"** — we added something retail doesn't have. We CAN remove it to match retail, so IMPL_TODO. Found in UnPawn.cpp.

4. **"also pending"** — "pending" anywhere in a reason implies temporary, so IMPL_TODO. Found in UnModel.cpp (projector clip logic).

5. **"may differ from retail" / "may not match retail"** — uncertainty about divergence = not confirmed permanent = IMPL_TODO. Found in UnLinker.cpp, UnCorObj.cpp.

6. **Small unexported helpers** — "static internal helper; VA cannot be identified in Ghidra" for helpers like `EncodeHexNibble` (1 line!), `FStringToAnsiBytes`, etc. Per audit rules: small+characterizable unexported helper = IMPL_TODO. Found in Core/UnScript.cpp (13 entries).

7. **Launch.cpp "Reconstructed; no Ghidra match found"** — Previous audit noted "no binary verification path possible." This audit overrides: SafeDisc CAN be bypassed via in-memory process dump, and the "err on IMPL_TODO" rule applies. Reclassified 35 entries.

8. **Core/UnScript.cpp Ravenshield exec* additions** — "absent from Core.dll export table; implementation inferred from context." These functions DO exist in Core.dll binary (just unexported), and exec* functions are small+characterizable. Reclassified 49 entries per the "small characterizable unexported helper → IMPL_TODO" rule.

9. **"needs fresh binary re-analysis"** — explicitly says work remains = IMPL_TODO. Found in UnCamera.cpp.

10. **"until binary extraction is complete"** — extraction IS possible (binary data section); IMPL_TODO. Found in UnMeshInstance.cpp (m_fCylindersRadius).

**Confirmed permanent (kept as IMPL_DIVERGE):**
- rdtsc timing chains
- Karma/MeSDK proprietary SDK calls
- GameSpy/CDKey/PunkBuster dead services
- "permanent header-level binary difference" (PrivateStaticClass vs StaticClass, vtable layouts)
- "permanently unrecoverable register value" (unaff_EDI, x87 ST0 register artifacts)
- D3DDrv FRenderInterface private struct fields (>200KB private state)
- Functions with explicit "permanent:" prefix where reason is concrete

**Rule to remember:** The question is always "Can this function EVER match retail?" — not "Has it been implemented correctly yet?"

### 2026 — IMPL_TODO vs IMPL_DIVERGE classification decisions

**execPrivateSet (UnScript.cpp):** Opcode value for EX_PrivateSet is unknown from Ghidra text exports — GNatives[] table not reconstructed. Kept as IMPL_TODO (not IMPL_DIVERGE) because the opcode IS in the retail binary, discoverable via binary disassembly of Core.dll init code. "Not done yet" ≠ "permanently impossible".

**execDrawNativeHUD (R6HUD.cpp):** 44896-byte Ghidra export exists at `ghidra/exports/R6Game/_r6hud_execDrawNativeHUD.cpp`. Blocked by 7 unresolved FUN_ helpers and 106 raw struct offsets across AR6HUD / AR6Rainbow / AR6PlayerController. Implement only after struct layout mapping is complete.

**UGameEngine::Exec (Engine.cpp, 0x103a3f00):** Demoted from IMPL_MATCH to IMPL_TODO. Ghidra confirms two deviations in TESTPATCH path: (1) SpawnActor at vtable[0xa8/4] — retail constructs FRotator(0,0,0) and FName(0) on stack as args, current code passes zero args beyond `this`; (2) retail calls FindFunctionChecked() before vtable[0x10/4], current code skips it. vtable slots 0xa8/4 and 0x10/4 are confirmed.

**IMPL_DIVERGE audit (UnPawn, UnActor, UnScript, Launch):** All sampled entries correctly classified. Notable patterns confirmed correct: rdtsc/Karma = IMPL_DIVERGE (permanent), "absent from export table" = IMPL_DIVERGE, Launch.cpp "Reconstructed; no Ghidra match found" for static helpers = IMPL_DIVERGE (no binary verification path possible for non-exported static functions).

### 2026-03-22 (Team) — External Blockers & UnMesh FUN_ Helper Analysis

**External Blockers Summary (jason-bourne work):**
- R6HUD.cpp:87: UTF-8 Ghidra export issue (actionable fix: add `encoding="utf-8"` to export_cpp.py)
- DareAudio.cpp:131: FUN helpers fully characterized, directly implementable (~100 LOC)
- UnScript opcodes (Tasks 3–4): Deferred pending script engine decompilation

**UnMesh FUN_ Helpers (Group D items):** All 4 blocked items are unlockable. No permanent divergences. Recommended implementation order:
1. Declare `FRawIndexBuffer` (5 min) — unlocks FUN_1043d7e0
2. Implement FUN_1043f770 (FMeshAnimSeq TArray, 0.5 day) — unlocks items #6 & #8
3. Implement FUN_1043fd50 (MotionChunk TArray, 0.5 day) — fully unlocks #6
4. Implement FUN_1043d7e0 (FAnimMeshVertexStream ctor, 1 hour) — unlocks #7
5. Implement FUN_10438510 (GLazyLoad serializer, 0.5 day) — partial unlock of #9
6. Reconstruct FSkelMeshLODModel + FUN_1043fa50 (2–3 days) — fully unlocks #9

Estimated total effort: 3–5 days to unlock all 4 items.

### WORLD_MAX / HALF_WORLD_MAX (2026-03-22 fix)

Standard UT99/UE1 values: `WORLD_MAX = 524288.0f`, `HALF_WORLD_MAX = 262144.0f`, `HALF_WORLD_MAX1 = 262143.0f`. Added to `EnginePrivate.h` under `#ifndef WORLD_MAX` guard. Used by Karma BSP helpers in EngineAux.cpp.

### UnRender.cpp frustum function analysis (2026)

**FLevelSceneNode::GetViewFrustum (0x10400290):**
- Zone-type lookup bug: `*(INT*)Viewport` reads vtable; retail uses `*(INT*)((BYTE*)Viewport + 0x34)` (object member). Fixed.
- Far-clip distance: Ghidra shows conditional LevelInfo+0x398 flag check → reads custom FarDist from LevelInfo+0x3a0, else 65536.f. Zone array accessed via `*(DWORD*)(Level+0x90) + (zoneIndex*9+0x24)*8`. Implemented.
- 8-corner sky-zone path: retail uses `FMatrix::TransformFPlane(this+0x150, plane)`, not `Deproject`. Left as Deproject (functionally equivalent for W=1 inputs).

**FPointLightMapSceneNode::GetViewFrustum (0x103d1740):**
- Retail: reads FVector at `this+0x1d4`, calls `FSceneNode::Project()`, uses returned `FPlane.Z/.W` as clip-space depth for the 4 Deproject corners. Implemented as `Project(*(FVector*)(this+0x1d4))`.

**FDirectionalLightMapSceneNode::GetViewFrustum (0x103d25d0):**
- Ghidra confirms 8-corner loop over X∈{−1,+1}×Y∈{−1,+1}×Z∈{0,1}. Plane ordering unconfirmed.

**FSceneNode::Project** returns `FPlane` (inherits FVector, adds W). Z and W members are accessible directly.

**UnLevel.cpp IMPL_TODO macros:** All accurately describe remaining blockers (FUN_ internal helpers called by raw retail address, Karma proprietary). No changes warranted — these require identifying and implementing the unnamed helpers from `ghidra/exports/Engine/_unnamed.cpp`.

### Ghidra decompiler limitations with MSVC ABI

Ghidra often fails to show stack-passed args for MSVC `__thiscall` functions when the callee constructs local objects (FRotator, FName, etc.) immediately before a call. The decompiler shows the call as having fewer args than it actually takes. Always cross-check with context (local variable constructions just before a call indicate args).
