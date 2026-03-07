# R6GameService.dll — Server list, mod info, patch management
# Phase 6E target. Depends on Core, Engine, R6Game.

set(R6GAMESERVICE_SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR})

file(GLOB_RECURSE R6GAMESERVICE_SOURCES
    ${R6GAMESERVICE_SRC_DIR}/*.cpp
    ${R6GAMESERVICE_SRC_DIR}/*.h
)

list(LENGTH R6GAMESERVICE_SOURCES SOURCE_COUNT)
if(SOURCE_COUNT GREATER 0)
    add_library(R6GameService MODULE ${R6GAMESERVICE_SOURCES} ${R6GAMESERVICE_SRC_DIR}/R6GameService.def)
    target_compile_definitions(R6GameService PRIVATE R6GAMESERVICE_EXPORTS ThisPackage=R6GameService)
    target_include_directories(R6GameService BEFORE PRIVATE
        ${R6GAMESERVICE_SRC_DIR}
        ${PROJECT_SOURCE_DIR}/src/r6abstract
        ${PROJECT_SOURCE_DIR}/src/engine
    )
    target_link_libraries(R6GameService Core_Dep Engine_Dep ${CSDK_LIB}/R6Abstract.lib)
else()
    message(STATUS "R6GameService: no source files yet — skipping")
endif()
