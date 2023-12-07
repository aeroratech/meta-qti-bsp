#Add qti specific changes only when qt-disro is enabled.
QTI_SYSTEMD_INC = ""
QTI_SYSTEMD_INC_qti-distro-base = "${THISDIR}/qti-systemd.inc"
include ${QTI_SYSTEMD_INC}

do_install_append() {
    sed -i '/group:wheel/d' ${D}${exec_prefix}/lib/tmpfiles.d/systemd.conf
    if ${@bb.utils.contains_any('MACHINE', 'cinder', 'true', 'false', d)}; then
        sed -i -e 's/^#RuntimeWatchdogSec=.*$/RuntimeWatchdogSec=30/g' ${D}${sysconfdir}/systemd/system.conf
    fi
}
