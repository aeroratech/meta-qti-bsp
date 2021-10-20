#Add qti specific changes only when qt-disro is enabled.
QTI_SYSTEMD_INC = ""
QTI_SYSTEMD_INC_qti-distro-base = "${THISDIR}/qti-systemd.inc"
include ${QTI_SYSTEMD_INC}

do_install_append() {
    sed -i '/group:wheel/d' ${D}${exec_prefix}/lib/tmpfiles.d/systemd.conf
}
