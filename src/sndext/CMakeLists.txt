# SNDext_ret.dll / SNDext_VSR.dll — DARE Sound Engine extension layer
# Phase 7 target. Depends on Core.
# 32 exports (C linkage, __stdcall). Platform abstraction for memory, file I/O,
# error handling, and asynchronous streaming. Ret and VSR variants have identical
# export tables; only internal implementation differs.

set(SNDEXT_SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR})

file(GLOB_RECURSE SNDEXT_SOURCES
    ${SNDEXT_SRC_DIR}/*.cpp
    ${SNDEXT_SRC_DIR}/*.h
)

list(LENGTH SNDEXT_SOURCES SOURCE_COUNT)
if(SOURCE_COUNT GREATER 0)
    # --- SNDext_ret ---
    add_library(SNDext_ret SHARED ${SNDEXT_SOURCES} ${SNDEXT_SRC_DIR}/SNDext_ret.def)
    target_compile_definitions(SNDext_ret PRIVATE SNDEXT_EXPORTS)
    target_include_directories(SNDext_ret PRIVATE ${SNDEXT_SRC_DIR})

    # --- SNDext_VSR ---
    add_library(SNDext_VSR SHARED ${SNDEXT_SOURCES} ${SNDEXT_SRC_DIR}/SNDext_VSR.def)
    target_compile_definitions(SNDext_VSR PRIVATE SNDEXT_EXPORTS)
    target_include_directories(SNDext_VSR PRIVATE ${SNDEXT_SRC_DIR})
else()
    message(STATUS "SNDext: no source files yet — skipping")
endif()
