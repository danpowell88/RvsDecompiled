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