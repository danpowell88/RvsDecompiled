# Engine.dll — Actor framework, rendering, physics, networking
# Phase 3 target. Depends on Core.

set(ENGINE_SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR})

file(GLOB_RECURSE ENGINE_SOURCES
    ${ENGINE_SRC_DIR}/Inc/*.h
    ${ENGINE_SRC_DIR}/Src/*.cpp
)

list(LENGTH ENGINE_SOURCES SOURCE_COUNT)
if(SOURCE_COUNT GREATER 0)
    add_library(Engine SHARED ${ENGINE_SOURCES})
    # Module definition file for ordinal-accurate exports matching retail Engine.dll.
    if(EXISTS ${ENGINE_SRC_DIR}/Src/Engine.def)
        target_sources(Engine PRIVATE ${ENGINE_SRC_DIR}/Src/Engine.def)
    endif()
    target_compile_definitions(Engine PRIVATE
        ENGINE_API=__declspec\(dllexport\)
        ThisPackage=Engine
    )
    # BEFORE ensures src/Engine/Inc/ shim headers override conflicting UT99/CSDK headers.
    target_include_directories(Engine BEFORE PRIVATE
        ${ENGINE_SRC_DIR}/Inc
    )
    target_link_libraries(Engine Core_Dep MeSDK)
    # Force linker to retain internal helper thunks needed for parity checking.
    # These functions have no callers in our source yet but must survive /OPT:REF.
    target_link_options(Engine PRIVATE
        "/include:?FUN_103012b0@@YAPAXK@Z"
        "/include:?FUN_103012d0@@YAXPAX@Z"
    )
    add_impl_verification(Engine ${ENGINE_SRC_DIR}/Src)
else()
    message(STATUS "Engine: no source files yet — skipping")
endif()
