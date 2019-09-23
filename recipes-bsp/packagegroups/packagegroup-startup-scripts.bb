SUMMARY = "Starup scripts needed during device bootup"

inherit packagegroup

RDEPENDS_${PN} = "\
    firmware-links \
    post-boot \
    usb-composition \
    "
