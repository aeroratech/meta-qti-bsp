include usb-composition.inc

do_install[postfuncs] += "fixup_usb_service"
fixup_usb_service() {
   # For SDX targets, start USB early in boot chain and hence needs early mount-copybinds.
   if ${@bb.utils.contains('MACHINE_FEATURES', 'qti-sdx', 'true', 'false', d)}; then
      sed -i 's/default.target/local-fs.target/g' ${D}${systemd_unitdir}/system/usb.service
      sed -i '/After=/s/sysinit.target//' ${D}${systemd_unitdir}/system/usb.service
   fi
}
