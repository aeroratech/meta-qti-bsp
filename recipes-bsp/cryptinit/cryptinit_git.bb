DESCRIPTION = "DM-Crypt Initialization"
HOMEPAGE         = "https://git.codelinaro.org/"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/BSD;md5=3775480a712fc46a69647678acb234cb"
LICENSE          = "BSD-3-Clause-Clear"

PR = "r1"

inherit pkgconfig

FILESPATH =+ "${WORKSPACE}/files:"
SRC_URI = " \
    file://cryptinit.service \
    file://cryptinit.sh \
    file://cryptshutdown.sh \
"

S = "${WORKDIR}"

do_unpack[deptask] = "do_populate_sysroot"

FILES_${PN} = "${bindir}/* ${systemd_unitdir}/system"

do_install_append() {
    install -d ${D}${systemd_unitdir}/system/
    install -d ${D}${systemd_unitdir}/system/multi-user.target.wants/
    install -m 0755 ${S}/cryptinit.sh -D ${D}/${bindir}/cryptinit.sh
    install -m 0755 ${S}/cryptshutdown.sh -D ${D}/${bindir}/cryptshutdown.sh
    install -m 0644 ${S}/cryptinit.service -D ${D}${systemd_unitdir}/system/cryptinit.service
    ln -sf ${systemd_unitdir}/system/cryptinit.service ${D}${systemd_unitdir}/system/multi-user.target.wants/cryptinit.service
}
