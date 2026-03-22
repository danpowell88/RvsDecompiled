# =============================================================================
# Ravenshield Decompilation Project — Root CMakeLists.txt
# =============================================================================
# Build system for reconstructed C++ source targeting MSVC 7.1 (byte-parity)
# with a modern MSVC fallback path.
#
# Usage (MSVC 7.1 legacy):
#   cmake -B build -G "NMake Makefiles" -DCMAKE_TOOLCHAIN_FILE=cmake/msvc71.cmake
#   cmake --build build
#
# Usage (Modern MSVC):
#   cmake -B build -G "Visual Studio 17 2022" -A Win32
#   cmake --build build --config Release
# =============================================================================

cmake_minimum_required(VERSION 3.10 FATAL_ERROR)
project(RavenShield LANGUAGES CXX)

# --- IMPL_xxx attribution system ---
# All stubs have been resolved (2026-03-14) — strict mode is now permanently ON.
# The build will fail if any function is unannotated or marked IMPL_APPROX.
# IMPL_TODO is now a valid annotation (planned implementation, not yet written).
# To temporarily bypass during a migration pass: cmake -DIMPL_STRICT=OFF ...
option(IMPL_STRICT "Fail build on missing/APPROX IMPL_xxx annotations" ON)
include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/ImplVerification.cmake)

# --- C++ Standard ---
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD 98)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# --- Output directories ---
set(OUTPUT_DIR ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${OUTPUT_DIR})
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_DEBUG ${OUTPUT_DIR})
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_RELEASE ${OUTPUT_DIR})
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_RELWITHDEBINFO ${OUTPUT_DIR})
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${OUTPUT_DIR})
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG ${OUTPUT_DIR})
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE ${OUTPUT_DIR})
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELWITHDEBINFO ${OUTPUT_DIR})

# --- SDK Paths ---
set(SDK_DIR ${PROJECT_SOURCE_DIR}/sdk)
set(CSDK_INC ${SDK_DIR}/Raven_Shield_C_SDK/inc)
set(CSDK_CORE_INC ${SDK_DIR}/Raven_Shield_C_SDK/432Core/Inc)
set(CSDK_LIB ${SDK_DIR}/Raven_Shield_C_SDK/lib)
set(UT99_CORE_INC ${SDK_DIR}/Ut99PubSrc/Core/Inc)
set(UT99_ENGINE_INC ${SDK_DIR}/Ut99PubSrc/Engine/Inc)

# --- Platform SDK Paths ---
set(TOOLCHAIN_DIR ${PROJECT_SOURCE_DIR}/tools/toolchain)
set(WINSDK_INCLUDE ${TOOLCHAIN_DIR}/winsdk/Include CACHE PATH "Windows SDK include path")
set(WINSDK_LIB ${TOOLCHAIN_DIR}/winsdk/Lib CACHE PATH "Windows SDK library path")
set(DXSDK_INCLUDE ${TOOLCHAIN_DIR}/dxsdk/Include CACHE PATH "DirectX SDK include path")
set(DXSDK_LIB ${TOOLCHAIN_DIR}/dxsdk/Lib CACHE PATH "DirectX SDK library path")

# --- External import libraries ---
set(EXTLIBS_DIR ${TOOLCHAIN_DIR}/../tools/extlibs)
if(NOT EXISTS ${EXTLIBS_DIR})
    set(EXTLIBS_DIR ${PROJECT_SOURCE_DIR}/tools/extlibs)
endif()

