inherit autotools pkgconfig

DESCRIPTION = "Android audio utilities library"
HOMEPAGE = "http://developer.android.com/"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=89aea4e17d99a7cacdbeed46a0096b10"

DEPENDS += "libcutils media-headers"

FILESPATH =+ "${WORKSPACE}/frameworks/:"
SRC_URI   = "file://audio_utils/"

S = "${WORKDIR}/audio_utils"

