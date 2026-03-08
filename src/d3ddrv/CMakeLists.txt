# D3DDrv.dll — Direct3D 8 rendering driver
# Phase 5 target. Depends on Core, Engine, DirectX 8 SDK.
# 1 UObject class: UD3DRenderDevice
# 44 ordinal exports.

set(D3DDRV_SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR})

file(GLOB_RECURSE D3DDRV_SOURCES
    ${D3DDRV_SRC_DIR}/Inc/*.h
    ${D3DDRV_SRC_DIR}/Src/*.cpp
)

list(LENGTH D3DDRV_SOURCES SOURCE_COUNT)
if(SOURCE_COUNT GREATER 0)
    add_library(D3DDrv MODULE ${D3DDRV_SOURCES} ${D3DDRV_SRC_DIR}/Src/D3DDrv.def)
    target_compile_definitions(D3DDrv PRIVATE D3DDRV_EXPORTS ThisPackage=D3DDrv)
    target_include_directories(D3DDrv BEFORE PRIVATE
        ${D3DDRV_SRC_DIR}/Inc
        ${PROJECT_SOURCE_DIR}/src/engine/Inc
        ${DXSDK_INCLUDE}
    )
    target_link_libraries(D3DDrv
        Core_Dep Engine_Dep
        ${DXSDK_LIB}/d3d8.lib
        ${DXSDK_LIB}/d3dx8.lib
        ${DXSDK_LIB}/dxguid.lib
        ddraw.lib
    )
else()
    message(STATUS "D3DDrv: no source files yet — skipping")
endif()
