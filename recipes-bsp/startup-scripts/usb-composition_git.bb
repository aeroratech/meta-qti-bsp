inherit autotools pkgconfig systemd
include usb-composition.inc
do_install[postfuncs] += "fixup_usb_service"
fixup_usb_service() {
   # For SDX targets, start USB early in boot chain and hence needs early mount-copybinds.
   if ${@bb.utils.contains('MACHINE_FEATURES', 'qti-sdx', 'true', 'false', d)}; then
      install -d ${D}${systemd_unitdir}/system/local-fs.target.wants/
      rm -rf ${D}${systemd_unitdir}/system/multi-user.target.wants/usb.service
      ln -sf ${systemd_unitdir}/system/usb.service ${D}${systemd_unitdir}/system/local-fs.target.wants/usb.service
      sed -i '/After=/s/sysinit.target//' ${D}${systemd_unitdir}/system/usb.service
      if ${@bb.utils.contains('MACHINE_FEATURES', 'nand-boot', 'true', 'false', d)}; then
         sed -i '0,/\<After\>/s/After=/After=systemrw.mount /' ${D}${systemd_unitdir}/system/usb.service
         sed -i '/After=systemrw.mount/a Requires=systemrw.mount' ${D}${systemd_unitdir}/system/usb.service
      sed -i '/RemainAfterExit=yes/a ExecStartPre=/sbin/mount-copybind /systemrw/adb_devid  /etc/adb_devid' ${D}${systemd_unitdir}/system/usb.service
      sed -i '/RemainAfterExit=yes/a ExecStartPre=/sbin/mount-copybind /systemrw/boot_hsusb_comp /etc/usb/boot_hsusb_comp' ${D}${systemd_unitdir}/system/usb.service
      fi
   fi

}

