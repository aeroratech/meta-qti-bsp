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
   fi
}
