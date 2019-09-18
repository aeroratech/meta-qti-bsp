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
SRC_URI   = "file://libcutils"

S = "${WORKDIR}/libcutils"

EXTRA_OECONF += "\
            --with-core-includes=${WORKSPACE}/system/core/include \
            --with-host-os=${HOST_OS} \
            --disable-static \
            --enable-leproperties \
            LE_PROPERTIES_ENABLED=true \
"
