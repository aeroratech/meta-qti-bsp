inherit autotools-brokensep gettext
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/${LICENSE};md5=0835ade698e0bcf8506ecda2f7b4f302"
SECTION = "libs"
PR = "r0"
SRCREV = "${AUTOREV}"
SRC_URI = "git://source.codeaurora.org/quic/la/platform/external/jsoncpp;protocol=git;branch=android-external.lnx.2.0-rel;destsuffix=${PN}-src-${PV} \
        file://${PN}-src-${PV}/Makefile.am \
        file://${PN}-src-${PV}/configure.ac \
        file://${PN}-src-${PV}/jsoncpp.pc.in \
"
S = "${WORKDIR}/${PN}-src-${PV}"

do_install_append() {
}
