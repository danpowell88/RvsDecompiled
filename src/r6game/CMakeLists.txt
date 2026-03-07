# R6Game.dll — Game modes, mission logic, operative management, campaign
# Phase 6D target. Depends on Core, Engine, R6Abstract, R6Engine, R6Weapons.

set(R6GAME_SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR})

file(GLOB_RECURSE R6GAME_SOURCES
    ${R6GAME_SRC_DIR}/*.cpp
    ${R6GAME_SRC_DIR}/*.h
)

list(LENGTH R6GAME_SOURCES SOURCE_COUNT)
if(SOURCE_COUNT GREATER 0)
    add_library(R6Game MODULE ${R6GAME_SOURCES} ${R6GAME_SRC_DIR}/R6Game.def)
    target_compile_definitions(R6Game PRIVATE R6GAME_EXPORTS ThisPackage=R6Game)
    target_include_directories(R6Game BEFORE PRIVATE
        ${R6GAME_SRC_DIR}
        ${PROJECT_SOURCE_DIR}/src/r6abstract
        ${PROJECT_SOURCE_DIR}/src/r6engine
        ${PROJECT_SOURCE_DIR}/src/r6weapons
        ${PROJECT_SOURCE_DIR}/src/engine
    )
    target_link_libraries(R6Game Core_Dep Engine_Dep ${CSDK_LIB}/R6Abstract.lib ${CMAKE_BINARY_DIR}/src/r6engine/Release/R6Engine.lib ${CSDK_LIB}/R6Weapons.lib)
    add_dependencies(R6Game R6Engine)
else()
    message(STATUS "R6Game: no source files yet — skipping")
endif()
