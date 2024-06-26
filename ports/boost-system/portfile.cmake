# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_buildpath_length_warning(37)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/system
    REF boost-${VERSION}
    SHA512 3cfeb0dd282fce5dc3b1a014edb61a3d7f57e9ebcbe541745353c4846226092578421c35085c6dd5671debc42cf11490ef14aa224512dd964c52272a7c13c56f
    HEAD_REF master
    PATCHES
        compat.diff
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
