# Engine.dll — Actor framework, rendering, physics, networking
# Phase 3 target. Depends on Core.

set(ENGINE_SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR})

file(GLOB_RECURSE ENGINE_SOURCES
    ${ENGINE_SRC_DIR}/*.cpp
    ${ENGINE_SRC_DIR}/*.h
)

list(LENGTH ENGINE_SOURCES SOURCE_COUNT)
if(SOURCE_COUNT GREATER 0)
    add_library(Engine MODULE ${ENGINE_SOURCES})
    target_compile_definitions(Engine PRIVATE
        ENGINE_API=__declspec\(dllexport\)
        ThisPackage=Engine
    )
    target_include_directories(Engine PRIVATE
        ${ENGINE_SRC_DIR}
        ${UT99_ENGINE_INC}
    )
    target_link_libraries(Engine Core_Dep)
else()
    message(STATUS "Engine: no source files yet — skipping")
endif()
