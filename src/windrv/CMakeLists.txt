# WinDrv.dll — Windows viewport, DirectInput keyboard/mouse/joystick
# Phase 5 target. Depends on Core, Engine, Window, DirectInput 8.
# 2 UObject classes: UWindowsViewport, UWindowsClient
# 1 plain class: WWindowsViewportWindow
# 89 ordinal exports.

set(WINDRV_SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR})

file(GLOB_RECURSE WINDRV_SOURCES
    ${WINDRV_SRC_DIR}/*.cpp
    ${WINDRV_SRC_DIR}/*.h
)

list(LENGTH WINDRV_SOURCES SOURCE_COUNT)
if(SOURCE_COUNT GREATER 0)
    add_library(WinDrv MODULE ${WINDRV_SOURCES} ${WINDRV_SRC_DIR}/WinDrv.def)
    target_compile_definitions(WinDrv PRIVATE WINDRV_EXPORTS ThisPackage=WinDrv)
    target_include_directories(WinDrv BEFORE PRIVATE
        ${WINDRV_SRC_DIR}
        ${PROJECT_SOURCE_DIR}/src/engine
        ${DXSDK_INCLUDE}
    )
    target_link_libraries(WinDrv
        Core_Dep Engine_Dep
        ${CSDK_LIB}/Window.lib
        ${DXSDK_LIB}/dinput8.lib
        ${DXSDK_LIB}/dxguid.lib
        user32 gdi32
    )
else()
    message(STATUS "WinDrv: no source files yet — skipping")
endif()
