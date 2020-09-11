# QTI Linux robotics image file.
# Provides packages required to build an image with
# robotics features support.

inherit qimage

IMAGE_FEATURES += "ssh-server-openssh"

CORE_IMAGE_EXTRA_INSTALL += "\
        chrony \
        e2fsprogs \
        e2fsprogs-e2fsck \
        e2fsprogs-mke2fs \
        glib-2.0 \
        kernel-modules \
        libnl \
        libxml2 \
        packagegroup-android-utils \
        packagegroup-qti-audio \
        packagegroup-qti-bluetooth \
        packagegroup-qti-camera \
        ${@bb.utils.contains('DISTRO_FEATURES','virtualization', 'packagegroup-qti-containers', '', d)} \
        packagegroup-qti-core-prop \
        packagegroup-qti-data \
        packagegroup-qti-dsp \
        packagegroup-qti-fastcv \
        packagegroup-qti-ml \
        packagegroup-qti-qmmf \
        packagegroup-qti-robotics \
        packagegroup-qti-securemsm \
        packagegroup-qti-ss-mgr \
        packagegroup-qti-video \
        packagegroup-qti-wifi \
        packagegroup-startup-scripts \
        systemd-machine-units \
"
