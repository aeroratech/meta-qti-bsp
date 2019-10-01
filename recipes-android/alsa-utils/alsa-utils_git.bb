inherit autotools pkgconfig

DESCRIPTION = "Android alsa utilities"

HOMEPAGE = "http://developer.android.com/"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=89aea4e17d99a7cacdbeed46a0096b10"

DEPENDS += "audio-utils glib-2.0 liblog media-headers tinyalsa"

FILESPATH =+ "${WORKSPACE}/frameworks/system/media/:"
SRC_URI   = "file://alsa_utils/"

S = "${WORKDIR}/alsa_utils"

EXTRA_OECONF += " --with-glib"

SOLIBS = ".so"
FILES_SOLIBSDEV = ""
