# SNDDSound3DDLL_ret.dll / SNDDSound3DDLL_VSR.dll — DARE Sound Engine DirectSound3D backend
# Phase 7 target. Depends on SNDext, dsound, winmm.
# Ret variant: 265 exports, VSR variant: 342 exports (additional script/editor functions).
# This is Ubi Soft Montreal's third-party audio middleware implementing 3D positional
# audio via DirectSound3D with EAX environmental audio extension support.

set(SND3D_SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR})

file(GLOB_RECURSE SND3D_SOURCES
    ${SND3D_SRC_DIR}/Src/*.cpp
    ${SND3D_SRC_DIR}/Inc/*.h
)

list(LENGTH SND3D_SOURCES SOURCE_COUNT)
if(SOURCE_COUNT GREATER 0)
    # --- SNDDSound3DDLL_ret ---
    add_library(SNDDSound3DDLL_ret SHARED ${SND3D_SOURCES} ${SND3D_SRC_DIR}/Src/SNDDSound3DDLL_ret.def)
    target_compile_definitions(SNDDSound3DDLL_ret PRIVATE SND3D_EXPORTS)
    target_include_directories(SNDDSound3DDLL_ret PRIVATE ${SND3D_SRC_DIR}/Src)
    target_link_libraries(SNDDSound3DDLL_ret SNDext_ret dsound winmm)

    # --- SNDDSound3DDLL_VSR ---
    add_library(SNDDSound3DDLL_VSR SHARED ${SND3D_SOURCES} ${SND3D_SRC_DIR}/Src/SNDDSound3DDLL_VSR.def)
    target_compile_definitions(SNDDSound3DDLL_VSR PRIVATE SND3D_EXPORTS SND3D_VSR)
    target_include_directories(SNDDSound3DDLL_VSR PRIVATE ${SND3D_SRC_DIR}/Src)
    target_link_libraries(SNDDSound3DDLL_VSR SNDext_VSR dsound winmm)
    add_impl_verification(SNDDSound3DDLL_ret ${SND3D_SRC_DIR}/Src)
    add_impl_verification(SNDDSound3DDLL_VSR ${SND3D_SRC_DIR}/Src)
else()
    message(STATUS "SNDDSound3D: no source files yet — skipping")
endif()
