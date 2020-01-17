inherit autotools systemd pkgconfig

DESCRIPTION = "Scripts for device settings after boot"
HOMEPAGE = "http://codeaurora.org"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=550794465ba0ec5312d6919e203a55f9"

FILESEXTRAPATHS_prepend := "${WORKSPACE}/system/core/:"
SRC_URI   = "file://rootdir"

S = "${WORKDIR}/rootdir"

PACKAGECONFIG_append_qcx40x = " debug"

PACKAGECONFIG[logrestrict] = "--enable-logrestrict,--disable-logrestrict"
PACKAGECONFIG[debug] = "--enable-debug,--disable-debug"

EXTRA_OECONF_append = " \
    --with-basemachine=${BASEMACHINE} \
"

do_compile[noexec]="1"

do_install_append() {
    install -m 0644 ${S}/etc/init_post_boot.service \
           -D ${D}${systemd_unitdir}/system/init_post_boot.service

    install -d ${D}${systemd_unitdir}/system/multi-user.target.wants/
    ln -sf ${systemd_unitdir}/system/init_post_boot.service \
           ${D}${systemd_unitdir}/system/multi-user.target.wants/init_post_boot.service

    install -d ${D}${systemd_unitdir}/system/ffbm.target.wants/
    ln -sf ${systemd_unitdir}/system/init_post_boot.service \
           ${D}${systemd_unitdir}/system/ffbm.target.wants/init_post_boot.service
}

PACKAGE_ARCH = "${MACHINE_ARCH}"

FILES_${PN} += "${systemd_unitdir}/system/"
