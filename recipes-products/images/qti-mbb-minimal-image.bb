# QTI Linux mbb minimal image file.
# Provides packages required to build an mbb minimal image with
# boot to console

inherit qimage
require ${COREBASE}/meta-qti-bsp/recipes-products/images/include/qti-ramdisk.inc

IMAGE_FEATURES += "read-only-rootfs persist-volume"

CORE_IMAGE_EXTRA_INSTALL += "\
              glib-2.0 \
              kernel-modules \
              powerapp \
              powerapp-powerconfig \
              powerapp-reboot \
              powerapp-shutdown \
              systemd-machine-units \
              packagegroup-android-utils \
              packagegroup-startup-scripts \
              packagegroup-qti-data \
              packagegroup-qti-core \
              packagegroup-qti-securemsm \
              packagegroup-qti-ss-mgr \
              ${@bb.utils.contains('MACHINE_FEATURES', 'qti-audio', 'packagegroup-qti-audio', '', d)} \
              ${@bb.utils.contains('MACHINE_FEATURES', 'qti-location', 'packagegroup-qti-location', '', d)} \
              ${@bb.utils.contains('DISTRO_FEATURES','selinux', 'packagegroup-selinux-minimal', '', d)} \
"

do_rootfs_append() {
    bb.build.exec_func('do_ramdisk_create',d)
}
