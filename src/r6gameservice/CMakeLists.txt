# R6GameService.dll — Server list, mod info, patch management
# Phase 6E target. Depends on Core, Engine, R6Game.

set(R6GAMESERVICE_SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR})

file(GLOB_RECURSE R6GAMESERVICE_SOURCES
    ${R6GAMESERVICE_SRC_DIR}/Inc/*.h
    ${R6GAMESERVICE_SRC_DIR}/Src/*.cpp
)

list(LENGTH R6GAMESERVICE_SOURCES SOURCE_COUNT)
if(SOURCE_COUNT GREATER 0)
    add_library(R6GameService MODULE ${R6GAMESERVICE_SOURCES} ${R6GAMESERVICE_SRC_DIR}/Src/R6GameService.def)
    target_compile_definitions(R6GameService PRIVATE R6GAMESERVICE_EXPORTS ThisPackage=R6GameService)
    set(R6ABSTRACT_BUILT_LIB ${CMAKE_BINARY_DIR}/src/r6abstract/Release/R6Abstract.lib)
    target_include_directories(R6GameService BEFORE PRIVATE
        ${R6GAMESERVICE_SRC_DIR}/Inc
        ${PROJECT_SOURCE_DIR}/src/r6abstract/Inc
        ${PROJECT_SOURCE_DIR}/src/engine/Inc
    )
    target_link_libraries(R6GameService Core_Dep Engine_Dep ${R6ABSTRACT_BUILT_LIB})
    add_dependencies(R6GameService R6Abstract)
else()
    message(STATUS "R6GameService: no source files yet — skipping")
endif()
