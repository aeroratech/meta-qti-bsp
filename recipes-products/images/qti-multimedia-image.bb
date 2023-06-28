# QTI Linux multimedia image file.
# Provides packages required to build an image with
# all multimedia support enabled.

inherit qimage

IMAGE_FEATURES += "ssh-server-openssh"

CORE_IMAGE_EXTRA_INSTALL += "\
        e2fsprogs \
        e2fsprogs-e2fsck \
        e2fsprogs-mke2fs \
        e2fsprogs-tune2fs \
        glib-2.0 \
        kernel-modules \
        libdrm-tests \
        graphite-client \
        alsa-utils \
        packagegroup-android-utils \
        packagegroup-qti-audio \
        packagegroup-qti-pulseaudio \
        packagegroup-qti-bluetooth \
        packagegroup-qti-camera \
        packagegroup-qti-core \
        packagegroup-qti-data \
        packagegroup-qti-display \
        packagegroup-qti-dsp \
        packagegroup-qti-fastcv \
        packagegroup-qti-gst \
        packagegroup-qti-ml \
        packagegroup-qti-gfx \
        packagegroup-qti-qmmf \
        ${@bb.utils.contains('COMBINED_FEATURES', 'qti-security', 'packagegroup-qti-securemsm', '', d)} \
        ${@bb.utils.contains('MACHINE_FEATURES', 'qti-sensors', 'packagegroup-qti-sensors', '', d)} \
        ${@bb.utils.contains('MACHINE_FEATURES', 'qti-location', 'packagegroup-qti-location', '', d)} \
        packagegroup-qti-ss-mgr \
        packagegroup-qti-video \
        packagegroup-qti-wifi \
        packagegroup-startup-scripts \
        packagegroup-support-utils \
        systemd-machine-units \
        ${@bb.utils.contains('DISTRO_FEATURES','selinux', 'packagegroup-selinux-minimal', '', d)} \
        hibernate \
        system-sample-apps \
"
