# Core.dll — Foundation layer (UObject, FName, memory, math, serialization)
# Phase 2 target. Zero dependencies on other game modules.

set(CORE_SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR})

file(GLOB_RECURSE CORE_SOURCES
    ${CORE_SRC_DIR}/*.cpp
    ${CORE_SRC_DIR}/*.h
)

list(LENGTH CORE_SOURCES SOURCE_COUNT)
if(SOURCE_COUNT GREATER 0)
    add_library(Core MODULE ${CORE_SOURCES})
    # Module definition file for ordinal-accurate exports matching retail Core.dll.
    if(EXISTS ${CORE_SRC_DIR}/Core.def)
        target_sources(Core PRIVATE ${CORE_SRC_DIR}/Core.def)
    endif()
    target_compile_definitions(Core PRIVATE
        CORE_API=__declspec\(dllexport\)
        ThisPackage=Core
    )
    target_include_directories(Core PRIVATE
        ${CORE_SRC_DIR}
        ${CSDK_CORE_INC}
        ${UT99_CORE_INC}
    )
    # Core links only against Windows system libraries
    target_link_libraries(Core
        kernel32 user32 advapi32
    )
else()
    message(STATUS "Core: no source files yet — skipping")
endif()
