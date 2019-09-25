inherit autotools pkgconfig systemd

DESCRIPTION = "Andorid like properties managment for LE"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=89aea4e17d99a7cacdbeed46a0096b10"

FILESEXTRAPATHS_prepend := "${WORKSPACE}/system/core/:"
SRC_URI = "file://leproperties"

S = "${WORKDIR}/leproperties"

DEPENDS += "libselinux libcutils liblog"

do_install_append() {
    install -b -m 0644 /dev/null -D ${D}${sysconfdir}/build.prop

    install -d ${D}${systemd_unitdir}/system/
    install -d ${D}${systemd_unitdir}/system/multi-user.target.wants/
    install -d ${D}${systemd_unitdir}/system/ffbm.target.wants/
    install -m 0644 ${S}/leprop.service \
           -D ${D}${systemd_unitdir}/system/leprop.service
    ln -sf ${systemd_unitdir}/system/leprop.service \
           ${D}${systemd_unitdir}/system/multi-user.target.wants/leprop.service
    ln -sf ${systemd_unitdir}/system/leprop.service \
           ${D}${systemd_unitdir}/system/ffbm.target.wants/leprop.service
}

FILES_${PN} += "${systemd_unitdir}/system/"
