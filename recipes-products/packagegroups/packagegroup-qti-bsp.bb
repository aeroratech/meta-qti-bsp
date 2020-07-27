SUMMARY = "Basic programs and scripts required by LE system"
DESCRIPTION = "Package group to bring in all basic packages for LE system"
LICENSE = "BSD-3-Clause"

inherit packagegroup

PROVIDES = "${PACKAGES}"
USB_SUPPORT = "${@d.getVar('MACHINE_SUPPORTS_USB') or "True"}"
PROPERTIES_SUPPORT = "${@d.getVar('MACHINE_SUPPORTS_ANDROID_PROPERTIES') or "True"}"

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
    ${@oe.utils.conditional('PROPERTIES_SUPPORT', 'True', 'system-prop', '', d)} \
    "

# Startup scripts needed during device bootup
RDEPENDS_packagegroup-startup-scripts = "\
    ${@bb.utils.contains('COMBINED_FEATURES', 'qti-ab-boot', 'ab-slot-util', '', d)} \
    ${@oe.utils.conditional('USB_SUPPORT', 'True', 'usb-composition', '', d)} \
    post-boot \
    "
