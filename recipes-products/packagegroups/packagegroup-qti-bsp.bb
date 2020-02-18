SUMMARY = "Basic programs and scripts required by LE system"
DESCRIPTION = "Package group to bring in all basic packages for LE system"
LICENSE = "BSD-3-Clause"

inherit packagegroup

PROVIDES = "${PACKAGES}"

PACKAGES = ' \
    packagegroup-android-utils \
    packagegroup-startup-scripts \
    '

# Android Core Image and Debugging utilities
RDEPENDS_packagegroup-android-utils = "\
    adbd \
    binder \
    leproperties \
    logcat \
    logd \
    system-prop \
    "

# Startup scripts needed during device bootup
RDEPENDS_packagegroup-startup-scripts = "\
    ${@bb.utils.contains('COMBINED_FEATURES', 'qti-ab-boot', 'ab-slot-util', '', d)} \
    post-boot \
    usb-composition \
    "
