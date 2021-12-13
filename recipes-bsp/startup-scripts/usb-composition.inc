inherit autotools pkgconfig systemd

DESCRIPTION = "Scripts to set USB compositions"
HOMEPAGE = "http://codeaurora.org"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=89aea4e17d99a7cacdbeed46a0096b10"

FILESEXTRAPATHS_prepend := "${WORKSPACE}/system/core/:"
SRC_URI   = "file://usb"

S = "${WORKDIR}/usb"

USBCOMPOSITION ?= "901D"

DEPENDS += "libcutils libutils"
do_install_append() {
   install -d ${D}${sysconfdir}/usb/
   install -b -m 0644 /dev/null ${D}${sysconfdir}/usb/boot_hsic_comp
   install -b -m 0644 /dev/null ${D}${sysconfdir}/usb/boot_hsusb_comp
   echo ${USBCOMPOSITION} > ${D}${sysconfdir}/usb/boot_hsusb_comp

   install -d ${D}${base_sbindir}/
   install -m 0755 ${S}/usb_composition -D ${D}${base_sbindir}/
   install -d ${D}${base_sbindir}/usb/
   install -d ${D}${base_sbindir}/usb/compositions/
   install -m 0755 ${S}/compositions/* -D ${D}${base_sbindir}/usb/compositions/
   install -m 0755 ${S}/target -D ${D}${base_sbindir}/usb/
   install -d ${D}${base_sbindir}/usb/debuger/
   install -m 0755 ${S}/debuger/debugFiles -D ${D}${base_sbindir}/usb/debuger/
   install -m 0755 ${S}/debuger/help -D ${D}${base_sbindir}/usb/debuger/
   install -m 0755 ${S}/debuger/usb_debug -D ${D}${base_sbindir}/

   install -d ${D}${base_sbindir}/
   install -m 0755 ${S}/start_usb -D ${D}${base_sbindir}/start_usb
   install -d ${D}${systemd_unitdir}/system/
   install -m 0644 ${S}/usb.service -D ${D}${systemd_unitdir}/system/usb.service
   install -m 0644 ${S}/usbd.service -D ${D}${systemd_unitdir}/system/usbd.service
}

SYSTEMD_SERVICE_${PN} = "usb.service usbd.service"
FILES_${PN} += "${systemd_unitdir}/system/"
