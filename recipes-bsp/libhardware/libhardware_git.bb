inherit autotools pkgconfig

DESCRIPTION = "hardware libhardware headers"
HOMEPAGE = "http://codeaurora.org/"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=89aea4e17d99a7cacdbeed46a0096b10"

FILESPATH =+ "${WORKSPACE}:"
SRC_URI   = "file://hardware/libhardware/"
S = "${WORKDIR}/hardware/libhardware"

PR = "r6"

DEPENDS += "libcutils liblog system-core"

# Set PACKAGECONFIG ?= "${@bb.utils.contains('COMBINED_FEATURES', 'qti-audio', 'aosp-audio', '', d)} ..."
# to activate extra oe conf options.
PACKAGECONFIG ?= "\
        ${@bb.utils.contains('COMBINED_FEATURES', 'qti-audio', 'aosp-audio', '', d)} \
        ${@bb.utils.contains('COMBINED_FEATURES', 'qti-camera', 'aosp-camera', '', d)} \
        ${@bb.utils.contains('COMBINED_FEATURES', 'qti-display', 'aosp-display', '', d)} \
        ${@bb.utils.contains('COMBINED_FEATURES', 'qti-location', 'aosp-location', '', d)} \
        ${@bb.utils.contains('COMBINED_FEATURES', 'qti-sensors', 'aosp-sensors', '', d)} \
"

PACKAGECONFIG[aosp-audio]    = "--enable-audio, --disable-audio"
PACKAGECONFIG[aosp-camera]   = "--enable-camera, --disable-camera"
PACKAGECONFIG[aosp-display]  = "--enable-display, --disable-display"
PACKAGECONFIG[aosp-location] = "--enable-location, --disable-location"
PACKAGECONFIG[aosp-sensors]  = "--enable-sensors, --disable-sensors"

PACKAGE_ARCH = "${MACHINE_ARCH}"
