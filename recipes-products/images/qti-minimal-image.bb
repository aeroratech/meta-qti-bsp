# QTI Linux minimal boot image file.
# Provides packages required to build an image with
# boot to console

inherit qimage
require ${COREBASE}/meta-qti-bsp/recipes-products/images/include/qti-ramdisk.inc

IMAGE_FEATURES += "read-only-rootfs persist-volume"

CORE_IMAGE_EXTRA_INSTALL += "\
              glib-2.0 \
              kernel-modules \
              systemd-machine-units \
              packagegroup-android-utils \
              packagegroup-startup-scripts \
              packagegroup-qti-core-prop \
              packagegroup-qti-ss-mgr \
              packagegroup-qti-data \
"

do_rootfs_append() {
    bb.build.exec_func('do_ramdisk_create',d)
}
