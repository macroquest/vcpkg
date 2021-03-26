vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zeromq/libzmq
    REF 4dd504abebf3eb944d0554c36d490fb2bb742e4f
    SHA512 cf0d81692744a66b1b318fc86d617e0c4dbd74801b34a9b526f1a475dda1e4b1b303ffcdb35f698e5c2bc796de358f8608c82dbc8d5ba8128ec01e1fd04537a5
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        sodium WITH_LIBSODIUM
        draft ENABLE_DRAFTS
    INVERTED_FEATURES
        websockets-sha1 DISABLE_WS
)

set(PLATFORM_OPTIONS)
if(VCPKG_TARGET_IS_MINGW)
    set(PLATFORM_OPTIONS "-DCMAKE_SYSTEM_VERSION=6.0")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DZMQ_BUILD_TESTS=OFF
        -DPOLLER=epoll
        -DBUILD_STATIC=${BUILD_STATIC}
        -DBUILD_SHARED=${BUILD_SHARED}
        -DWITH_PERF_TOOL=OFF
        -DWITH_DOCS=OFF
        -DWITH_NSS=OFF
        ${FEATURE_OPTIONS}
        ${PLATFORM_OPTIONS}
    OPTIONS_DEBUG
        "-DCMAKE_PDB_OUTPUT_DIRECTORY=${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg"
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

if(EXISTS ${CURRENT_PACKAGES_DIR}/CMake)
    vcpkg_fixup_cmake_targets(CONFIG_PATH CMake)
endif()
if(EXISTS ${CURRENT_PACKAGES_DIR}/share/cmake/ZeroMQ)
    vcpkg_fixup_cmake_targets(CONFIG_PATH share/cmake/ZeroMQ)
endif()

file(COPY
    ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/zmq.h
        "defined ZMQ_STATIC"
        "1 //defined ZMQ_STATIC"
    )
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

# Handle copyright
file(RENAME ${CURRENT_PACKAGES_DIR}/share/zmq/COPYING.LESSER.txt ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share ${CURRENT_PACKAGES_DIR}/share/zmq)
