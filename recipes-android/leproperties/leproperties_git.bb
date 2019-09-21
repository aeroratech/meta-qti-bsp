inherit autotools pkgconfig

DESCRIPTION = "Andorid like properties managment for LE"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=89aea4e17d99a7cacdbeed46a0096b10"

FILESEXTRAPATHS_prepend := "${WORKSPACE}/system/core/:"
SRC_URI = "file://leproperties"

S = "${WORKDIR}/leproperties"

DEPENDS += "libselinux libcutils liblog"
