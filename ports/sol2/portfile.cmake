vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ThePhD/sol2
    REF v3.3.1
    SHA512 4404b124a4f331d77459c01a92cd73895301e7d3ef829a0285980f0138b9cc66782de3713d54f017d5aad7d8a11d23eeffbc5f3b39ccb4d4306a955711d385dd
    HEAD_REF develop
    PATCHES fix-namespace.patch
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