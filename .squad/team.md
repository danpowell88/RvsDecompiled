# Squad Team — rvs

## Coordinator

| Name | Role | Notes |
|------|------|-------|
| Squad | Coordinator | Routes work, enforces handoffs and reviewer gates. Does not generate domain artifacts. |

## Members

| Name | Role | Charter | Status |
|------|------|---------|--------|
| John Wick | Lead Decompiler | `.squad/agents/john-wick/charter.md` | ✅ Active |
| Jack Reacher | Impl Specialist | `.squad/agents/jack-reacher/charter.md` | ✅ Active |
| Ethan Hunt | Toolsmith | `.squad/agents/ethan-hunt/charter.md` | ✅ Active |
| Jason Bourne | Reference Expert | `.squad/agents/jason-bourne/charter.md` | ✅ Active |
| Sarah Connor | Verifier/QA | `.squad/agents/sarah-connor/charter.md` | ✅ Active |
| Wade Wilson | Tech Blogger | `.squad/agents/wade-wilson/charter.md` | ✅ Active |
| Scribe | Session Logger | `.squad/agents/scribe/charter.md` | 📋 Silent |
| Ralph | Work Monitor | — | 🔄 Monitor |

## Project Context

- **Owner:** Daniel Powell
- **Project:** Tom Clancy's Rainbow Six Ravenshield — Full Decompilation & Reconstruction
- **Stack:** C++98, MSVC 7.1, Unreal Engine (UT99 fork), x86 Windows, Ghidra, Docusaurus, CMake/nmake
- **Description:** Decompile all 16 Ravenshield binaries (DLLs + EXE) into maintainable, readable C++ that compiles with MSVC 7.1 and achieves byte parity with retail. Blog about the journey.
- **Created:** 2026-03-22
- **Key References:** `ghidra/exports/` (ground truth), `sdk/Raven_Shield_C_SDK/` (cross-reference only), `sdk/Ut99PubSrc/` (engine reference), `sdk/UnrealScriptSrc/` (1.56/1.66 .uc source)
- **Build:** `cd build-71 && nmake /s 2>&1 | Where-Object { $_ -match "error " }`