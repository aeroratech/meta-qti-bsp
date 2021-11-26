# Provides packages required to build
# QTI Generic Linux image.

inherit qimage populate_sdk_ext

IMAGE_FEATURES += "ssh-server-openssh"

# This image doesn't support abl generation
EXTRA_IMAGEDEPENDS_remove = "edk2"

CORE_IMAGE_EXTRA_INSTALL += "\
        e2fsprogs \
        e2fsprogs-e2fsck \
        e2fsprogs-mke2fs \
        glib-2.0 \
        kernel-modules \
        packagegroup-android-utils-base \
        packagegroup-startup-scripts-base \
        packagegroup-support-utils \
        systemd-machine-units \
        ${@bb.utils.contains('DISTRO_FEATURES','selinux', 'packagegroup-selinux-minimal', '', d)} \
"
# Install display packages
CORE_IMAGE_EXTRA_INSTALL += " \
            libdrm \
            wayland \
            "

python copy_buildsystem_append() {
    # Create src directory in extensible SDK to copy the project sources
    bb.utils.mkdirhier(baseoutpath + '/src')
    # Enable the use of WORKSPACE variable on an extensible SDK
    with open(baseoutpath + '/conf/bblayers.conf', 'a') as f:
        f.write('WORKSPACE = "$' + '{TOPDIR}/src"\n')
}
