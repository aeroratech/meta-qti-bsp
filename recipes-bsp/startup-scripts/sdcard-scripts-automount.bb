HOMEPAGE         = "https://www.codeaurora.org/"
LICENSE          = "BSD-3-Clause-Clear"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta-qti-bsp/files/common-licenses/${LICENSE};md5=3771d4920bd6cdb8cbdf1e8344489ee0"

DESCRIPTION = "Script for automounting SD Card"

SRC_URI += "\
            file://automountsdcard.sh \
            file://automountsdcard.rules \
            file://sdcardmount@.service \
"

PACKAGE_ARCH ?= "${MACHINE_ARCH}"
SDCARD_DEVICE ?= "mmcblk0p1"

do_configure[noexec] = "1"
do_compile[noexec] = "1"


do_install() {
    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${sysconfdir}/udev/scripts/
        install -m 0744 ${WORKDIR}/automountsdcard.sh \
            ${D}${sysconfdir}/udev/scripts/automountsdcard.sh
        sed -i "s/SLOT/"\"${SDCARD_DEVICE}\""/g" ${WORKDIR}/automountsdcard.rules
        install -d 0644 ${D}${sysconfdir}/udev/rules.d
        install -m 0744 ${WORKDIR}/automountsdcard.rules ${D}${sysconfdir}/udev/rules.d/
	install -d 0644 ${D}${systemd_unitdir}/system
	install -m 0644 ${WORKDIR}/sdcardmount@.service ${D}${systemd_unitdir}/system
    else
        install -d ${D}${sysconfdir}/mdev
        install -m 0755 ${WORKDIR}/automountsdcard.sh ${D}${sysconfdir}/mdev/
    fi
}

FILES_${PN} += "${systemd_unitdir}/system/*"
