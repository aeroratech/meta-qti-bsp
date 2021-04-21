inherit autotools pkgconfig

DESCRIPTION = "Build Android libcutils"
HOMEPAGE = "http://developer.android.com/"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=89aea4e17d99a7cacdbeed46a0096b10"

PR = "r1"

DEPENDS += "liblog"

BBCLASSEXTEND = "native"

FILESPATH =+ "${WORKSPACE}/system/core/:"
SRC_URI   = "file://libcutils \
             file://include "

S = "${WORKDIR}/libcutils"

EXTRA_OECONF += "\
            --with-host-os=${HOST_OS} \
            --disable-static \
            ${@bb.utils.contains('MACHINE_FEATURES', 'qti-sdx', '', '--enable-leproperties', d)} \
"
