inherit autotools pkgconfig

DESCRIPTION = "Android libbacktrace library"
HOMEPAGE = "http://developer.android.com/"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=89aea4e17d99a7cacdbeed46a0096b10"

FILESEXTRAPATHS_prepend := "${WORKSPACE}/system/core:"
SRC_URI = "file://libbacktrace"

S = "${WORKDIR}/libbacktrace"

DEPENDS += "libbase libunwind"

EXTRA_OECONF = " \
                --with-glib \
                --with-core-includes=${WORKSPACE}/system/core/include \
               "
