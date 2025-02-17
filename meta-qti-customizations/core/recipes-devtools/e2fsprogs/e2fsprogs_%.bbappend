#Below Package is fetch from Codelinaro
SRC_URI = "${CLO_LE_GIT}/e2fsprogs.git;protocol=https;branch=ext2/master"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://remove.ldconfig.call.patch \
           file://run-ptest \
           file://ptest.patch \
           file://mkdir_p.patch \
           file://0001-configure.ac-correct-AM_GNU_GETTEXT.patch \
           file://0001-intl-do-not-try-to-use-gettext-defines-that-no-longe.patch \
           file://0001-e2fsprogs-Support-the-stable_inodes-fe.patch \
           "
