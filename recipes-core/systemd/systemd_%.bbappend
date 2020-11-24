#Add qti specific changes only when qt-disro is enabled.
QTI_SYSTEMD_INC = ""
QTI_SYSTEMD_INC_qti-distro-base = "${THISDIR}/qti-systemd.inc"
include ${QTI_SYSTEMD_INC}
