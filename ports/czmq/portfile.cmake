vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zeromq/czmq
    REF 614572bf207dc89b35f2ef19c698b5d51861dd0b
    SHA512 9a71c3bb9a5d472f72ac9923f27fed9fc461eb569c8aa26166f4d19a34de43f4e3577de023f18fd4db207f0b8f09b88a267eeb02c25410bde873d1d74f4b66b7
    HEAD_REF master
    PATCHES
        fix-dependencies.patch
)

foreach(_cmake_module
    Findlibcurl.cmake
    Findlibmicrohttpd.cmake
    Findlibzmq.cmake
    Findlz4.cmake
    Finduuid.cmake
)
    configure_file(
        ${CMAKE_CURRENT_LIST_DIR}/${_cmake_module}
        ${SOURCE_PATH}/${_cmake_module}
        COPYONLY
    )
endforeach()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    draft   ENABLE_DRAFTS
    curl    CZMQ_WITH_LIBCURL
    httpd   CZMQ_WITH_LIBMICROHTTPD
    lz4     CZMQ_WITH_LZ4
    uuid    CZMQ_WITH_UUID
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DCZMQ_BUILD_SHARED=${BUILD_SHARED}
        -DCZMQ_BUILD_STATIC=${BUILD_STATIC}
        -DBUILD_TESTING=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

if(EXISTS ${CURRENT_PACKAGES_DIR}/CMake)
    vcpkg_fixup_cmake_targets(CONFIG_PATH CMake)
endif()
if(EXISTS ${CURRENT_PACKAGES_DIR}/share/cmake/${PORT})
    vcpkg_fixup_cmake_targets(CONFIG_PATH share/cmake/${PORT})
endif()

file(COPY
    ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
)

if ("tool" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES zmakecert)
endif()

vcpkg_clean_executables_in_bin(FILE_NAMES zmakecert)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/czmq_library.h
        "if defined CZMQ_STATIC"
        "if 1 //if defined CZMQ_STATIC"
    )
endif()

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
