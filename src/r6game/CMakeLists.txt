# R6Game.dll — Game modes, mission logic, operative management, campaign
# Phase 6D target. Depends on Core, Engine, R6Abstract, R6Engine, R6Weapons.

set(R6GAME_SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR})

file(GLOB_RECURSE R6GAME_SOURCES
    ${R6GAME_SRC_DIR}/*.cpp
    ${R6GAME_SRC_DIR}/*.h
)

list(LENGTH R6GAME_SOURCES SOURCE_COUNT)
if(SOURCE_COUNT GREATER 0)
    add_library(R6Game MODULE ${R6GAME_SOURCES})
    target_compile_definitions(R6Game PRIVATE R6GAME_EXPORTS ThisPackage=R6Game)
    target_include_directories(R6Game PRIVATE ${R6GAME_SRC_DIR})
    target_link_libraries(R6Game
        Core_Dep Engine_Dep
        ${CSDK_LIB}/R6Abstract.lib
        ${CSDK_LIB}/R6Engine.lib
        ${CSDK_LIB}/R6Weapons.lib
    )
else()
    message(STATUS "R6Game: no source files yet — skipping")
endif()
