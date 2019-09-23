SUMMARY = "Android Core Image and Debugging utilities"

inherit packagegroup

RDEPENDS_${PN} = "\
    adbd \
    binder \
    leproperties \
    logd \
    "
