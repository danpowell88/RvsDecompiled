# Squad Decisions

## Active Decisions

### IMPL Classification Framework (2026-03-22)

**Decision 1: execPrivateSet → IMPL_TODO (not IMPL_DIVERGE)**
- File: `src/Core/Src/UnScript.cpp`
- Function: `UObject::execPrivateSet`
- Ruling: Blocked, not permanently diverged
- Rationale: Opcode value is discoverable via binary analysis of Core.dll GNatives[] table; currently lacks the engineering work to extract it, but this is a temporary blocker, not a permanent constraint.

**Decision 2: UGameEngine::Exec → IMPL_TODO (demoted from IMPL_MATCH)**
- File: `src/Engine/Src/Engine.cpp`
- Function: `UGameEngine::Exec` (0x103a3f00)
- Ruling: Two confirmed behavioral deviations from retail
- Rationale: 
  1. SpawnActor vtable dispatch: Retail pre-constructs `FRotator(0,0,0)` and `FName(0)` on stack; current code does not
  2. FindFunctionChecked: Retail calls this before vtable[0x10/4] dispatch; current code skips it
- Reclassified as IMPL_TODO (upgradeable via deeper binary analysis)

**Decision 3: IMPL_DIVERGE Audit Confirms No Misclassifications**
- Files sampled: UnPawn.cpp, UnActor.cpp, UnScript.cpp, Launch.cpp
- Confirmed patterns (all correctly classified as IMPL_DIVERGE):
  - rdtsc cycle-counter profiling (permanent: CPU instruction encoding difference)
  - Karma/MeSDK binary-only SDK (permanent: proprietary)
  - PunkBuster anti-cheat (permanent: proprietary binary)
  - Absent from retail export table (permanent: unverifiable)
  - Unexported static helpers (permanent: no binary ground truth available)
  - PrivateStaticClass header-level differences (permanent: architectural)

### UnPawn.cpp IMPL Promotions (2026-03-22)

**Promoted to IMPL_MATCH:**
- `APlayerController::execFindStairRotation` (0x103900a0)
- `APawn::findPathToward` (0x1041cfa0)
- Reason: Implementations align with Ghidra control flow and thresholds

**Kept as IMPL_TODO:**
- `APawn::physSpider` (0x103F5990)
- `APawn::physWalking` (0x103ED370)
- Reason: Unresolved scalar provenance from decompiler x87 reuse; requires assembly-level confirmation

### External Blockers Characterization (2026-03-22)

**R6HUD.cpp:87 (UTF-8 Ghidra Export Issue)**
- Status: Actionable
- Root cause: Ghidra `export_cpp.py` fails to encode UTF-8 characters in decompiled output
- Fix: Modify export script line 92 to use `encoding="utf-8"`
- Impact: Once fixed, enables `execDrawNativeHUD` (0x1000ceb0, 10,251 bytes) decompilation

**DareAudio.cpp:131 (FUN_10001550 / FUN_10001660 Helpers)**
- Status: Resolved and implementable
- Finding: Both helpers are simple FArray copy utilities
- Recommendation: Implement directly inline (Option A) rather than as named helpers
- Effort: ~100 LOC, directly implementable from Ghidra analysis
- Impact: Unlocks UDareAudioSubsystem::operator= (0x100017f0)

**UnScript.cpp Opcode Lookups (UnScript.cpp:1105, :3712)**
- Status: Deferred pending script engine decompilation
- Reason: These blockers reference future UnrealScript bytecode interpreter work; opcodes not yet discoverable
- Action: Schedule for when script engine (bytecode switch/case dispatch) is decompiled

### UnMesh FUN_ Helper Tractability (2026-03-22)

**Summary:** All 4 Group D blocked items are unlockable via engineering work. No permanent divergences.

**Helper Breakdown:**

| Helper | Address | Size | Tractability | Unblocks | Effort |
|--------|---------|------|--------------|----------|--------|
| FUN_1043f770 | 0x1043f770 | 224 B | ✅ HIGH | Items #6, #8 | 0.5 day |
| FUN_1043fd50 | 0x1043fd50 | 224 B | ✅ HIGH | Item #6 | 0.5 day |
| FUN_1043d7e0 | 0x1043d7e0 | 126 B | ✅ MEDIUM | Item #7 | 1 hr + FRawIndexBuffer decl |
| FUN_1043fa50 | 0x1043fa50 | 231 B | ✅ MED-LOW | Item #9 | 2–3 days |
| FUN_10438510 | 0x10438510 | 417 B | ✅ HIGH | Item #9 (partial) | 0.5 day |

**Recommended implementation order:**
1. Declare `FRawIndexBuffer` struct (5 min) — unlocks FUN_1043d7e0
2. Implement FUN_1043f770 (FMeshAnimSeq TArray, 0.5 day) — unlocks #6 AND #8
3. Implement FUN_1043fd50 (MotionChunk TArray, 0.5 day) — fully unlocks #6
4. Implement FUN_1043d7e0 (FAnimMeshVertexStream ctor, 1 hour) — unlocks #7
5. Implement FUN_10438510 (GLazyLoad serializer, 0.5 day) — partial unlock of #9
6. Reconstruct FSkelMeshLODModel + FUN_1043fa50 (2–3 days) — fully unlocks #9

**Estimated total effort:** 3–5 days to unlock all 4 items.

## Governance

- All meaningful changes require team consensus
- Document architectural decisions here
- Keep history focused on work, decisions focused on direction
- Decision records include rationale, author, date, and impact assessment
