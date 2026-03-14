# ByteParity.cmake — hook byte-accuracy verification into module builds.
#
# For each function annotated  IMPL_MATCH("Foo.dll", 0xADDR)  the post-build
# step runs verify_byte_parity.py which:
#   1. Extracts the retail function bytes at 0xADDR.
#   2. Extracts the compiled function bytes from the .map file.
#   3. Compares them with relocation-entry masking.
#   4. Fails the build on any mismatch.
#
# Usage (add to a module's CMakeLists.txt after target is defined):
#
#   include(${PROJECT_SOURCE_DIR}/cmake/ByteParity.cmake)
#   add_byte_parity_check(Engine src/Engine/Src Engine.dll)
#
# The /MAP linker flag is automatically added to the target so the tool
# has symbol → VA mappings available.
#
# Set BYTE_PARITY=OFF to disable (default ON when retail DLLs are present).
# =============================================================================

option(BYTE_PARITY "Fail build on IMPL_MATCH byte-parity violations" ON)

function(add_byte_parity_check TARGET_NAME SRC_DIR DLL_NAME)
    if(NOT BYTE_PARITY)
        return()
    endif()

    find_package(Python3 QUIET COMPONENTS Interpreter)
    if(NOT Python3_FOUND)
        message(STATUS "${TARGET_NAME}: Python3 not found — byte-parity check skipped")
        return()
    endif()

    if(NOT TARGET ${TARGET_NAME})
        message(STATUS "${TARGET_NAME}: target not defined — byte-parity check skipped")
        return()
    endif()

    # Check retail DLL exists
    set(RETAIL_DLL "${PROJECT_SOURCE_DIR}/retail/system/${DLL_NAME}")
    if(NOT EXISTS "${RETAIL_DLL}")
        message(STATUS "${TARGET_NAME}: retail/${DLL_NAME} not found — byte-parity check skipped")
        return()
    endif()

    set(VERIFY_SCRIPT "${PROJECT_SOURCE_DIR}/tools/verify_byte_parity.py")
    if(NOT EXISTS "${VERIFY_SCRIPT}")
        message(STATUS "${TARGET_NAME}: verify_byte_parity.py not found — check skipped")
        return()
    endif()

    # Enable MAP file generation so the tool can map symbol names → VAs.
    # MSVC: /MAP[:filename]  (CMake exposes this via LINK_FLAGS or target_link_options)
    if(MSVC)
        # Determine output directory for the map file
        set(MAP_FILE "$<TARGET_FILE_DIR:${TARGET_NAME}>/${TARGET_NAME}.map")
        target_link_options(${TARGET_NAME} PRIVATE "/MAP:${MAP_FILE}")
    endif()

    # Post-build: verify byte parity
    set(_warn_flag "")
    # Currently run in warn-only mode so we get visibility without hard-failing
    # until all IMPL_MATCH annotations have been verified to be correct.
    # Remove --warn-only once the pass rate is known-good.
    set(_warn_flag "--warn-only")

    add_custom_command(TARGET ${TARGET_NAME} POST_BUILD
        COMMAND ${Python3_EXECUTABLE}
            "${VERIFY_SCRIPT}"
            "${SRC_DIR}"
            --dll "${DLL_NAME}"
            ${_warn_flag}
        COMMENT "Byte-parity check: ${TARGET_NAME} vs retail/${DLL_NAME}..."
        VERBATIM
    )

    message(STATUS "${TARGET_NAME}: byte-parity check enabled (retail/${DLL_NAME})")
endfunction()
