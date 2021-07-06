# QTI Linux Telematics image file.
# Provides packages required to build
# QTI Linux Telematics image.

inherit qimage

IMAGE_FEATURES += "read-only-rootfs"

CORE_IMAGE_EXTRA_INSTALL += "\
        chrony \
        e2fsprogs \
        e2fsprogs-e2fsck \
        e2fsprogs-mke2fs \
        glib-2.0 \
        i2c-tools \
        kernel-modules \
        libnl \
        libxml2 \
        net-tools \
        packagegroup-android-utils \
        ${@bb.utils.contains('MACHINE_FEATURES', 'qti-location', 'packagegroup-qti-location', '', d)} \
        ${@bb.utils.contains('COMBINED_FEATURES', 'qti-security', 'packagegroup-qti-securemsm', '', d)} \
        packagegroup-qti-telematics \
        ${@bb.utils.contains('DISTRO_FEATURES','selinux', 'packagegroup-selinux-minimal', '', d)} \
        packagegroup-startup-scripts \
        pps-tools \
        spitools \
        systemd-machine-units \
"
