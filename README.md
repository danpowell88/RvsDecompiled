# Project Ravenshield — Game Decompilation & Reconstruction

A project to decompile Rainbow Six: Ravenshield (2003) game runtime binaries using Ghidra and rebuild them into maintainable, readable C++ source code.

## Goal

Produce a playable, maintainable rebuild of Ravenshield's game engine and logic that:
- Compiles from clean C++ source code
- Is as close as possible to the original binaries (byte-comparison verified)
- Prioritizes readability and maintainability over byte-perfect matching
- Can be understood and modified by any game engine developer

## Scope

16 game runtime binaries (15 DLLs + 1 EXE) are decompiled and reconstructed. Third-party libraries (Bink video, OpenAL, Ogg/Vorbis, EAX, MSVC runtimes) are treated as external dependencies.

## Project Structure

```
src/              Reconstructed C++ source (one subdirectory per module)
ghidra/           Ghidra analysis scripts and configuration
tools/            Build toolchain, comparison tools, import helpers
blog/             Docusaurus developer blog
sdk/              SDK references (headers, UnrealScript source, sample code)
retail/           Original game installation (not in repo)
```

## Build Requirements

- **MSVC 7.1** (Visual C++ .NET 2003) — for byte-parity builds
- **CMake 3.10+** — build system
- **Windows Server 2003 SP1 SDK** — era-correct platform headers
- **DirectX 8 SDK** — rendering headers and libraries
- **Ghidra 11.x + JDK 21** — for decompilation analysis
- **Python 3.10+** — for Ghidra scripts and comparison tools
- **Node.js 18+** — for Docusaurus blog

## Quick Start

```bash
# Configure build (MSVC 7.1 legacy target)
cmake -B build -G "NMake Makefiles" -DCMAKE_TOOLCHAIN_FILE=cmake/msvc71.cmake

# Build all modules
cmake --build build

# Run binary comparison against originals
python tools/compare/bindiff.py --original retail/system --rebuilt build/bin
```

## Documentation

See [DECOMPILATION_PLAN.md](DECOMPILATION_PLAN.md) for the full project plan.

See the [developer blog](blog/) for milestone write-ups aimed at a general programming audience.

## License

This project contains no copyrighted game assets or binaries. The reconstructed source code is provided for educational and preservation purposes.
