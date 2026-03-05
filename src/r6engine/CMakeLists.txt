# R6Engine.dll — R6-specific engine extensions (pawns, AI, doors, interaction)
# Phase 6C target. Depends on Core, Engine, R6Abstract.

set(R6ENGINE_SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR})

file(GLOB_RECURSE R6ENGINE_SOURCES
    ${R6ENGINE_SRC_DIR}/*.cpp
    ${R6ENGINE_SRC_DIR}/*.h
)

list(LENGTH R6ENGINE_SOURCES SOURCE_COUNT)
if(SOURCE_COUNT GREATER 0)
    add_library(R6Engine MODULE ${R6ENGINE_SOURCES})
    target_compile_definitions(R6Engine PRIVATE R6ENGINE_EXPORTS ThisPackage=R6Engine)
    target_include_directories(R6Engine PRIVATE ${R6ENGINE_SRC_DIR})
    target_link_libraries(R6Engine Core_Dep Engine_Dep ${CSDK_LIB}/R6Abstract.lib)
else()
    message(STATUS "R6Engine: no source files yet — skipping")
endif()
