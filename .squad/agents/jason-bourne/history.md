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