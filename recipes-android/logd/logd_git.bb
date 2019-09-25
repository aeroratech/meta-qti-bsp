inherit autotools pkgconfig systemd

DESCRIPTION = "Android logd daemon"
HOMEPAGE = "http://developer.android.com/"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=89aea4e17d99a7cacdbeed46a0096b10"

FILESEXTRAPATHS_prepend := "${WORKSPACE}/system/core/:"
SRC_URI = "file://logd"

S = "${WORKDIR}/logd"

DEPENDS += "libbase libutils libcutils libsysutils liblog"

EXTRA_OECONF = " --with-core-includes=${WORKSPACE}/system/core/include"

do_install_append() {
    install -d ${D}${systemd_unitdir}/system/
    install -d ${D}${systemd_unitdir}/system/multi-user.target.wants/
    install -d ${D}${systemd_unitdir}/system/ffbm.target.wants/
    install -m 0644 ${S}/logd.path -D ${D}${systemd_unitdir}/system/logd.path
    install -m 0644 ${S}/earlyinit-logd.service -D ${D}${systemd_unitdir}/system/earlyinit-logd.service
    install -m 0644 ${S}/logd.service -D ${D}${systemd_unitdir}/system/logd.service

    ln -sf ${systemd_unitdir}/system/logd.path \
           ${D}${systemd_unitdir}/system/multi-user.target.wants/logd.path
    ln -sf ${systemd_unitdir}/system/earlyinit-logd.service \
           ${D}${systemd_unitdir}/system/multi-user.target.wants/earlyinit-logd.service

    ln -sf ${systemd_unitdir}/system/logd.path \
           ${D}${systemd_unitdir}/system/ffbm.target.wants/logd.path
    ln -sf ${systemd_unitdir}/system/earlyinit-logd.service \
           ${D}${systemd_unitdir}/system/ffbm.target.wants/earlyinit-logd.service
}


FILES_${PN} += "${systemd_unitdir}/system/"
