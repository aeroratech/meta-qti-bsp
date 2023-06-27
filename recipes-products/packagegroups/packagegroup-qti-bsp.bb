SUMMARY = "Basic programs and scripts required by LE system"
DESCRIPTION = "Package group to bring in all basic packages for LE system"
LICENSE = "BSD-3-Clause"

inherit packagegroup

PROVIDES = "${PACKAGES}"
USB_SUPPORT = "${@d.getVar('MACHINE_SUPPORTS_USB') or "True"}"
PROPERTIES_SUPPORT = "${@d.getVar('MACHINE_SUPPORTS_ANDROID_PROPERTIES') or "True"}"

PACKAGES = ' \
    packagegroup-android-utils \
    packagegroup-support-utils \
    packagegroup-startup-scripts \
    '

# Android Core Image and Debugging utilities
RDEPENDS_packagegroup-android-utils = "\
    packagegroup-android-utils-base \
    "

# Startup scripts needed during device bootup
RDEPENDS_packagegroup-startup-scripts = "\
    packagegroup-startup-scripts-base \
    "
# Other essential utilites
RDEPENDS_packagegroup-support-utils = "\
    chrony \
    libinput \
    libinput-bin \
    libnl \
    libxml2 \
    "

# Sa525m overwrite the packagegroup to only include chrony
RDEPENDS_packagegroup-support-utils_sa525m = "\
    chrony \
    "
