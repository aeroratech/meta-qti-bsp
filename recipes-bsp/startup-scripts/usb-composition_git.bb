inherit autotools pkgconfig systemd

DESCRIPTION = "Scripts to set USB compositions"
HOMEPAGE = "http://codeaurora.org"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=550794465ba0ec5312d6919e203a55f9"

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
   install -d ${D}${systemd_unitdir}/system/multi-user.target.wants/
   install -d ${D}${systemd_unitdir}/system/ffbm.target.wants/
   install -m 0644 ${S}/usb.service -D ${D}${systemd_unitdir}/system/usb.service
   install -m 0644 ${S}/usbd.service -D ${D}${systemd_unitdir}/system/usbd.service
   ln -sf ${systemd_unitdir}/system/usb.service \
        ${D}${systemd_unitdir}/system/multi-user.target.wants/usb.service
   ln -sf ${systemd_unitdir}/system/usb.service \
        ${D}${systemd_unitdir}/system/ffbm.target.wants/usb.service
   ln -sf ${systemd_unitdir}/system/usbd.service \
        ${D}${systemd_unitdir}/system/multi-user.target.wants/usbd.service

   # For SDX targets, start USB early in boot chain and hence needs early mount-copybinds.
   if ${@bb.utils.contains('MACHINE_FEATURES', 'qti-sdx', 'true', 'false', d)}; then
      install -d ${D}${systemd_unitdir}/system/local-fs.target.wants/
      rm -rf ${D}${systemd_unitdir}/system/multi-user.target.wants/usb.service
      ln -sf ${systemd_unitdir}/system/usb.service ${D}${systemd_unitdir}/system/local-fs.target.wants/usb.service
      sed -i '/After=/s/sysinit.target//' ${D}${systemd_unitdir}/system/usb.service
      if ${@bb.utils.contains('DISTRO_FEATURES', 'nand-boot', 'true', 'false', d)}; then
         sed -i '0,/\<After\>/s/After=/After=systemrw.mount /' ${D}${systemd_unitdir}/system/usb.service
         sed -i '/After=systemrw.mount/a Requires=systemrw.mount' ${D}${systemd_unitdir}/system/usb.service
      sed -i '/RemainAfterExit=yes/a ExecStartPre=/sbin/mount-copybind /systemrw/adb_devid  /etc/adb_devid' ${D}${systemd_unitdir}/system/usb.service
      sed -i '/RemainAfterExit=yes/a ExecStartPre=/sbin/mount-copybind /systemrw/boot_hsusb_comp /etc/usb/boot_hsusb_comp' ${D}${systemd_unitdir}/system/usb.service
      fi
   fi
}

FILES_${PN} += "${systemd_unitdir}/system/"
