inherit autotools pkgconfig

DESCRIPTION = "Android libhardware headers"
HOMEPAGE = "http://codeaurora.org/"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=89aea4e17d99a7cacdbeed46a0096b10"

FILESPATH =+ "${WORKSPACE}/hardware:"
SRC_URI   = "file://libhardware/"

S = "${WORKDIR}/libhardware"

PR = "r7"

DEPENDS += "libcutils libutils liblog system-core-headers"

PACKAGECONFIG ?= "\
        ${@bb.utils.contains('COMBINED_FEATURES', 'qti-audio', 'audio', '', d)} \
        ${@bb.utils.contains('COMBINED_FEATURES', 'qti-camera', 'camera', '', d)} \
        ${@bb.utils.contains('COMBINED_FEATURES', 'qti-display', 'display', '', d)} \
        ${@bb.utils.contains('COMBINED_FEATURES', 'qti-location', 'location', '', d)} \
        ${@bb.utils.contains('COMBINED_FEATURES', 'qti-sensors', 'sensors', '', d)} \
"

PACKAGECONFIG[audio]    = "--enable-audio, --disable-audio"
PACKAGECONFIG[camera]   = "--enable-camera, --disable-camera"
PACKAGECONFIG[display]  = "--enable-display, --disable-display"
PACKAGECONFIG[location] = "--enable-location, --disable-location"
PACKAGECONFIG[sensors]  = "--enable-sensors, --disable-sensors"

PACKAGE_ARCH = "${MACHINE_ARCH}"
