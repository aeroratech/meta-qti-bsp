# QTI Linux multimedia minimal image file.
# Provides packages required to build an image with
# all multimedia support enabled.

inherit qimage

IMAGE_FEATURES += "ssh-server-openssh"

CORE_IMAGE_EXTRA_INSTALL += "\
        e2fsprogs \
        e2fsprogs-e2fsck \
        e2fsprogs-mke2fs \
        glib-2.0 \
        kernel-modules \
        packagegroup-android-utils \
        packagegroup-startup-scripts \
        packagegroup-support-utils \
        systemd-machine-units \
"
