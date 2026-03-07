# R6Weapons.dll — Weapon system: ballistics, damage, recoil, firing modes
# Phase 6B target. Depends on Core, Engine, R6Abstract.

set(R6WEAPONS_SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR})

file(GLOB_RECURSE R6WEAPONS_SOURCES
    ${R6WEAPONS_SRC_DIR}/*.cpp
    ${R6WEAPONS_SRC_DIR}/*.h
)

list(LENGTH R6WEAPONS_SOURCES SOURCE_COUNT)
if(SOURCE_COUNT GREATER 0)
    add_library(R6Weapons MODULE ${R6WEAPONS_SOURCES} ${R6WEAPONS_SRC_DIR}/R6Weapons.def)
    target_compile_definitions(R6Weapons PRIVATE R6WEAPONS_EXPORTS ThisPackage=R6Weapons)
    target_include_directories(R6Weapons BEFORE PRIVATE
        ${R6WEAPONS_SRC_DIR}
        ${PROJECT_SOURCE_DIR}/src/r6abstract
        ${PROJECT_SOURCE_DIR}/src/engine
    )
    target_link_libraries(R6Weapons Core_Dep Engine_Dep ${CSDK_LIB}/R6Abstract.lib)
else()
    message(STATUS "R6Weapons: no source files yet — skipping")
endif()
