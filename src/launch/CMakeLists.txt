# RavenShield.exe — Game launcher / bootstrap
# Phase 8 target. Depends on Core, Engine, Window.
#
# The launcher is a Win32 executable that initialises Core subsystems (memory,
# logging, file I/O), creates the game engine, shows a splash screen + log
# window, and runs the main tick/message pump loop.  It exports GPackage and
# hInstance so DLLs loaded at runtime can find them.

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

    # BEFORE so our local headers beat global SDK paths.
    # Include paths needed:
    #   src/launch           — LaunchPrivate.h
    #   src/engine           — EngineClasses.h (our reconstructed engine headers)
    #   sdk/.../Window/Inc   — Window.h framework (relative includes resolve from here)
    target_include_directories(RavenShield BEFORE PRIVATE
        ${LAUNCH_SRC_DIR}
        ${PROJECT_SOURCE_DIR}/src/engine
        ${PROJECT_SOURCE_DIR}/sdk/Ut99PubSrc/Window/Inc
    )

    target_link_libraries(RavenShield
        Core_Dep Engine_Dep
        ${CSDK_LIB}/Window.lib
        user32 gdi32 kernel32 advapi32
        comctl32 comdlg32 shell32
    )
else()
    message(STATUS "RavenShield (launch): no source files yet — skipping")
endif()
