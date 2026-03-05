# Window.dll — Window management subsystem
# Phase 4 target. Depends on Core, Engine.

set(WINDOW_SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR})

file(GLOB_RECURSE WINDOW_SOURCES
    ${WINDOW_SRC_DIR}/*.cpp
    ${WINDOW_SRC_DIR}/*.h
)

list(LENGTH WINDOW_SOURCES SOURCE_COUNT)
if(SOURCE_COUNT GREATER 0)
    add_library(Window MODULE ${WINDOW_SOURCES})
    target_compile_definitions(Window PRIVATE WINDOW_EXPORTS ThisPackage=Window)
    target_include_directories(Window PRIVATE ${WINDOW_SRC_DIR})
    target_link_libraries(Window Core_Dep Engine_Dep user32 gdi32)
else()
    message(STATUS "Window: no source files yet — skipping")
endif()
