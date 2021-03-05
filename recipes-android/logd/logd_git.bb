inherit autotools pkgconfig systemd

DESCRIPTION = "Android logd daemon"
HOMEPAGE = "http://developer.android.com/"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=89aea4e17d99a7cacdbeed46a0096b10"

FILESEXTRAPATHS_prepend := "${WORKSPACE}/system/core/:"
SRC_URI = "file://logd \
           file://include "

S = "${WORKDIR}/logd"

DEPENDS += "libbase libutils libcutils libsysutils liblog"

EXTRA_OECONF = " ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', '--with-systemd', "",d)} "

do_install_append() {
    if ${@bb.utils.contains('EXTRA_OECONF', '--with-systemd', 'true', 'false', d)}; then
        install -d ${D}${systemd_unitdir}/system/
        install -d ${D}${systemd_unitdir}/system/multi-user.target.wants/
        install -d ${D}${systemd_unitdir}/system/ffbm.target.wants/

        ln -sf ${systemd_unitdir}/system/logd.path \
               ${D}${systemd_unitdir}/system/multi-user.target.wants/logd.path
        ln -sf ${systemd_unitdir}/system/earlyinit-logd.service \
               ${D}${systemd_unitdir}/system/multi-user.target.wants/earlyinit-logd.service

        ln -sf ${systemd_unitdir}/system/logd.path \
               ${D}${systemd_unitdir}/system/ffbm.target.wants/logd.path
        ln -sf ${systemd_unitdir}/system/earlyinit-logd.service \
               ${D}${systemd_unitdir}/system/ffbm.target.wants/earlyinit-logd.service
    fi
}

FILES_${PN} += "${systemd_unitdir}/system/"
