# =============================================================================
# MSVC 7.1 Toolchain File for CMake
# =============================================================================
# Points CMake at the MSVC 7.1 (Visual C++ .NET 2003) compiler from
# tools/toolchain/msvc71/ for byte-parity builds against the original
# Ravenshield binaries.
#
# Usage: cmake -B build-71 -G "NMake Makefiles" \
#              -DCMAKE_TOOLCHAIN_FILE=cmake/msvc71.cmake \
#              -DCMAKE_BUILD_TYPE=Release .
# =============================================================================

set(CMAKE_SYSTEM_NAME Windows)
set(CMAKE_SYSTEM_PROCESSOR x86)

# --- Skip the linker during CMake's compiler detection probe ---
# The MSVC 7.1 Toolkit lacks MSVCRTD.lib (debug CRT) so the default
# "compile a .exe" probe fails. Build a static lib instead to avoid the
# linker entirely during cmake configuration.
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

# --- Toolchain paths ---
get_filename_component(TOOLCHAIN_ROOT "${CMAKE_CURRENT_LIST_DIR}/../tools/toolchain" ABSOLUTE)
set(MSVC71_BIN     "${TOOLCHAIN_ROOT}/msvc71/bin")
set(MSVC71_INC     "${TOOLCHAIN_ROOT}/msvc71/include")
set(MSVC71_LIB     "${TOOLCHAIN_ROOT}/msvc71/lib")
set(WINSDK_INC     "${TOOLCHAIN_ROOT}/winsdk/Include")
set(WINSDK_LIB     "${TOOLCHAIN_ROOT}/winsdk/Lib")
set(DXSDK_INC      "${TOOLCHAIN_ROOT}/dxsdk/Include")
set(DXSDK_LIB      "${TOOLCHAIN_ROOT}/dxsdk/Lib")

# --- Locate VS 2019 Build Tools for lib.exe and nmake.exe ---
# The MSVC 7.1 Toolkit does NOT include lib.exe. We borrow lib.exe and
# nmake.exe from a VS 2019 Build Tools installation (these are only used
# as build orchestrators — the actual C++ compilation still uses cl.exe 1310).
set(VS2019_X86 "C:/Program Files (x86)/Microsoft Visual Studio/2019/BuildTools/VC/Tools/MSVC/14.29.30133/bin/Hostx64/x86")

# --- Compiler ---
set(CMAKE_C_COMPILER   "${MSVC71_BIN}/cl.exe"   CACHE FILEPATH "MSVC 7.1 C compiler")
set(CMAKE_CXX_COMPILER "${MSVC71_BIN}/cl.exe"   CACHE FILEPATH "MSVC 7.1 C++ compiler")
set(CMAKE_LINKER       "${MSVC71_BIN}/link.exe" CACHE FILEPATH "MSVC 7.1 linker")
set(CMAKE_AR           "${VS2019_X86}/lib.exe"  CACHE FILEPATH "Static lib archiver (from VS2019)")

# NMake is the build driver for "NMake Makefiles" generator.
set(CMAKE_MAKE_PROGRAM "${VS2019_X86}/nmake.exe" CACHE FILEPATH "NMake from VS2019")

# --- Compiler flags ---
#
# /GR        Enable RTTI (Unreal uses dynamic_cast heavily)
# /W3        Warning level 3
# /Oi        Enable intrinsic functions (matches retail build)
# /GS-       Disable security cookies (retail was compiled without them)
# /nologo    Suppress banner
#
# NOTE: We do NOT pass /Zc:wchar_t- here because MSVC 7.1 does not support
# the negative-suffix form (/Zc:wchar_t- with trailing dash was added in
# MSVC 8.0). The retail build relied on wchar_t being a typedef (unsigned
# short), which is MSVC 7.1's DEFAULT. No flag needed.
#
# NOTE: /EHa (async exception handling) is set in CMakeLists.txt for VS2019;
# for MSVC 7.1 we use /EHsc which matches the retail compilation mode.
set(CMAKE_CXX_FLAGS_INIT         "/GR /W3 /Oi /GS- /nologo")
set(CMAKE_CXX_FLAGS_RELEASE_INIT "/O2 /Ob2 /MD /DNDEBUG")

# Debug build: use release CRT (/MD not /MDd) since the Toolkit lacks MSVCRTD.lib.
set(CMAKE_CXX_FLAGS_DEBUG_INIT   "/Od /MD /Zi /D_DEBUG")

# --- Suppress include/lib paths that CMake auto-detects from the registry ---
# CMake's MSVC detection reads the VS install from the registry and would add
# VS2019 headers — we want ONLY the era-correct headers below.
set(CMAKE_CXX_STANDARD_INCLUDE_DIRECTORIES
    "${MSVC71_INC}"
    "${WINSDK_INC}"
    "${DXSDK_INC}"
)

# --- Library search paths ---
link_directories("${MSVC71_LIB}" "${WINSDK_LIB}" "${DXSDK_LIB}")

# Propagate path variables to the parent CMakeLists so it can add them to
# include_directories() globally (WINSDK_INC, DXSDK_INC are checked there).
set(WINSDK_INC "${WINSDK_INC}" CACHE PATH "Windows Server 2003 SP1 Platform SDK include")
set(DXSDK_INC  "${DXSDK_INC}"  CACHE PATH "DirectX SDK include")

# --- Linker flags ---
set(CMAKE_EXE_LINKER_FLAGS_INIT    "/MACHINE:X86 /SUBSYSTEM:WINDOWS /NOLOGO")
# /FORCE:UNRESOLVED — MSVC 7.1 with DO_GUARD=0 never emits __FUNC_NAME__ statics,
# but retail Core.def exports 6 of them. No retail DLL imports them; null export
# addresses are safe. Without this flag the link would fail with LNK2001.
set(CMAKE_MODULE_LINKER_FLAGS_INIT "/MACHINE:X86 /NOLOGO /FORCE:UNRESOLVED")
set(CMAKE_SHARED_LINKER_FLAGS_INIT "/MACHINE:X86 /NOLOGO")

# --- PATH: cl.exe depends on c1.dll, c2.dll, mspdb71.dll, msobj71.dll ---
# These DLLs are in MSVC71_BIN. CMake's configure phase inherits PATH from
# the parent process, but build invocations may have a different PATH. Set
# it explicitly so NMake finds the DLLs at build time as well.
# VS2019_X86 must also be in PATH because MSVC 7.1 link.exe delegates .rc
# file conversion to cvtres.exe, which is not shipped with MSVC 7.1 but IS
# present in VS2019 Build Tools.
set(ENV{PATH} "${MSVC71_BIN};${VS2019_X86};$ENV{PATH}")
set(ENV{INCLUDE} "${MSVC71_INC};${WINSDK_INC};${DXSDK_INC}")
set(ENV{LIB}     "${MSVC71_LIB};${WINSDK_LIB};${DXSDK_LIB}")

