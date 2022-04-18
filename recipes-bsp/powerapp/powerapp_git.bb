inherit autotools-brokensep pkgconfig systemd

DESCRIPTION = "Powerapp tools"
HOMEPAGE = "http://codeaurora.org/"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=89aea4e17d99a7cacdbeed46a0096b10"

FILESEXTRAPATHS_prepend := "${WORKSPACE}/system/core/:"
SRC_URI = "file://powerapp"

S = "${WORKDIR}/powerapp"

PACKAGECONFIG ?= "glib"
PACKAGECONFIG[glib] = "--with-glib, --without-glib, glib-2.0"

PACKAGES =+ "${PN}-reboot ${PN}-shutdown ${PN}-powerconfig"
FILES_${PN}-reboot = " ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', "${sysconfdir}/initscripts/reboot", "${sysconfdir}/init.d/reboot", d)} "
FILES_${PN}-shutdown = " ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', "${sysconfdir}/initscripts/shutdown", "${sysconfdir}/init.d/shutdown", d)} "
FILES_${PN}-powerconfig = " ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', "${sysconfdir}/initscripts/power_config", "${sysconfdir}/init.d/power_config", d)} "
FILES_${PN} += "/data/*"
FILES_${PN} += "/lib/systemd/*"

# TODO - add depedency on virtual/sh
PROVIDES =+ "${PN}-reboot ${PN}-shutdown ${PN}-powerconfig"

PR = "r9"

EXTRA_OECONF  = " ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', '--with-systemd', '',d)} "
EXTRA_OECONF += "${@bb.utils.contains('MACHINE_FEATURES', 'qti-vm', '--enable-vm-config', '', d)}"

DEPENDS += "glib-2.0"
EXTRA_OECONF += "--with-glib"

do_install_append() {
        ln ${D}${base_sbindir}/powerapp ${D}${base_sbindir}/sys_reboot
        ln ${D}${base_sbindir}/powerapp ${D}${base_sbindir}/sys_shutdown

}


pkg_postinst_${PN}-reboot () {
        if ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'false', 'true', d)}; then
           [ -n "$D" ] && OPT="-r $D" || OPT="-s"
           update-rc.d $OPT -f reboot remove
           update-rc.d $OPT reboot start 99 6 .
	fi
}

pkg_postinst_${PN}-shutdown () {
        if ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'false', 'true', d)}; then
           [ -n "$D" ] && OPT="-r $D" || OPT="-s"
           update-rc.d $OPT -f shutdown remove
           update-rc.d $OPT shutdown start 99 0 .
	fi
}

pkg_postinst_${PN}-powerconfig () {
        if ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'false', 'true', d)}; then
           [ -n "$D" ] && OPT="-r $D" || OPT="-s"
           update-rc.d $OPT -f power_config remove
           update-rc.d $OPT power_config start 99 2 3 4 5 . stop 50 0 1 6 .
	fi
}

pkg_postinst_${PN} () {
        if ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'false', 'true', d)}; then
           [ -n "$D" ] && OPT="-r $D" || OPT="-s"
           update-rc.d $OPT -f reset_reboot_cookie remove
           update-rc.d $OPT reset_reboot_cookie start 55 2 3 4 5 .
        fi
}

SYSTEMD_SERVICE_${PN}  = " reset_reboot_cookie.service "
SYSTEMD_SERVICE_${PN}  = " power_config.service "
SYSTEMD_SERVICE_${PN} += "${@bb.utils.contains('MACHINE_FEATURES','qti-vm',' powerapp.service ','',d)}"
