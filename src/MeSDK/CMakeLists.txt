# MeSDK — Decompiled MathEngine/Karma physics SDK
# Statically linked from Engine.dll; extracted via Ghidra decompilation.
# Original source: MathEngine Ltd (proprietary), statically compiled into Engine.dll.
# This reconstruction is based on Ghidra decompilation of Engine.dll
# (VA range 0x10490000-0x10510000, approx. 1448 functions).

cmake_minimum_required(VERSION 3.10)

set(MESDK_SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR})

set(MESDK_SOURCES
    Src/MdtBody.cpp
    Src/MdtContact.cpp
    Src/McdModel.cpp
    Src/MeWorld.cpp
)

add_library(MeSDK STATIC ${MESDK_SOURCES})

target_include_directories(MeSDK
    PUBLIC  ${MESDK_SRC_DIR}/Inc
    PRIVATE ${CMAKE_SOURCE_DIR}/src/Engine/Inc
)

# Core/Inc for ImplSource.h; SDK engine headers for Unreal types used by callers.
target_include_directories(MeSDK PUBLIC
    ${CMAKE_SOURCE_DIR}/src/Core/Inc
    ${CMAKE_SOURCE_DIR}/sdk/engine/Inc
)

add_impl_verification(MeSDK ${MESDK_SRC_DIR}/Src)
