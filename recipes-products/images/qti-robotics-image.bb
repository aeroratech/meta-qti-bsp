# QTI Linux robotics image file.
# Provides packages required to build an image with
# robotics features support.

inherit qimage

IMAGE_FEATURES += "ssh-server-openssh"

CORE_IMAGE_EXTRA_INSTALL += "\
        alsa-utils \
        canutils \
        chronyc \
        e2fsprogs \
        e2fsprogs-e2fsck \
        e2fsprogs-mke2fs \
        e2fsprogs-tune2fs \
        glib-2.0 \
        kernel-modules \
        packagegroup-android-utils \
        packagegroup-qti-audio \
        packagegroup-qti-bluetooth \
        packagegroup-qti-camera \
        ${@bb.utils.contains('DISTRO_FEATURES','virtualization', 'packagegroup-qti-containers', '', d)} \
        packagegroup-qti-core \
        packagegroup-qti-core-prop \
        packagegroup-qti-cvp \
        packagegroup-qti-data \
        packagegroup-qti-display \
        packagegroup-qti-dsp \
        packagegroup-qti-fastcv \
        packagegroup-qti-gfx \
        packagegroup-qti-gst \
        packagegroup-qti-ml \
        packagegroup-qti-mmframeworks \
        ${@bb.utils.contains('MACHINE_FEATURES', 'qti-npu', 'packagegroup-qti-npu', '', d)} \
        packagegroup-qti-qmmf \
        packagegroup-qti-robotics \
        packagegroup-qti-securemsm \
        packagegroup-qti-ss-mgr \
        packagegroup-qti-test-sensors-see \
        packagegroup-qti-video \
        packagegroup-qti-wifi \
        ${@bb.utils.contains('DISTRO_FEATURES', 'ros2', 'packagegroup-ros2-foxy', '', d)} \
        packagegroup-startup-scripts \
        packagegroup-support-utils \
        systemd-machine-units \
        ${@bb.utils.contains('DISTRO_FEATURES','selinux', 'packagegroup-selinux-minimal', '', d)} \
        ${@bb.utils.contains_any("BASEMACHINE", "qrbx210 qcs6490", "qti-c2-module", "", d)} \
"
