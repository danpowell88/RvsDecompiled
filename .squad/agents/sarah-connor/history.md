# Project Context

- **Owner:** Daniel Powell
- **Project:** Tom Clancy's Rainbow Six Ravenshield — Full Decompilation & Reconstruction
- **Stack:** C++98, MSVC 7.1, Unreal Engine (UT99 fork), x86 Windows, Ghidra
- **Created:** 2026-03-22
- **My Role:** Verifier/QA — binary comparison, IMPL_MATCH verification, regression checks, build validation
- **Key Verification Info:**
  - Comparison tools: `tools/compare/bindiff.py`, `tools/compare/funcmatch.py`
  - Ghidra exports: `ghidra/exports/` — ground truth for comparison
  - ImplSource macros: `src/Core/Inc/ImplSource.h` — IMPL_MATCH claims byte parity
  - Build check: `cd build-71 && nmake /s 2>&1 | Where-Object { $_ -match "error " }`
  - Engine.dll base: 0x10300000, Core.dll base: 0x10100000
- **IMPL_MATCH requires:** full virtual address, verified against Ghidra output

## Learnings

<!-- Append new learnings below. -->