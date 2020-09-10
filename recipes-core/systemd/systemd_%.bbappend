FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
        file://0001-kernel-install-shell-changes-to-sh.patch \
"

#Add qti specific changes only when qt-disro is enabled.
QTI_SYSTEMD_INC = ""
QTI_SYSTEMD_INC_qti-distro-base = "${THISDIR}/qti-systemd.inc"
include ${QTI_SYSTEMD_INC}

#remove of bash from systemd
RDEPENDS_${PN}-kernel-install_remove = "bash"


