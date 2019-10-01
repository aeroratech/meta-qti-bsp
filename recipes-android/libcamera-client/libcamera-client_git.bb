inherit autotools pkgconfig

DESCRIPTION = "Android libcamera_client library"
HOMEPAGE = "http://developer.android.com/"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=89aea4e17d99a7cacdbeed46a0096b10"

DEPENDS += "binder camera-metadata liblog libutils"

FILESPATH =+ "${WORKSPACE}/frameworks/:"
SRC_URI   = "file://libcamera_client/"

S = "${WORKDIR}/libcamera_client"

CPPFLAGS += "-I${STAGING_INCDIR}/camera"
