# Project Context

- **Owner:** Daniel Powell
- **Project:** Tom Clancy's Rainbow Six Ravenshield — Full Decompilation & Reconstruction
- **Stack:** C++98, MSVC 7.1, Unreal Engine (UT99 fork), Ghidra
- **Created:** 2026-03-22
- **My Role:** Reference Expert — UT99 source, UnrealScript 1.56/1.66, SDK headers, Unreal Engine cross-reference
- **Key Reference Locations:**
  - UT99 C++ source: `sdk/Ut99PubSrc/` (Core/Inc, Engine/Inc, Engine/Src, etc.)
  - SDK headers: `sdk/Raven_Shield_C_SDK/inc/` (21 headers) and `sdk/Raven_Shield_C_SDK/432Core/Inc/` (50+ headers)
  - UnrealScript: look in `sdk/UnrealScriptSrc/` or related paths
  - Ghidra exports: `ghidra/exports/` — always ground truth when conflicting with SDK
- **Important:** SDK is community-maintained, NOT official. Ghidra wins when they disagree.

## Learnings

<!-- Append new learnings below. -->

### 2026-03-22: External Blockers Investigation Complete

**R6HUD.cpp:87 (UTF-8 Encoding Issue)**
- Root cause found: Ghidra `export_cpp.py` doesn't use UTF-8 encoding when writing decompiled C code
- Function `execDrawNativeHUD` (0x1000ceb0, 10,251 bytes) has UTF-8 characters in its decompilation
- Fix: Modify `ghidra/scripts/export_cpp.py` line 92 to `open(cpp_path, "w", encoding="utf-8")`
- Status: Actionable, requires Ghidra environment

**DareAudio.cpp:131 (FUN_10001550 / FUN_10001660)**
- Both helpers are straightforward FArray copy operations for 4-byte and 20-byte elements
- Implementation exists in Ghidra exports; directly implementable without blockers
- Recommendation: Inline directly into UDareAudioSubsystem::operator= rather than named helpers
- Effort: ~100 LOC
- Status: Ready to implement

**UnScript.cpp Opcodes (Tasks 3–4)**
- EX_StringToName and execPrivateSet opcodes referenced in future script engine work
- These blockers do NOT currently exist in codebase (UnScript.cpp is 321 lines, only animation notifies)
- Status: Defer until script engine bytecode interpreter is decompiled
- When decompiling, opcodes ARE recoverable from Core.dll binary disassembly (not permanent divergence)