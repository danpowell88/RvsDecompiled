# Project Context

- **Owner:** Daniel Powell
- **Project:** Tom Clancy's Rainbow Six Ravenshield — Full Decompilation & Reconstruction
- **Stack:** C++98, MSVC 7.1, Unreal Engine (UT99 fork), x86 Windows, Ghidra
- **Created:** 2026-03-22
- **My Role:** Impl Specialist — translating Ghidra decompilations to clean C++
- **Key References:**
  - Ghidra exports: `ghidra/exports/` — ground truth
  - ImplSource macros: `src/Core/Inc/ImplSource.h`
  - guard/unguard rules: guard() opens try, unguard MUST be at function scope (not inside nested blocks)
  - IMPL_MATCH requires full virtual address (e.g. 0x103b4130), not relative offset
  - .def files: check before changing any function signature — mangled name encodes param types
- **Build command:** `cd build-71 && nmake /s 2>&1 | Where-Object { $_ -match "error " }`

## Learnings

<!-- Append new learnings below. -->