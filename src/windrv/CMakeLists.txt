# WinDrv.dll — Windows viewport, input handling
# Phase 5 target. Depends on Core, Engine.

set(WINDRV_SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR})

file(GLOB_RECURSE WINDRV_SOURCES
    ${WINDRV_SRC_DIR}/*.cpp
    ${WINDRV_SRC_DIR}/*.h
)

list(LENGTH WINDRV_SOURCES SOURCE_COUNT)
if(SOURCE_COUNT GREATER 0)
    add_library(WinDrv MODULE ${WINDRV_SOURCES})
    target_compile_definitions(WinDrv PRIVATE WINDRV_EXPORTS ThisPackage=WinDrv)
    target_include_directories(WinDrv PRIVATE ${WINDRV_SRC_DIR})
    target_link_libraries(WinDrv Core_Dep Engine_Dep user32 gdi32)
else()
    message(STATUS "WinDrv: no source files yet — skipping")
endif()
