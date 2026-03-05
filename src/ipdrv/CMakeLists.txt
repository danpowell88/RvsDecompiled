# IpDrv.dll — TCP/IP networking driver, GameSpy integration
# Phase 4 target. Depends on Core, Engine.

set(IPDRV_SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR})

file(GLOB_RECURSE IPDRV_SOURCES
    ${IPDRV_SRC_DIR}/*.cpp
    ${IPDRV_SRC_DIR}/*.h
)

list(LENGTH IPDRV_SOURCES SOURCE_COUNT)
if(SOURCE_COUNT GREATER 0)
    add_library(IpDrv MODULE ${IPDRV_SOURCES})
    target_compile_definitions(IpDrv PRIVATE IPDRV_EXPORTS ThisPackage=IpDrv)
    target_include_directories(IpDrv PRIVATE ${IPDRV_SRC_DIR})
    target_link_libraries(IpDrv Core_Dep Engine_Dep ws2_32)
else()
    message(STATUS "IpDrv: no source files yet — skipping")
endif()
