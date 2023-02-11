vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ThePhD/sol2
    REF 4de99c5b41b64b7e654bf8e48b177e8414a756b7 #v3.3.0 patch 2
    SHA512 84fca431e7680ad82957dfcdf049e0970d03da5aedbc83f35c82a4407a8fb2dfc2e5f6d36e108a36a496ce0c22d23a660feace1047fb8a2b9baf416600686a8c
    HEAD_REF develop
    PATCHES
        fix-namespace.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/sol2)

file(
    REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/debug"
        "${CURRENT_PACKAGES_DIR}/lib"
        "${CURRENT_PACKAGES_DIR}/include"
)

file(INSTALL "${SOURCE_PATH}/include/sol" DESTINATION "${CURRENT_PACKAGES_DIR}/include/")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_fixup_pkgconfig()
