# R6Abstract.dll — Abstract base classes for R6 game systems
# Phase 6A target. Depends on Core, Engine. Smallest R6 module.

set(R6ABSTRACT_SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR})

file(GLOB_RECURSE R6ABSTRACT_SOURCES
    ${R6ABSTRACT_SRC_DIR}/*.cpp
    ${R6ABSTRACT_SRC_DIR}/*.h
)

list(LENGTH R6ABSTRACT_SOURCES SOURCE_COUNT)
if(SOURCE_COUNT GREATER 0)
    add_library(R6Abstract MODULE ${R6ABSTRACT_SOURCES})
    target_compile_definitions(R6Abstract PRIVATE R6ABSTRACT_EXPORTS ThisPackage=R6Abstract)
    target_include_directories(R6Abstract PRIVATE ${R6ABSTRACT_SRC_DIR})
    target_link_libraries(R6Abstract Core_Dep Engine_Dep)
else()
    message(STATUS "R6Abstract: no source files yet — skipping")
endif()
