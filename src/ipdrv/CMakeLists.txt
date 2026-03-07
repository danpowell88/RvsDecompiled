# IpDrv.dll — TCP/IP networking driver
# Phase 4 target. Depends on Core, Engine.
# 5 main classes + 5 commandlet/download autoclasses, 161 ordinal exports.
# 26 IMPLEMENT_FUNCTION native registrations, 8 AUTOGENERATE_NAME tokens.

set(IPDRV_SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR})

file(GLOB_RECURSE IPDRV_SOURCES
    ${IPDRV_SRC_DIR}/*.cpp
    ${IPDRV_SRC_DIR}/*.h
)

list(LENGTH IPDRV_SOURCES SOURCE_COUNT)
if(SOURCE_COUNT GREATER 0)
    add_library(IpDrv MODULE ${IPDRV_SOURCES} ${IPDRV_SRC_DIR}/IpDrv.def)
    target_compile_definitions(IpDrv PRIVATE IPDRV_EXPORTS ThisPackage=IpDrv)
    target_include_directories(IpDrv BEFORE PRIVATE
        ${IPDRV_SRC_DIR}
        ${PROJECT_SOURCE_DIR}/src/engine
    )
    target_link_libraries(IpDrv Core_Dep Engine_Dep ws2_32)
else()
    message(STATUS "IpDrv: no source files yet — skipping")
endif()
