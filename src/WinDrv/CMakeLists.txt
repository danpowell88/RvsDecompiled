# WinDrv.dll — Windows viewport, DirectInput keyboard/mouse/joystick
# Phase 5 target. Depends on Core, Engine, Window, DirectInput 8.
# 2 UObject classes: UWindowsViewport, UWindowsClient
# 1 plain class: WWindowsViewportWindow
# 89 ordinal exports.

set(WINDRV_SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR})

file(GLOB_RECURSE WINDRV_SOURCES
    ${WINDRV_SRC_DIR}/Inc/*.h
    ${WINDRV_SRC_DIR}/Src/*.cpp
)

list(LENGTH WINDRV_SOURCES SOURCE_COUNT)
if(SOURCE_COUNT GREATER 0)
    add_library(WinDrv MODULE ${WINDRV_SOURCES} ${WINDRV_SRC_DIR}/Src/WinDrv.def)
    target_compile_definitions(WinDrv PRIVATE WINDRV_EXPORTS ThisPackage=WinDrv)
    set(WINDOW_BUILT_LIB ${CMAKE_BINARY_DIR}/src/Window/Release/Window.lib)
    target_include_directories(WinDrv BEFORE PRIVATE
        ${WINDRV_SRC_DIR}/Inc
        ${PROJECT_SOURCE_DIR}/src/Engine/Inc
        ${DXSDK_INCLUDE}
    )
    target_link_libraries(WinDrv
        Core_Dep Engine_Dep
        ${WINDOW_BUILT_LIB}
        ${DXSDK_LIB}/dinput8.lib
        ${DXSDK_LIB}/dxguid.lib
        user32 gdi32
    )
    # dinput8.lib (legacy DX SDK) is not SAFESEH-compatible; disable the check for this target.
    target_link_options(WinDrv PRIVATE /SAFESEH:NO)
    add_dependencies(WinDrv Window)
else()
    message(STATUS "WinDrv: no source files yet — skipping")
endif()
