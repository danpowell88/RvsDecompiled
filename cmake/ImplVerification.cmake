# ImplVerification.cmake — Helper function to wire IMPL_xxx attribution checks
# into a module's build.
#
# Usage (inside a module's CMakeLists.txt, after the target is defined):
#
#   include(${PROJECT_SOURCE_DIR}/cmake/ImplVerification.cmake)
#   add_impl_verification(Engine ${CMAKE_CURRENT_SOURCE_DIR}/Src)
#
# When IMPL_STRICT is OFF (default), issues are warnings and the build
# continues. Set IMPL_STRICT=ON via cmake -DIMPL_STRICT=ON to fail on any
# missing or IMPL_TODO attribution.
# =============================================================================

function(add_impl_verification TARGET_NAME SRC_DIR)
    find_package(Python3 QUIET COMPONENTS Interpreter)
    if(NOT Python3_FOUND)
        message(STATUS "${TARGET_NAME}: Python3 not found — IMPL_xxx check skipped")
        return()
    endif()

    if(NOT TARGET ${TARGET_NAME})
        message(STATUS "${TARGET_NAME}: target not defined — IMPL_xxx check skipped")
        return()
    endif()

    if(NOT IS_DIRECTORY "${SRC_DIR}")
        return()
    endif()

    set(VERIFY_SCRIPT "${PROJECT_SOURCE_DIR}/tools/verify_impl_sources.py")
    if(NOT EXISTS "${VERIFY_SCRIPT}")
        message(STATUS "${TARGET_NAME}: verify_impl_sources.py not found — check skipped")
        return()
    endif()

    if(IMPL_STRICT)
        set(_warn_flag "")
    else()
        set(_warn_flag "--warn-only")
    endif()

    add_custom_command(TARGET ${TARGET_NAME} PRE_BUILD
        COMMAND ${Python3_EXECUTABLE}
            "${VERIFY_SCRIPT}"
            "${SRC_DIR}"
            ${_warn_flag}
        COMMENT "Verifying ${TARGET_NAME} IMPL_xxx attributions..."
        VERBATIM
    )
endfunction()
