# DareAudio.dll + related — DARE audio subsystem
# Phase 7 target. Depends on Core, Engine.

set(DAREAUDIO_SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR})

file(GLOB_RECURSE DAREAUDIO_SOURCES
    ${DAREAUDIO_SRC_DIR}/*.cpp
    ${DAREAUDIO_SRC_DIR}/*.h
)

list(LENGTH DAREAUDIO_SOURCES SOURCE_COUNT)
if(SOURCE_COUNT GREATER 0)
    add_library(DareAudio MODULE ${DAREAUDIO_SOURCES})
    target_compile_definitions(DareAudio PRIVATE DAREAUDIO_EXPORTS ThisPackage=DareAudio)
    target_include_directories(DareAudio PRIVATE
        ${DAREAUDIO_SRC_DIR}
        ${DXSDK_INCLUDE}
    )
    target_link_libraries(DareAudio
        Core_Dep Engine_Dep
        ${DXSDK_LIB}/dsound.lib
        ${DXSDK_LIB}/dxguid.lib
    )
else()
    message(STATUS "DareAudio: no source files yet — skipping")
endif()
