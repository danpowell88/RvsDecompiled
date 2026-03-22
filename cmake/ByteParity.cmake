# ByteParity.cmake — byte-accuracy verification for IMPL_MATCH annotations.
#
# Provides a standalone "verify" target that compares rebuilt DLLs against
# retail binaries function-by-function. Run after building:
#
#   nmake verify
#
# The verify target depends on Core and Engine (ensures they are built first),
# then runs verify_byte_parity.py which:
#   1. Scans source for IMPL_MATCH("Foo.dll", 0xADDR) annotations
#   2. Extracts retail function bytes at the given VA
#   3. Extracts rebuilt function bytes via the MSVC .map file
#   4. Compares with relocation-entry masking
#   5. Exits non-zero on any mismatch
#
# /MAP is added globally via cmake/msvc71.cmake so all DLLs produce .map files.
#
# Set BYTE_PARITY=OFF to skip the verify target entirely.
# =============================================================================

option(BYTE_PARITY "Enable the 'verify' byte-parity target" ON)

function(add_byte_parity_target)
    if(NOT BYTE_PARITY)
        message(STATUS "verify: byte-parity target disabled (BYTE_PARITY=OFF)")
        return()
    endif()

    find_package(Python3 QUIET COMPONENTS Interpreter)
    if(NOT Python3_FOUND)
        message(STATUS "verify: Python3 not found — byte-parity target skipped")
        return()
    endif()

    set(VERIFY_SCRIPT "${PROJECT_SOURCE_DIR}/tools/verify_byte_parity.py")
    if(NOT EXISTS "${VERIFY_SCRIPT}")
        message(STATUS "verify: verify_byte_parity.py not found — target skipped")
        return()
    endif()

    # Check at least one retail DLL exists
    set(RETAIL_DIR "${PROJECT_SOURCE_DIR}/retail/system")
    if(NOT EXISTS "${RETAIL_DIR}/Core.dll" AND NOT EXISTS "${RETAIL_DIR}/Engine.dll")
        message(STATUS "verify: no retail DLLs found — byte-parity target skipped")
        return()
    endif()

    # Build the list of DLL targets to depend on (only those that exist)
    set(_deps "")
    foreach(_tgt Core Engine)
        if(TARGET ${_tgt})
            list(APPEND _deps ${_tgt})
        endif()
    endforeach()

    # Create the verify target
    add_custom_target(verify
        COMMAND ${Python3_EXECUTABLE}
            "${VERIFY_SCRIPT}"
            "${PROJECT_SOURCE_DIR}/src"
            --build-dir "${CMAKE_BINARY_DIR}/bin"
            --report "${CMAKE_BINARY_DIR}/parity_report.txt"
        DEPENDS ${_deps}
        COMMENT "Verifying byte-parity: rebuilt DLLs vs retail..."
        VERBATIM
    )

    message(STATUS "verify: byte-parity target enabled (nmake verify)")
endfunction()
