# R6Weapons.dll — Weapon system: ballistics, damage, recoil, firing modes
# Phase 6B target. Depends on Core, Engine, R6Abstract.

set(R6WEAPONS_SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR})

file(GLOB_RECURSE R6WEAPONS_SOURCES
    ${R6WEAPONS_SRC_DIR}/Inc/*.h
    ${R6WEAPONS_SRC_DIR}/Src/*.cpp
)

list(LENGTH R6WEAPONS_SOURCES SOURCE_COUNT)
if(SOURCE_COUNT GREATER 0)
    add_library(R6Weapons MODULE ${R6WEAPONS_SOURCES} ${R6WEAPONS_SRC_DIR}/Src/R6Weapons.def)
    target_compile_definitions(R6Weapons PRIVATE R6WEAPONS_EXPORTS ThisPackage=R6Weapons)
    set(R6ABSTRACT_BUILT_LIB ${CMAKE_BINARY_DIR}/src/R6Abstract/Release/R6Abstract.lib)
    target_include_directories(R6Weapons BEFORE PRIVATE
        ${R6WEAPONS_SRC_DIR}/Inc
        ${PROJECT_SOURCE_DIR}/src/R6Abstract/Inc
        ${PROJECT_SOURCE_DIR}/src/Engine/Inc
    )
    target_link_libraries(R6Weapons Core_Dep Engine_Dep ${R6ABSTRACT_BUILT_LIB})
    add_dependencies(R6Weapons R6Abstract)
    add_impl_verification(R6Weapons ${R6WEAPONS_SRC_DIR}/Src)
else()
    message(STATUS "R6Weapons: no source files yet — skipping")
endif()
