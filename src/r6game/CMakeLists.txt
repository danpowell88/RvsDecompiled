# R6Game.dll — Game modes, mission logic, operative management, campaign
# Phase 6D target. Depends on Core, Engine, R6Abstract, R6Engine, R6Weapons.

set(R6GAME_SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR})
set(R6ABSTRACT_BUILT_LIB ${CMAKE_BINARY_DIR}/src/r6abstract/Release/R6Abstract.lib)
set(R6WEAPONS_BUILT_LIB ${CMAKE_BINARY_DIR}/src/r6weapons/Release/R6Weapons.lib)

file(GLOB_RECURSE R6GAME_SOURCES
    ${R6GAME_SRC_DIR}/Inc/*.h
    ${R6GAME_SRC_DIR}/Src/*.cpp
)

list(LENGTH R6GAME_SOURCES SOURCE_COUNT)
if(SOURCE_COUNT GREATER 0)
    add_library(R6Game MODULE ${R6GAME_SOURCES} ${R6GAME_SRC_DIR}/Src/R6Game.def)
    target_compile_definitions(R6Game PRIVATE R6GAME_EXPORTS ThisPackage=R6Game)
    target_include_directories(R6Game BEFORE PRIVATE
        ${R6GAME_SRC_DIR}/Inc
        ${PROJECT_SOURCE_DIR}/src/r6abstract/Inc
        ${PROJECT_SOURCE_DIR}/src/r6engine/Inc
        ${PROJECT_SOURCE_DIR}/src/r6weapons/Inc
        ${PROJECT_SOURCE_DIR}/src/engine/Inc
    )
    target_link_libraries(R6Game
        Core_Dep Engine_Dep
        ${R6ABSTRACT_BUILT_LIB}
        ${CMAKE_BINARY_DIR}/src/r6engine/Release/R6Engine.lib
        ${R6WEAPONS_BUILT_LIB}
    )
    add_dependencies(R6Game R6Abstract R6Engine R6Weapons)
else()
    message(STATUS "R6Game: no source files yet — skipping")
endif()
