# RavenShield.exe — Game launcher / bootstrap
# Phase 8 target. Depends on Core, Engine, Window.
#
# The launcher is a Win32 executable that initialises Core subsystems (memory,
# logging, file I/O), creates the game engine, shows a splash screen + log
# window, and runs the main tick/message pump loop.  It exports GPackage and
# hInstance so DLLs loaded at runtime can find them.

set(LAUNCH_SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR})
set(WINDOW_BUILT_LIB ${CMAKE_BINARY_DIR}/src/Window/Release/Window.lib)

file(GLOB_RECURSE LAUNCH_SOURCES
    ${LAUNCH_SRC_DIR}/Inc/*.h
    ${LAUNCH_SRC_DIR}/Src/*.cpp
    ${LAUNCH_SRC_DIR}/Src/*.rc
)

list(LENGTH LAUNCH_SOURCES SOURCE_COUNT)
if(SOURCE_COUNT GREATER 0)
    add_executable(RavenShield WIN32 ${LAUNCH_SOURCES})
    if(EXISTS ${LAUNCH_SRC_DIR}/Src/RavenShield.def)
        target_sources(RavenShield PRIVATE ${LAUNCH_SRC_DIR}/Src/RavenShield.def)
        target_link_options(RavenShield PRIVATE "/DEF:${LAUNCH_SRC_DIR}/Src/RavenShield.def")
    endif()
    target_compile_definitions(RavenShield PRIVATE
        ThisPackage=Launch
        GTimestamp=GTimestampLaunch
    )

    # BEFORE so our local headers beat global SDK paths.
    # Include paths needed:
    #   src/Launch/Inc       — LaunchPrivate.h, FMallocWindows.h
    #   src/Launch/Src       — Res/LaunchRes.h (resource header)
    #   src/Engine/Inc       — EngineClasses.h (our reconstructed engine headers)
    #   sdk/.../Window/Inc   — Window.h framework (relative includes resolve from here)
    target_include_directories(RavenShield BEFORE PRIVATE
        ${LAUNCH_SRC_DIR}/Inc
        ${LAUNCH_SRC_DIR}/Src
        ${PROJECT_SOURCE_DIR}/src/Engine/Inc
        ${PROJECT_SOURCE_DIR}/sdk/Ut99PubSrc/Window/Inc
    )

    target_link_libraries(RavenShield
        Core_Dep Engine_Dep
        ${WINDOW_BUILT_LIB}
        user32 gdi32 kernel32 advapi32
        comctl32 comdlg32 shell32
    )
    add_dependencies(RavenShield Window)
else()
    message(STATUS "RavenShield (launch): no source files yet — skipping")
endif()
