vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://github.com/backtrace-labs/crashpad.git
    REF b51ddfa3119f85cdeaf74af7637b1b0c5042f7c5
    PATCHES
        0001-Add-buildflags-header.patch
)

# backtrace's version is still python2
vcpkg_find_acquire_program(PYTHON2)
vcpkg_replace_string("${SOURCE_PATH}/.gn" "script_executable = \"python3\"" "script_executable = \"${PYTHON2}\"")

function(checkout_in_path PATH_TO_CHECK URL REF)
    if(EXISTS "${PATH_TO_CHECK}")
        file(GLOB FILES "${PATH_TO_CHECK}")
        list(LENGTH FILES COUNT)
        if(COUNT GREATER 1)
            return()
        endif()
        file(REMOVE_RECURSE "${PATH_TO_CHECK}")
    endif()

    vcpkg_from_git(
        OUT_SOURCE_PATH DEP_SOURCE_PATH
        URL "${URL}"
        REF "${REF}"
        PATCHES "${ARGN}"
    )
    file(RENAME "${DEP_SOURCE_PATH}" "${PATH_TO_CHECK}")
    file(REMOVE_RECURSE "${DEP_SOURCE_PATH}")
endfunction()

# mini_chromium contains the toolchains and build configuration
checkout_in_path(
    "${SOURCE_PATH}/third_party/mini_chromium/mini_chromium"
    "https://chromium.googlesource.com/chromium/mini_chromium"
    "822fada4a9972e3e2f36a981da770539025beb0a"
)

function(replace_gn_dependency INPUT_FILE OUTPUT_FILE LIBRARY_NAMES)
    unset(_LIBRARY_DEB CACHE)
    find_library(_LIBRARY_DEB NAMES ${LIBRARY_NAMES}
        PATHS "${CURRENT_INSTALLED_DIR}/debug/lib"
        NO_DEFAULT_PATH)

    if(_LIBRARY_DEB MATCHES "-NOTFOUND")
        message(FATAL_ERROR "Could not find debug library with names: ${LIBRARY_NAMES}")
    endif()

    unset(_LIBRARY_REL CACHE)
    find_library(_LIBRARY_REL NAMES ${LIBRARY_NAMES}
        PATHS "${CURRENT_INSTALLED_DIR}/lib"
        NO_DEFAULT_PATH)

    if(_LIBRARY_REL MATCHES "-NOTFOUND")
        message(FATAL_ERROR "Could not find library with names: ${LIBRARY_NAMES}")
    endif()

    set(_INCLUDE_DIR "${CURRENT_INSTALLED_DIR}/include")

    file(REMOVE "${OUTPUT_FILE}")
    configure_file("${INPUT_FILE}" "${OUTPUT_FILE}" @ONLY)
endfunction()

replace_gn_dependency(
    "${CMAKE_CURRENT_LIST_DIR}/zlib.gn"
    "${SOURCE_PATH}/third_party/zlib/BUILD.gn"
    "z;zlib;zlibd"
)

if (TRIPLET_SYSTEM_ARCH MATCHES "x86")
    set(OPTIONS_ALL "target_cpu=\"x86\"")
else()
    set(OPTIONS_ALL "")
endif()
set(OPTIONS_DBG "is_debug=true")
set(OPTIONS_REL "")

if(CMAKE_HOST_WIN32)
    # Load toolchains
    vcpkg_cmake_get_vars(cmake_vars_file)
    include("${cmake_vars_file}")

    set(OPTIONS_DBG "${OPTIONS_DBG} \
        extra_cflags_c=\"${VCPKG_COMBINED_C_FLAGS_DEBUG}\" \
        extra_cflags_cc=\"${VCPKG_COMBINED_CXX_FLAGS_DEBUG}\" \
        extra_ldflags=\"${VCPKG_COMBINED_SHARED_LINKER_FLAGS_DEBUG}\" \
        extra_arflags=\"${VCPKG_COMBINED_STATIC_LINKER_FLAGS_DEBUG}\"")

    set(OPTIONS_REL "${OPTIONS_REL} \
        extra_cflags_c=\"${VCPKG_COMBINED_C_FLAGS_RELEASE}\" \
        extra_cflags_cc=\"${VCPKG_COMBINED_CXX_FLAGS_RELEASE}\" \
        extra_ldflags=\"${VCPKG_COMBINED_SHARED_LINKER_FLAGS_RELEASE}\" \
        extra_arflags=\"${VCPKG_COMBINED_STATIC_LINKER_FLAGS_RELEASE}\"")

    set(DISABLE_WHOLE_PROGRAM_OPTIMIZATION "\
        extra_cflags=\"/GL-\" \
        extra_ldflags=\"/LTCG:OFF\" \
        extra_arflags=\"/LTCG:OFF\"")

    set(OPTIONS_DBG "${OPTIONS_DBG} ${DISABLE_WHOLE_PROGRAM_OPTIMIZATION}")
    set(OPTIONS_REL "${OPTIONS_REL} ${DISABLE_WHOLE_PROGRAM_OPTIMIZATION}")
endif()

vcpkg_gn_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS " target_cpu=\"${VCPKG_TARGET_ARCHITECTURE}\" "
    OPTIONS_DEBUG "${OPTIONS_DBG}"
    OPTIONS_RELEASE "${OPTIONS_REL}"
)

vcpkg_gn_install(
    SOURCE_PATH "${SOURCE_PATH}"
    TARGETS client client:common util third_party/mini_chromium/mini_chromium/base handler:crashpad_handler
)

message(STATUS "Installing headers...")
set(PACKAGES_INCLUDE_DIR "${CURRENT_PACKAGES_DIR}/include/${PORT}")
function(install_headers DIR)
    file(COPY "${DIR}" DESTINATION "${PACKAGES_INCLUDE_DIR}" FILES_MATCHING PATTERN "*.h")
endfunction()
install_headers("${SOURCE_PATH}/client")
install_headers("${SOURCE_PATH}/util")
install_headers("${SOURCE_PATH}/third_party/mini_chromium/mini_chromium/base")
install_headers("${SOURCE_PATH}/third_party/mini_chromium/mini_chromium/build")

file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/gen/build/chromeos_buildflags.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}/build")
file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/gen/build/chromeos_buildflags.h.flags" DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}/build")
if(VCPKG_TARGET_IS_OSX)
    file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/obj/util/libmig_output.a" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
    file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/obj/util/libmig_output.a" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
endif()

# remove empty directories
file(REMOVE_RECURSE
    "${PACKAGES_INCLUDE_DIR}/util/net/testdata"
    "${PACKAGES_INCLUDE_DIR}/build/ios")

configure_file("${CMAKE_CURRENT_LIST_DIR}/crashpadConfig.cmake.in"
        "${CURRENT_PACKAGES_DIR}/share/${PORT}/crashpadConfig.cmake" @ONLY)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/${PORT}/build/config")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/${PORT}/util/mach/__pycache__")

vcpkg_copy_pdbs()
file(INSTALL "${SOURCE_PATH}/LICENSE"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    RENAME copyright)
