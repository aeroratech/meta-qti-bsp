inherit autotools-brokensep pkgconfig

DESCRIPTION = "Build Android liblog"
HOMEPAGE = "http://developer.android.com/"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=89aea4e17d99a7cacdbeed46a0096b10"

PR = "r1"

FILESPATH =+ "${WORKSPACE}/system/core/:"
SRC_URI   = "file://liblog \
             file://include"

S = "${WORKDIR}/liblog"

BBCLASSEXTEND = "native"

EXTRA_OECONF += " --disable-static"
EXTRA_OECONF_append_class-target = " --with-logd-logging"
EXTRA_OECONF += "${@bb.utils.contains('CLASSOVERRIDE', 'class-target', '--with-class-target', '',d)}"
