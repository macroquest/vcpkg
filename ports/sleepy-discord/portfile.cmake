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
    REF 0f090ffc883dd7f0212969c5bed9c2b1699b2a38
    SHA512 508e0914c3697f3ded72d6ff4ec890e4b00f308689e3664fb430fb377a3eb0d97c4169d0c648d6441102e21fa97033011657140e02a7d021192ec557077d016a
    HEAD_REF master
    PATCHES
        "0001-CMakeLists.patch"
        "0002-sleepy-discord-CMakeLists.patch"
        "MQ2Discord-0001-Rate-Limit-Check.patch"
        "MQ2Discord-0002-Add-Polling.patch"
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -DAUTO_DOWNLOAD_LIBRARY=OFF -DUSE_VCPKG_LIBS=ON -DSLEEPY_DISCORD_VERSION_BUILD="685" -DSLEEPY_DISCORD_VERSION_BRANCH="master" -DSLEEPY_DISCORD_VERSION_IS_MASTER="1" -DSLEEPY_DISCORD_VERSION_HASH="0f090ffc883dd7f0212969c5bed9c2b1699b2a38" -DSLEEPY_DISCORD_VERSION_DESCRIPTION="0f090ff"
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE.md ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
