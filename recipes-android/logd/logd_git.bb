inherit autotools pkgconfig

DESCRIPTION = "Android logd daemon"
HOMEPAGE = "http://developer.android.com/"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=89aea4e17d99a7cacdbeed46a0096b10"

FILESEXTRAPATHS_prepend := "${WORKSPACE}/system/core/:"
SRC_URI = "file://logd"

S = "${WORKDIR}/logd"

DEPENDS += "libbase libutils libcutils libsysutils liblog"

EXTRA_OECONF = " --with-core-includes=${WORKSPACE}/system/core/include"
