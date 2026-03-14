# R6Abstract.dll — Abstract base classes for R6 game systems
# Phase 6A target. Depends on Core, Engine. Smallest R6 module.
# 13 classes, 207 ordinal exports, 3 AUTOGENERATE_NAME tokens.

set(R6ABSTRACT_SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR})

file(GLOB_RECURSE R6ABSTRACT_SOURCES
    ${R6ABSTRACT_SRC_DIR}/Inc/*.h
    ${R6ABSTRACT_SRC_DIR}/Src/*.cpp
)

list(LENGTH R6ABSTRACT_SOURCES SOURCE_COUNT)
if(SOURCE_COUNT GREATER 0)
    add_library(R6Abstract SHARED ${R6ABSTRACT_SOURCES} ${R6ABSTRACT_SRC_DIR}/Src/R6Abstract.def)
    target_compile_definitions(R6Abstract PRIVATE R6ABSTRACT_EXPORTS ThisPackage=R6Abstract)
    target_include_directories(R6Abstract BEFORE PRIVATE
        ${R6ABSTRACT_SRC_DIR}/Inc
        ${PROJECT_SOURCE_DIR}/src/Engine/Inc
    )
    target_link_libraries(R6Abstract Core_Dep Engine_Dep)
    add_impl_verification(R6Abstract ${R6ABSTRACT_SRC_DIR}/Src)
else()
    message(STATUS "R6Abstract: no source files yet — skipping")
endif()
