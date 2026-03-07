# DareAudio.dll / DareAudioScript.dll / DareAudioRelease.dll
# Phase 7 target. DARE audio subsystem — UDareAudioSubsystem (87 exports).
# All three variants share identical source and export tables but link
# different SNDDSound3D backends:
#   DareAudio        → SNDDSound3DDLL_ret
#   DareAudioScript  → SNDDSound3DDLL_VSR
#   DareAudioRelease → SNDDSound3DDLL_VBD (not present in retail — dead variant)

set(DAREAUDIO_SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR})

file(GLOB_RECURSE DAREAUDIO_SOURCES
    ${DAREAUDIO_SRC_DIR}/*.cpp
    ${DAREAUDIO_SRC_DIR}/*.h
)

list(LENGTH DAREAUDIO_SOURCES SOURCE_COUNT)
if(SOURCE_COUNT GREATER 0)
    # Common settings applied to all variants via a helper function
    # Use our rebuilt Engine.lib — the SDK's Engine.lib is missing symbols
    # that DareAudio needs (e.g. UAudioSubsystem default constructor).
    set(ENGINE_BUILT_LIB ${CMAKE_BINARY_DIR}/src/engine/Release/Engine.lib)

    function(dareaudio_target TARGET_NAME SND_DEP)
        add_library(${TARGET_NAME} MODULE ${DAREAUDIO_SOURCES} ${DAREAUDIO_SRC_DIR}/DareAudio.def)
        target_compile_definitions(${TARGET_NAME} PRIVATE DAREAUDIO_EXPORTS ThisPackage=DareAudio)
        # BEFORE ensures our local engine headers beat the UT99 SDK headers.
        target_include_directories(${TARGET_NAME} BEFORE PRIVATE
            ${DAREAUDIO_SRC_DIR}
            ${PROJECT_SOURCE_DIR}/src/engine
        )
        target_link_libraries(${TARGET_NAME}
            Core_Dep
            ${ENGINE_BUILT_LIB}
            ${SND_DEP}
        )
        add_dependencies(${TARGET_NAME} Engine)
    endfunction()

    # --- DareAudio.dll (retail, links ret backend) ---
    dareaudio_target(DareAudio SNDDSound3DDLL_ret)

    # --- DareAudioScript.dll (scripted/editor variant, links VSR backend) ---
    dareaudio_target(DareAudioScript SNDDSound3DDLL_VSR)

    # --- DareAudioRelease.dll (dead variant — VBD backend not in retail) ---
    # Links ret as a stand-in since VBD doesn't exist.
    dareaudio_target(DareAudioRelease SNDDSound3DDLL_ret)
else()
    message(STATUS "DareAudio: no source files yet — skipping")
endif()
