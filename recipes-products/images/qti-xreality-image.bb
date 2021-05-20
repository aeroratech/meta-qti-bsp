# Provides packages required to build
# QTI Linux eXtended Reality image.

inherit qimage populate_sdk

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
        packagegroup-qti-camera \
        packagegroup-qti-display \
        ${@bb.utils.contains('MACHINE_FEATURES', 'qti-data-modem', "packagegroup-qti-data", "", d)} \
        packagegroup-qti-dsp \
        packagegroup-qti-fastcv \
        packagegroup-qti-cvp \
        packagegroup-qti-gfx \
        packagegroup-qti-sensors-see \
        packagegroup-qti-ss-mgr \
        packagegroup-qti-securemsm \
        ${@bb.utils.contains('COMBINED_FEATURES', 'qti-wifi', "packagegroup-qti-wifi", "", d)} \
        ${@bb.utils.contains('COMBINED_FEATURES', 'qti-bluetooth', "packagegroup-qti-bluetooth", "", d)} \
        packagegroup-qti-video \
        packagegroup-qti-gst \
        packagegroup-startup-scripts \
        systemd-machine-units \
        ${@bb.utils.contains('DISTRO_FEATURES','selinux', 'packagegroup-selinux-minimal', '', d)} \
"
#Install packages for audio
CORE_IMAGE_EXTRA_INSTALL += " \
            audiodlkm \
            init-audio \
            tinyalsa \
            tinycompress \
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
# To include protoc compiler in SDK
TOOLCHAIN_HOST_TASK_append = " nativesdk-protobuf-compiler "

# To include kernel headers in SDK
TOOLCHAIN_TARGET_TASK_append = " linux-msm-headers-dev"

# To include kernel sources in SDK to build kernel modules
TOOLCHAIN_TARGET_TASK_append = " kernel-devsrc"
