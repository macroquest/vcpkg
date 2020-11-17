include(vcpkg_common_functions)

if ("websocketpp" IN_LIST FEATURES)
    set(USE_WEBSOCKETPP ON)
elseif("uwebsockets" IN_LIST FEATURES)
    set(USE_WEBSOCKETPP OFF)
    set(USE_UWEBSOCKETS ON)
endif()

if ("voice" IN_LIST FEATURES)
    set(USE_LIBOPUS ON)
    set(USE_LISODIUM ON)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yourWaifu/sleepy-discord
    REF 7796a1fd6003eb75511068e0c206aaada6198213
    SHA512 20c88cf2b1cd8492865c3851f4088bffed469eb2dd8a9063f48f1406ee300060d1678a679f524c8f0f5b34065c468b2b954850f16940b74a25c92461cc265b5f
    HEAD_REF master
    PATCHES
        "0001-CMakeLists.patch"
        "0002-sleepy-discord-CMakeLists.patch"
        "MQ2Discord-0001-Rate-Limit-Check.patch"
        "MQ2Discord-0002-Add-Polling.patch"
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -DAUTO_DOWNLOAD_LIBRARY=OFF -DUSE_VCPKG_LIBS=ON -DSLEEPY_DISCORD_VERSION_BUILD="684" -DSLEEPY_DISCORD_VERSION_BRANCH="master" -DSLEEPY_DISCORD_VERSION_IS_MASTER="1" -DSLEEPY_DISCORD_VERSION_HASH="7796a1fd6003eb75511068e0c206aaada6198213" -DSLEEPY_DISCORD_VERSION_DESCRIPTION="7796a1f"
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE.md ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
