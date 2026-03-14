# R6Engine.dll — R6-specific engine extensions (pawns, AI, doors, interaction)
# Phase 6C target. Depends on Core, Engine, R6Abstract.

set(R6ENGINE_SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR})

file(GLOB_RECURSE R6ENGINE_SOURCES
    ${R6ENGINE_SRC_DIR}/Inc/*.h
    ${R6ENGINE_SRC_DIR}/Src/*.cpp
)

list(LENGTH R6ENGINE_SOURCES SOURCE_COUNT)
if(SOURCE_COUNT GREATER 0)
    add_library(R6Engine MODULE ${R6ENGINE_SOURCES} ${R6ENGINE_SRC_DIR}/Src/R6Engine.def)
    target_compile_definitions(R6Engine PRIVATE R6ENGINE_EXPORTS ThisPackage=R6Engine)
    set(R6ABSTRACT_BUILT_LIB ${CMAKE_BINARY_DIR}/src/R6Abstract/Release/R6Abstract.lib)
    target_include_directories(R6Engine BEFORE PRIVATE
        ${R6ENGINE_SRC_DIR}/Inc
        ${PROJECT_SOURCE_DIR}/src/R6Abstract/Inc
        ${PROJECT_SOURCE_DIR}/src/Engine/Inc
    )
    target_link_libraries(R6Engine Core_Dep Engine_Dep ${R6ABSTRACT_BUILT_LIB})
    add_dependencies(R6Engine R6Abstract)
    add_impl_verification(R6Engine ${R6ENGINE_SRC_DIR}/Src)
else()
    message(STATUS "R6Engine: no source files yet — skipping")
endif()
