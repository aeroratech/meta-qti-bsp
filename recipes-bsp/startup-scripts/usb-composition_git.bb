inherit pkgconfig systemd

DESCRIPTION = "Scripts to set USB compositions"
HOMEPAGE = "http://codeaurora.org"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=550794465ba0ec5312d6919e203a55f9"

FILESEXTRAPATHS_prepend := "${WORKSPACE}/system/core/:"
SRC_URI   = "file://usb"

S = "${WORKDIR}/usb"

do_configure[noexec]="1"
do_compile[noexec]="1"

USBCOMPOSITION ?= "901D"

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

   install -m 0755 ${S}/start_usb -D ${D}${sysconfdir}/initscripts/usb
   install -d ${D}${systemd_unitdir}/system/
   install -d ${D}${systemd_unitdir}/system/multi-user.target.wants/
   install -d ${D}${systemd_unitdir}/system/ffbm.target.wants/
   install -m 0644 ${S}/usb.service -D ${D}${systemd_unitdir}/system/usb.service
   ln -sf ${systemd_unitdir}/system/usb.service \
        ${D}${systemd_unitdir}/system/multi-user.target.wants/usb.service
   ln -sf ${systemd_unitdir}/system/usb.service \
        ${D}${systemd_unitdir}/system/ffbm.target.wants/usb.service
}

FILES_${PN} += "${systemd_unitdir}/system/"
