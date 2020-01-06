inherit systemd pkgconfig

DESCRIPTION = "Scripts for device settings after boot"
HOMEPAGE = "http://codeaurora.org"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=550794465ba0ec5312d6919e203a55f9"

FILESEXTRAPATHS_prepend := "${WORKSPACE}/system/core/:"
SRC_URI   = "file://rootdir/etc"

S = "${WORKDIR}/rootdir/etc"

do_configure[noexec]="1"
do_compile[noexec]="1"

do_install() {
    install -m 0750 ${S}/${MACHINE}/init.post_boot.sh -D ${D}${sysconfdir}/initscripts/init_post_boot

    install -d ${D}${systemd_unitdir}/system/
    install -d ${D}${systemd_unitdir}/system/multi-user.target.wants/
    install -d ${D}${systemd_unitdir}/system/ffbm.target.wants/
    install -m 0644 ${S}/init_post_boot.service \
           -D ${D}${systemd_unitdir}/system/init_post_boot.service
    ln -sf ${systemd_unitdir}/system/init_post_boot.service \
           ${D}${systemd_unitdir}/system/multi-user.target.wants/init_post_boot.service
    ln -sf ${systemd_unitdir}/system/init_post_boot.service \
           ${D}${systemd_unitdir}/system/ffbm.target.wants/init_post_boot.service
}

do_install_append_qcs40x () {
    install -m 0750 ${S}/${MACHINE}/init.qti.debug.sh -D ${D}${sysconfdir}/initscripts/init_qti_debug
}

FILES_${PN} += "${systemd_unitdir}/system/"
