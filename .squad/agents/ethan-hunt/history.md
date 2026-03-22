# Project Context

- **Owner:** Daniel Powell
- **Project:** Tom Clancy's Rainbow Six Ravenshield — Full Decompilation & Reconstruction
- **Stack:** C++98, MSVC 7.1, Unreal Engine (UT99 fork), x86 Windows, CMake/nmake
- **Created:** 2026-03-22
- **My Role:** Toolsmith — build system, toolchain, linker errors, analysis tools
- **Key Build Info:**
  - Build dir: `build-71/`
  - Toolchain: MSVC 7.1 at `tools/toolchain/msvc71/bin`
  - VS2019_X86 needed in PATH for cvtres.exe: `C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Tools\MSVC\14.29.30133\bin\Hostx64\x86`
  - LIB: `tools/toolchain/msvc71/lib;tools/toolchain/winsdk/Lib;tools/toolchain/dxsdk/Lib`
  - Build command: `nmake /s 2>&1 | Where-Object { $_ -match "error " }`
  - .def files are in `src/{module}/Src/{Module}.def`
  - Mangled name suffix codes: H=int/BOOL, M=float, E=BYTE, G=WORD, I=DWORD, _N=bool, PA=pointer, V=class value, AA=reference
- **Tools dir:** `tools/` — scripts go here

## Learnings

<!-- Append new learnings below. -->