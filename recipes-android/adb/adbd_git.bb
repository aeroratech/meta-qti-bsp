inherit autotools pkgconfig systemd

DESCRIPTION = "ADB daemon"
HOMEPAGE = "http://developer.android.com/"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=89aea4e17d99a7cacdbeed46a0096b10"

FILESEXTRAPATHS_prepend := "${WORKSPACE}/system/core/:"
SRC_URI = "file://adb"

S = "${WORKDIR}/adb"

DEPENDS += "ext4-utils glib-2.0 fsmgr libselinux libbase libcutils liblog"

EXTRA_OECONF = " \
                  --with-glib \
                  --with-core-includes=${WORKSPACE}/system/core/include \
"
do_install_append() {
    install -d ${D}${base_sbindir}
    install -d ${D}${sysconfdir}
    install -m 0755 ${S}/launch_adbd -D ${D}${base_sbindir}/launch_adbd
    install -b -m 0644 /dev/null ${D}${sysconfdir}/adb_devid
    install -m 0755 ${S}/start_pcie -D ${D}${sysconfdir}/start_pcie

    install -d ${D}${systemd_unitdir}/system/
    install -d ${D}${systemd_unitdir}/system/multi-user.target.wants/
    install -d ${D}${systemd_unitdir}/system/ffbm.target.wants/
    install -m 0644 ${S}/adbd.service -D ${D}${systemd_unitdir}/system/adbd.service
    install -m 0644 ${S}/pcie.service -D ${D}${systemd_unitdir}/system/pcie.service
    ln -sf ${systemd_unitdir}/system/adbd.service \
        ${D}${systemd_unitdir}/system/multi-user.target.wants/adbd.service
    ln -sf ${systemd_unitdir}/system/adbd.service \
        ${D}${systemd_unitdir}/system/ffbm.target.wants/adbd.service

    if ${@bb.utils.contains('MACHINE_FEATURES', 'qti-sdx', 'true', 'false', d)}; then
        install -d ${D}${systemd_unitdir}/system/local-fs.target.wants/
        rm -rf ${D}${systemd_unitdir}/system/multi-user.target.wants/adbd.service
        rm -rf ${D}${systemd_unitdir}/system/multi-user.target.wants/usb.service
        ln -sf ${systemd_unitdir}/system/adbd.service ${D}${systemd_unitdir}/system/local-fs.target.wants/adbd.service
        ln -sf ${systemd_unitdir}/system/usb.service ${D}${systemd_unitdir}/system/local-fs.target.wants/usb.service
        sed -i '/Requires=usb.service/s/$/ diag-router.service/' ${D}${systemd_unitdir}/system/adbd.service
        ln -sf ${systemd_unitdir}/system/pcie.service ${D}${systemd_unitdir}/system/ffbm.target.wants/pcie.service
        ln -sf ${systemd_unitdir}/system/pcie.service ${D}${systemd_unitdir}/system/local-fs.target.wants/pcie.service
    fi
}

FILES_${PN} += "${systemd_unitdir}/system/"
