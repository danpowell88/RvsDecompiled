# Window.dll — Window management subsystem (GUI framework)
# Phase 4 target. Depends on Core, Engine.
# 45+ W*/F* classes, 1 UObject (UWindowManager), 1047 ordinal exports.

set(WINDOW_SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR})

file(GLOB_RECURSE WINDOW_SOURCES
    ${WINDOW_SRC_DIR}/*.cpp
    ${WINDOW_SRC_DIR}/*.h
)

list(LENGTH WINDOW_SOURCES SOURCE_COUNT)
if(SOURCE_COUNT GREATER 0)
    add_library(Window MODULE ${WINDOW_SOURCES} ${WINDOW_SRC_DIR}/Window.def)
    target_compile_definitions(Window PRIVATE WINDOW_EXPORTS ThisPackage=Window)
    # BEFORE so src/window/ shim headers beat UT99 headers if needed.
    # The UT99 Window/Inc path lets Window.h's relative includes resolve:
    #   ..\Src\Res\WindowRes.h  and  ..\..\core\inc\unmsg.h
    # BEFORE ensures src/engine/ and src/window/ shim headers beat global UT99 paths.
    # The UT99 Window/Inc path lets Window.h's relative includes resolve:
    #   ..\Src\Res\WindowRes.h  and  ..\..\core\inc\unmsg.h
    target_include_directories(Window BEFORE PRIVATE
        ${WINDOW_SRC_DIR}
        ${PROJECT_SOURCE_DIR}/src/engine
        ${PROJECT_SOURCE_DIR}/sdk/Ut99PubSrc/Window/Inc
    )
    target_link_libraries(Window
        Core_Dep Engine_Dep
        user32 gdi32 comctl32 comdlg32 shell32 advapi32
    )
else()
    message(STATUS "Window: no source files yet — skipping")
endif()
