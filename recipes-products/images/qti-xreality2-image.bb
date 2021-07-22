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
        packagegroup-qti-core \
        packagegroup-qti-display \
        ${@bb.utils.contains('MACHINE_FEATURES', 'qti-data-modem', "packagegroup-qti-data", "", d)} \
        packagegroup-qti-dsp \
        packagegroup-qti-fastcv \
        packagegroup-qti-ss-mgr \
        ${@bb.utils.contains('COMBINED_FEATURES', 'qti-wifi', "packagegroup-qti-wifi", "", d)} \
        ${@bb.utils.contains('COMBINED_FEATURES', 'qti-bluetooth', "packagegroup-qti-bluetooth", "", d)} \
        packagegroup-startup-scripts \
        systemd-machine-units \
        ${@bb.utils.contains('DISTRO_FEATURES','selinux', 'packagegroup-selinux-minimal', '', d)} \
"
# To include protoc compiler in SDK
TOOLCHAIN_HOST_TASK_append = " nativesdk-protobuf-compiler "

# To include kernel headers in SDK
TOOLCHAIN_TARGET_TASK_append = " linux-msm-headers-dev"

# To include kernel sources in SDK to build kernel modules
TOOLCHAIN_TARGET_TASK_append = " kernel-devsrc"
