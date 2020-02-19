# QTI Linux audio image file.
# Provides packages required to build an image with
# minimal boot to console with audio support.

inherit qimage

IMAGE_FEATURES += "ssh-server-openssh"

CORE_IMAGE_EXTRA_INSTALL += "\
        abctl \
        ab-slot-util \
        ab-status-updater \
        chrony \
        e2fsprogs \
        e2fsprogs-e2fsck \
        e2fsprogs-mke2fs \
        glib-2.0 \
        kernel-modules \
        libnl \
        libxml2 \
        packagegroup-android-utils \
        packagegroup-qti-bluetooth \
        packagegroup-qti-core-prop \
        packagegroup-qti-data \
        packagegroup-qti-dsp \
        packagegroup-qti-ml \
        packagegroup-qti-ss-mgr \
        packagegroup-qti-wifi \
        packagegroup-startup-scripts \
        systemd-machine-units \
"
