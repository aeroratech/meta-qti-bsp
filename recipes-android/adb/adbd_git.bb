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
    install -m 0755 ${S}/launch_adbd -D ${D}${sysconfdir}/launch_adbd
    install -m 0750 ${S}/start_adbd -D ${D}${sysconfdir}/initscripts/adbd
    install -b -m 0644 /dev/null ${D}${sysconfdir}/adb_devid

    install -d ${D}${systemd_unitdir}/system/
    install -d ${D}${systemd_unitdir}/system/multi-user.target.wants/
    install -d ${D}${systemd_unitdir}/system/ffbm.target.wants/
    install -m 0644 ${S}/adbd.service -D ${D}${systemd_unitdir}/system/adbd.service
    ln -sf ${systemd_unitdir}/system/adbd.service \
        ${D}${systemd_unitdir}/system/multi-user.target.wants/adbd.service
    ln -sf ${systemd_unitdir}/system/adbd.service \
        ${D}${systemd_unitdir}/system/ffbm.target.wants/adbd.service
}

FILES_${PN} += "${systemd_unitdir}/system/"
