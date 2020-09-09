# Provides packages required to build
# QTI Linux eXtended Reality image.

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
        packagegroup-qti-core-prop \
        packagegroup-qti-data \
        packagegroup-qti-dsp \
        packagegroup-qti-ss-mgr \
        packagegroup-startup-scripts \
        systemd-machine-units \
"
#Install packages for audio
CORE_IMAGE_EXTRA_INSTALL += " \
            audiodlkm \
            init-audio \
            tinyalsa \
            soundtrigger \
"
#install drm
CORE_IMAGE_EXTRA_INSTALL += " \
            libdrm \
            libdrm-tests \
            libdrm-kms \
            "
#Install packages for display
CORE_IMAGE_EXTRA_INSTALL += " \
            wayland \
            gbm \
            "
#Install packages for video
CORE_IMAGE_EXTRA_INSTALL += " \
            packagegroup-qti-video \
            "

#Install packages for sensors
CORE_IMAGE_EXTRA_INSTALL += " \
            packagegroup-qti-sensors \
            "

#Install packages for camera
CORE_IMAGE_EXTRA_INSTALL += " \
            packagegroup-qti-camera \
            "
