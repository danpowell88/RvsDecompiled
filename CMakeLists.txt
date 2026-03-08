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
    add_compile_options(/Zc:wchar_t-)   # Match MSVC 7.1 behavior
    add_compile_options(/W3)            # Warning level 3
    add_compile_options(/GR)            # RTTI enabled (Unreal uses it)
    add_compile_options(/GS-)           # Disable stack cookies (not needed with guard disabled)
    # Use async exception handling so SEH exceptions are visible to C++ code.
    string(REPLACE "/EHsc" "/EHa" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
endif()

# Disable guard/unguard try/catch blocks. Cross-CRT exception handling between
# MSVC 7.1 (retail DLLs) and MSVC 2019 (our exe) causes terminate() when
# exceptions propagate through our stack frames. With DO_GUARD=0, guard/unguard
# become plain braces — no try/catch interference with cross-DLL exceptions.
add_definitions(-DDO_GUARD=0 -D_UNICODE -DUNICODE)

# --- Global include directories ---
# Available to all modules: core Unreal headers + R6 SDK headers
include_directories(
    ${CSDK_CORE_INC}
    ${UT99_CORE_INC}
    ${UT99_ENGINE_INC}
    ${CSDK_INC}
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
    ${CMAKE_BINARY_DIR}/src/core/Release/Core.lib)

# --- Engine (rebuilt from source) ---
add_library(Engine_Dep INTERFACE)
target_include_directories(Engine_Dep INTERFACE
    ${PROJECT_SOURCE_DIR}/src/engine/Inc
    ${UT99_ENGINE_INC}
)
target_link_libraries(Engine_Dep INTERFACE
    ${CMAKE_BINARY_DIR}/src/engine/Release/Engine.lib)

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
add_subdirectory(src/core)

# --- Phase 3: Engine ---
add_subdirectory(src/engine)

# --- Phase 4: Support modules ---
add_subdirectory(src/fire)
add_subdirectory(src/window)
add_subdirectory(src/ipdrv)

# --- Phase 5: Drivers ---
add_subdirectory(src/windrv)
add_subdirectory(src/d3ddrv)

# --- Phase 6: R6 game modules ---
add_subdirectory(src/r6abstract)
add_subdirectory(src/r6weapons)
add_subdirectory(src/r6engine)
add_subdirectory(src/r6game)
add_subdirectory(src/r6gameservice)

# --- Phase 7: Audio ---
# Bottom-up: SNDext → SNDDSound3D → DareAudio
add_subdirectory(src/sndext)
add_subdirectory(src/sndsound3d)
add_subdirectory(src/dareaudio)

# --- Phase 8: Main executable ---
add_subdirectory(src/launch)