# --- Compiler flags ---
if(MSVC)
    # /Zc:wchar_t- (disable wchar_t as built-in type) was only added as a
    # negative-suffix switch in MSVC 8.0 (1400). MSVC 7.1 defaults to the
    # typedef mode we want, so no flag is needed there.
    if(MSVC_VERSION GREATER 1310)
        add_compile_options(/Zc:wchar_t-)   # Match MSVC 7.1 behavior
    endif()
    add_compile_options(/W3)            # Warning level 3
    add_compile_options(/GR)            # RTTI enabled (Unreal uses it)
    add_compile_options(/GS-)           # Disable stack cookies (not needed with guard disabled)
    # Use async exception handling so SEH exceptions are visible to C++ code.
    # MSVC 7.1 (1310) uses /EHsc — the /EHsc→/EHa replacement is VS2019-only.
    if(MSVC_VERSION GREATER 1310)
        string(REPLACE "/EHsc" "/EHa" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
    endif()
    # Suppress SDK-origin warnings we cannot fix (legacy Unreal SDK headers).
    # These warning codes only exist in MSVC 2015+ (version 1900+).
    #   C4595 — non-member operator new/delete defined inline (UnFile.h SDK)
    #   C4661 — template instantiation without definition (UnTemplate.h SDK)
    #   C4073 — initializers put in library initialization area (SDK pattern)
    #   C4477 — format string type mismatch in SDK headers
    if(MSVC_VERSION GREATER 1310)
        add_compile_options(/wd4595 /wd4661 /wd4073 /wd4477)
    endif()
    # MSVC 7.1 specific: suppress C4234 (__thiscall in typedef is not standard
    # in 7.1 but the calling convention is still honoured at codegen time).
    if(MSVC_VERSION EQUAL 1310)
        add_compile_options(/wd4234)
    endif()
endif()

# DO_GUARD: controls guard()/unguard() try/catch expansion.
#
# With MSVC 2019 we build with DO_GUARD=0 because mixing our MSVC 2019 DLLs
# with the retail MSVC 7.1 launcher causes terminate() when exceptions cross
# DLL boundaries due to incompatible exception-handling ABIs.
#
# With MSVC 7.1 we build with DO_GUARD=1 because ALL DLLs use the same
# runtime (msvcr71.dll) and there is no ABI mismatch. DO_GUARD=1 also causes
# the compiler to emit the guard() __FUNC_NAME__ function-local statics that
# the retail Core.def exports (this is the retail-accurate behaviour).
if(MSVC AND MSVC_VERSION EQUAL 1310)
    add_definitions(-DDO_GUARD=1)
else()
    add_definitions(-DDO_GUARD=0)
endif()
add_definitions(-D_UNICODE -DUNICODE -D_CRT_SECURE_NO_WARNINGS -D_CRT_NON_CONFORMING_SWPRINTFS)

# --- Global include directories ---
# Available to all modules: core Unreal headers + R6 SDK headers + era-correct platform headers.
# NOTE: src/Core/Inc is included globally so ImplSource.h (and other
# hand-crafted shim headers) are available to all modules without duplication.
# It is listed AFTER the SDK paths so per-module BEFORE overrides still win.
#
# WINSDK_INC and DXSDK_INC come from the toolchain file (msvc71.cmake) when
# building with MSVC 7.1, or from the cache when building with VS 2019.
# They default to the bundled era-correct SDKs under tools/toolchain/.
include_directories(
    ${CSDK_CORE_INC}
    ${UT99_CORE_INC}
    ${UT99_ENGINE_INC}
    ${CSDK_INC}
    ${PROJECT_SOURCE_DIR}/src/Core/Inc
    ${WINSDK_INC}
    ${DXSDK_INC}
)

# =============================================================================
# Interface libraries for pre-built dependencies
# =============================================================================
# These represent the original DLLs that modules can link against during
# incremental reconstruction. As each module is rebuilt from source, its
# INTERFACE library is replaced with the real MODULE library.
# =============================================================================

# --- Core (rebuilt from source) ---
add_library(Core_Dep INTERFACE)
target_include_directories(Core_Dep INTERFACE ${CSDK_CORE_INC} ${UT99_CORE_INC})
target_link_libraries(Core_Dep INTERFACE
    $<TARGET_LINKER_FILE:Core>)

# --- Engine (rebuilt from source) ---
add_library(Engine_Dep INTERFACE)
target_include_directories(Engine_Dep INTERFACE
    ${PROJECT_SOURCE_DIR}/src/Engine/Inc
    ${UT99_ENGINE_INC}
)
target_link_libraries(Engine_Dep INTERFACE
    $<TARGET_LINKER_FILE:Engine>)

# --- Helper macro for game modules ---
macro(add_rvs_module MODULE_NAME)
    set(MODULE_SRC_DIR ${PROJECT_SOURCE_DIR}/src/${MODULE_NAME})
    
    # Collect source files
    file(GLOB_RECURSE MODULE_SOURCES
        ${MODULE_SRC_DIR}/*.cpp
        ${MODULE_SRC_DIR}/*.h
    )
    
    # Skip if no source files yet (stub phase)
    list(LENGTH MODULE_SOURCES SOURCE_COUNT)
    if(SOURCE_COUNT GREATER 0)
        # Create DLL module
        add_library(${MODULE_NAME} MODULE ${MODULE_SOURCES})
        
        # Standard defines for all Unreal modules
        string(TOUPPER ${MODULE_NAME} MODULE_UPPER)
        target_compile_definitions(${MODULE_NAME} PRIVATE
            ${MODULE_UPPER}_EXPORTS
            ThisPackage=${MODULE_NAME}
        )
        
        # Module-specific include directory
        target_include_directories(${MODULE_NAME} PRIVATE ${MODULE_SRC_DIR})
        
        # Base dependencies (all modules need Core)
        target_link_libraries(${MODULE_NAME} Core_Dep)
    else()
        message(STATUS "Skipping ${MODULE_NAME} — no source files yet")
    endif()
endmacro()

# =============================================================================
# Module subdirectories
# =============================================================================
# Uncomment each module as its source is reconstructed.
# Order matches dependency graph (leaves first).
# =============================================================================

# --- Phase 2: Core engine ---
add_subdirectory(src/Core)

# --- Phase 2.5: MeSDK (MathEngine/Karma physics, statically linked into Engine) ---
add_subdirectory(src/MeSDK)

# --- Phase 3: Engine ---
add_subdirectory(src/Engine)

# --- Phase 4: Support modules ---
add_subdirectory(src/Fire)
add_subdirectory(src/Window)
add_subdirectory(src/IpDrv)

# --- Phase 5: Drivers ---
add_subdirectory(src/WinDrv)
add_subdirectory(src/D3DDrv)

# --- Phase 6: R6 game modules ---
add_subdirectory(src/R6Abstract)
add_subdirectory(src/R6Weapons)
add_subdirectory(src/R6Engine)
add_subdirectory(src/R6Game)
add_subdirectory(src/R6GameService)

# --- Phase 7: Audio ---
# Bottom-up: SNDext → SNDDSound3D → DareAudio
add_subdirectory(src/SNDext)
add_subdirectory(src/SNDDSound3D)
add_subdirectory(src/DareAudio)

# --- Phase 8: Main executable ---
add_subdirectory(src/Launch)

# =============================================================================
# Byte-parity verification target
# =============================================================================
# Run "nmake verify" after building to compare rebuilt DLLs against retail.
# Exits non-zero if any IMPL_MATCH function doesn't match the retail binary.
include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/ByteParity.cmake)
add_byte_parity_target()
