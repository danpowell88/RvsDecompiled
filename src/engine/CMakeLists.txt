# Engine.dll — Actor framework, rendering, physics, networking
# Phase 3 target. Depends on Core.

set(ENGINE_SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR})

file(GLOB_RECURSE ENGINE_SOURCES
    ${ENGINE_SRC_DIR}/*.cpp
    ${ENGINE_SRC_DIR}/*.h
)
# Exclude .bak backup files picked up by GLOB_RECURSE.
list(FILTER ENGINE_SOURCES EXCLUDE REGEX "\\.bak$")

list(LENGTH ENGINE_SOURCES SOURCE_COUNT)
if(SOURCE_COUNT GREATER 0)
    add_library(Engine MODULE ${ENGINE_SOURCES})
    # Module definition file for ordinal-accurate exports matching retail Engine.dll.
    if(EXISTS ${ENGINE_SRC_DIR}/Engine.def)
        target_sources(Engine PRIVATE ${ENGINE_SRC_DIR}/Engine.def)
    endif()
    target_compile_definitions(Engine PRIVATE
        ENGINE_API=__declspec\(dllexport\)
        ThisPackage=Engine
    )
    # BEFORE ensures src/engine/ shim headers override conflicting UT99/CSDK headers.
    target_include_directories(Engine BEFORE PRIVATE
        ${ENGINE_SRC_DIR}
    )
    target_link_libraries(Engine Core_Dep)
    # Allow duplicate symbol definitions from compiler-generated virtual destructors
    # across multiple translation units that include the same class definitions.
    target_link_options(Engine PRIVATE /FORCE:MULTIPLE)
else()
    message(STATUS "Engine: no source files yet — skipping")
endif()
