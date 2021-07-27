# Provides packages required to build
# QTI Linux eXtended Reality image.

inherit qimage populate_sdk_qti

IMAGE_FEATURES += "ssh-server-openssh"

CORE_IMAGE_EXTRA_INSTALL += "\
        e2fsprogs \
        e2fsprogs-e2fsck \
        e2fsprogs-mke2fs \
        glib-2.0 \
        kernel-modules \
        packagegroup-android-utils \
        packagegroup-qti-audio \
        ${@bb.utils.contains('COMBINED_FEATURES', 'qti-bluetooth', "packagegroup-qti-bluetooth", "", d)} \
        packagegroup-qti-camera \
        packagegroup-qti-core \
        packagegroup-qti-cvp \
        ${@bb.utils.contains('MACHINE_FEATURES', 'qti-data-modem', "packagegroup-qti-data", "", d)} \
        packagegroup-qti-display \
        packagegroup-qti-dsp \
        packagegroup-qti-fastcv \
        packagegroup-qti-gfx \
        packagegroup-qti-gst \
        packagegroup-qti-pulseaudio \
        packagegroup-qti-qvr \
        packagegroup-qti-securemsm \
        packagegroup-qti-sensors-see \
        packagegroup-qti-ss-mgr \
        packagegroup-qti-test-sensors-see \
        packagegroup-qti-video \
        ${@bb.utils.contains('COMBINED_FEATURES', 'qti-wifi', "packagegroup-qti-wifi", "", d)} \
        packagegroup-startup-scripts \
        packagegroup-support-utils \
        systemd-machine-units \
        ${@bb.utils.contains('DISTRO_FEATURES','selinux', 'packagegroup-selinux-minimal', '', d)} \
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
