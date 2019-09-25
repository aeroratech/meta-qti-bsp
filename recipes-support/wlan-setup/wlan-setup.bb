DESCRIPTION = "Utility facilitating wifi auto connection to preconfigured AP"
HOMEPAGE    = "http://codeaurora.org"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/${LICENSE};\
md5=550794465ba0ec5312d6919e203a55f9"

SRC_URI = "\
    file://dhcpcd.service \
    file://wpa-supplicant.service \
    file://wlan-ko.service \
"
do_configure[noexec] = "1"
do_compile[noexec]   = "1"
do_install () {
    install -d ${D}${systemd_unitdir}/system/
    install -d ${D}${systemd_unitdir}/system/multi-user.target.wants/
    install -d ${D}${systemd_unitdir}/system/dhcpcd.service.requires/
    install -d ${D}${systemd_unitdir}/system/wpa-supplicant.service.requires/
    install -m 0644 ${WORKDIR}/dhcpcd.service ${D}${systemd_unitdir}/system/
    install -m 0644 ${WORKDIR}/wpa-supplicant.service ${D}${systemd_unitdir}/system/
    install -m 0644 ${WORKDIR}/wlan-ko.service ${D}${systemd_unitdir}/system/
    ln -sf ${systemd_unitdir}/system/wpa-supplicant.service \
        ${D}${systemd_unitdir}/system/dhcpcd.service.requires/wpa-supplicant.service
    ln -sf ${systemd_unitdir}/system/wlan-ko.service \
        ${D}${systemd_unitdir}/system/dhcpcd.service.requires/wlan-ko.service
    ln -sf ${systemd_unitdir}/system/wlan-ko.service \
        ${D}${systemd_unitdir}/system/wpa-supplicant.service.requires/wlan-ko.service
    ln -sf ${systemd_unitdir}/system/wpa-supplicant.service \
        ${D}${systemd_unitdir}/system/multi-user.target.wants/wpa-supplicant.service
    ln -sf ${systemd_unitdir}/system/wlan-ko.service \
        ${D}${systemd_unitdir}/system/multi-user.target.wants/wlan-ko.service
    ln -sf ${systemd_unitdir}/system/dhcpcd.service \
        ${D}${systemd_unitdir}/system/multi-user.target.wants/dhcpcd.service
}

FILES_${PN} += "${systemd_unitdir}/*"
