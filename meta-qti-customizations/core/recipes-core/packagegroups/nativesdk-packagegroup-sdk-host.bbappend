# Limit QTI eSDK only to following nativesdk packages.
# There is no qemu support.

RDEPENDS_${PN}_qti-distro-base = "\
    nativesdk-pkgconfig \
    nativesdk-pseudo \
    nativesdk-unfs3 \
    nativesdk-opkg \
    nativesdk-libtool \
    nativesdk-autoconf \
    nativesdk-automake \
    nativesdk-shadow \
    nativesdk-makedevs \
    nativesdk-cmake \
    nativesdk-meson \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'nativesdk-wayland', '', d)} \
    nativesdk-sdk-provides-dummy \
    ${@bb.utils.contains('DISTRO_FEATURES_NATIVESDK', 'dm-verity-initramfs-v4', 'nativesdk-avbtool', '', d)} \
    "
