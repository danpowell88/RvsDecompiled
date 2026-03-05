# RavenShield.exe — Game launcher / bootstrap
# Phase 8 target. Depends on Core, Engine.

set(LAUNCH_SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR})

file(GLOB_RECURSE LAUNCH_SOURCES
    ${LAUNCH_SRC_DIR}/*.cpp
    ${LAUNCH_SRC_DIR}/*.h
    ${LAUNCH_SRC_DIR}/*.rc
)

list(LENGTH LAUNCH_SOURCES SOURCE_COUNT)
if(SOURCE_COUNT GREATER 0)
    add_executable(RavenShield WIN32 ${LAUNCH_SOURCES})
    target_compile_definitions(RavenShield PRIVATE ThisPackage=Launch)
    target_include_directories(RavenShield PRIVATE ${LAUNCH_SRC_DIR})
    target_link_libraries(RavenShield
        Core_Dep Engine_Dep
        user32 kernel32 advapi32
    )
else()
    message(STATUS "RavenShield (launch): no source files yet — skipping")
endif()
