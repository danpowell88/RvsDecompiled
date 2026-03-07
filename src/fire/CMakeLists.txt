# Fire.dll — Procedural fire/water/wave texture generators
# Phase 4 target. Depends on Core, Engine.
# 7 classes: UFractalTexture, UFireTexture, UWaterTexture, UWaveTexture,
#            UFluidTexture, UIceTexture, UWetTexture
# 147 ordinal exports.

set(FIRE_SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR})

file(GLOB_RECURSE FIRE_SOURCES
    ${FIRE_SRC_DIR}/*.cpp
    ${FIRE_SRC_DIR}/*.h
)

list(LENGTH FIRE_SOURCES SOURCE_COUNT)
if(SOURCE_COUNT GREATER 0)
    add_library(Fire MODULE ${FIRE_SOURCES} ${FIRE_SRC_DIR}/Fire.def)
    target_compile_definitions(Fire PRIVATE FIRE_EXPORTS ThisPackage=Fire)
    # BEFORE ensures src/engine/ shim headers beat global UT99_ENGINE_INC.
    target_include_directories(Fire BEFORE PRIVATE
        ${FIRE_SRC_DIR}
        ${PROJECT_SOURCE_DIR}/src/engine
    )
    target_link_libraries(Fire Core_Dep Engine_Dep)
else()
    message(STATUS "Fire: no source files yet — skipping")
endif()
