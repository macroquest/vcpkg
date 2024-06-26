vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zeromq/zyre
    REF 1b5962436c3e32705cb7f07cf1b83ff49770abb7
    SHA512 d460a29ec72b38e98187ed45422da43433b5fd337a295f3ca9df3d350f0d8bf9de85cfcb84fd54fc6818fe778ee0ba12e84aee62a015b6e9d0396a534cb1b9aa
    HEAD_REF master
)

configure_file(
    "${CMAKE_CURRENT_LIST_DIR}/Config.cmake.in"
    "${SOURCE_PATH}/builds/cmake/Config.cmake.in"
    COPYONLY
)

foreach(_cmake_module Findczmq.cmake Findlibzmq.cmake)
    configure_file(
        "${CMAKE_CURRENT_LIST_DIR}/${_cmake_module}"
        "${SOURCE_PATH}/${_cmake_module}"
        COPYONLY
    )
endforeach()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" ZYRE_BUILD_SHARED)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" ZYRE_BUILD_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DZYRE_BUILD_SHARED=${ZYRE_BUILD_SHARED}
        -DZYRE_BUILD_STATIC=${ZYRE_BUILD_STATIC}
        -DENABLE_DRAFTS=OFF
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

if(EXISTS "${CURRENT_PACKAGES_DIR}/CMake")
    vcpkg_cmake_config_fixup(CONFIG_PATH CMake)
elseif(EXISTS "${CURRENT_PACKAGES_DIR}/share/cmake/${PORT}")
    vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/${PORT})
endif()

file(COPY
    "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)

vcpkg_copy_tools(TOOL_NAMES zpinger AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(ZYRE_BUILD_STATIC)
    vcpkg_replace_string(
        "${CURRENT_PACKAGES_DIR}/include/zyre_library.h"
        "if defined ZYRE_STATIC"
        "if 1 //if defined ZYRE_STATIC"
    )
endif()

# Handle copyright
configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)

vcpkg_fixup_pkgconfig()
