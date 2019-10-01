inherit autotools pkgconfig

DESCRIPTION = "audio route"
HOMEPAGE = "http://developer.android.com/"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=89aea4e17d99a7cacdbeed46a0096b10"

DEPENDS += "expat liblog tinyalsa"

FILESPATH =+ "${WORKSPACE}/frameworks/:"
SRC_URI   = "file://audio_route/"

S = "${WORKDIR}/audio_route"

#EXTRA_OECONF += " --with-glib"
