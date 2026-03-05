# =============================================================================
# MSVC 7.1 Toolchain File for CMake
# =============================================================================
# Points CMake at the MSVC 7.1 (Visual C++ .NET 2003) compiler from
# tools/toolchain/msvc71/ for byte-parity builds against the original
# Ravenshield binaries.
#
# Usage: cmake -B build -G "NMake Makefiles" -DCMAKE_TOOLCHAIN_FILE=cmake/msvc71.cmake
# =============================================================================

set(CMAKE_SYSTEM_NAME Windows)
set(CMAKE_SYSTEM_PROCESSOR x86)

# --- Toolchain paths ---
get_filename_component(TOOLCHAIN_ROOT "${CMAKE_CURRENT_LIST_DIR}/../tools/toolchain" ABSOLUTE)
set(MSVC71_BIN "${TOOLCHAIN_ROOT}/msvc71/bin")
set(MSVC71_INCLUDE "${TOOLCHAIN_ROOT}/msvc71/include")
set(MSVC71_LIB "${TOOLCHAIN_ROOT}/msvc71/lib")
set(WINSDK_INCLUDE "${TOOLCHAIN_ROOT}/winsdk/Include")
set(WINSDK_LIB "${TOOLCHAIN_ROOT}/winsdk/Lib")

# --- Compiler ---
set(CMAKE_C_COMPILER "${MSVC71_BIN}/cl.exe")
set(CMAKE_CXX_COMPILER "${MSVC71_BIN}/cl.exe")
set(CMAKE_LINKER "${MSVC71_BIN}/link.exe")
set(CMAKE_AR "${MSVC71_BIN}/lib.exe")

# --- Flags matching original build configuration ---
# /O2   - Maximize speed (release build)
# /Ob2  - Aggressive inlining
# /GR   - Enable RTTI
# /MD   - Dynamic CRT (msvcr71.dll)
# /Zc:wchar_t- - wchar_t is NOT a built-in type (matches original)
# /W3   - Warning level 3
set(CMAKE_CXX_FLAGS_INIT "/Zc:wchar_t- /GR /W3")
set(CMAKE_CXX_FLAGS_RELEASE_INIT "/O2 /Ob2 /MD /DNDEBUG")
set(CMAKE_CXX_FLAGS_DEBUG_INIT "/Od /MDd /Zi /D_DEBUG")

# --- Include paths ---
# MSVC 7.1 headers first, then era-correct Windows SDK
set(CMAKE_CXX_STANDARD_INCLUDE_DIRECTORIES "${MSVC71_INCLUDE};${WINSDK_INCLUDE}")

# --- Library paths ---
set(CMAKE_CXX_STANDARD_LINK_DIRECTORIES "${MSVC71_LIB};${WINSDK_LIB}")

# --- Linker flags ---
set(CMAKE_EXE_LINKER_FLAGS_INIT "/MACHINE:X86 /SUBSYSTEM:WINDOWS")
set(CMAKE_MODULE_LINKER_FLAGS_INIT "/MACHINE:X86")
set(CMAKE_SHARED_LINKER_FLAGS_INIT "/MACHINE:X86")
