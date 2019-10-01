inherit autotools pkgconfig

DESCRIPTION = "Common multimedia headers installation"

HOMEPAGE = "http://developer.android.com/"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=89aea4e17d99a7cacdbeed46a0096b10"

FILESPATH =+ "${WORKSPACE}/frameworks/:"
SRC_URI = "file://include/media"

S = "${WORKDIR}/include/media"

do_compile[noexec] = "1"
