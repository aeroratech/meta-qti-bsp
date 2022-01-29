#Below Package is fetch from CAF 
SRC_URI = "git://source.codeaurora.org/quic/le/e2fsprogs.git;branch=ext2/master;protocol=https"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://remove.ldconfig.call.patch \
           file://run-ptest \
           file://ptest.patch \
           file://mkdir_p.patch \
           file://0001-configure.ac-correct-AM_GNU_GETTEXT.patch \
           file://0001-intl-do-not-try-to-use-gettext-defines-that-no-longe.patch \
           "
