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

- 2026-03-22: Re-verified `UActorChannel::ReceivedBunch` (`0x104827f0`) and `UActorChannel::ReplicateActor` (`0x104834d0`) directly from `ghidra/exports/Engine/_global.cpp`. `FFieldNetCache`/`FClassNetCache` are not a permanent blocker (layout exists in `sdk/Raven_Shield_C_SDK/432Core/Inc/UnCoreNet.h`); the true remaining blockers are unresolved helper mappings and call-order reconstruction in the large property/RPC loops.
- 2026-03-22: Re-verified `UParticleEmitter::UpdateParticles` (`0x103ddca0`) from Ghidra extract. Existing implementation covers the early loop/lifetime path, but collision, bounce, force-spawn, and ramp sections still depend on unresolved runtime layout details and helper mapping; status remains `IMPL_TODO`, explicitly non-permanent.
- 2026-03-22: Re-verified `UModel::Render` (`0x103cd750`) as a large dispatcher with many render helper dependencies in `_unnamed.cpp`; still tractable but substantial. Documenting TODO with precise unresolved pieces is safer than premature partial lift that risks regressions.

- 2026-03-22: Promoted UnPawn stair-rotation (0x103900a0) and findPathToward (0x1041cfa0) from IMPL_TODO to IMPL_MATCH after re-checking Ghidra _global.cpp control flow and thresholds. Kept physSpider/physWalking as IMPL_TODO with tighter blocker notes tied to unresolved decompiler stack/x87 scalar provenance.
