# QTI Linux Telematics External AP image file.
# Provides packages required to build an image with
# all qti external AP (applications processor) support
# enabled.

inherit qimage populate_sdk

IMAGE_FEATURES += "read-only-rootfs"

CORE_IMAGE_EXTRA_INSTALL += "\
        chrony \
        glib-2.0 \
        i2c-tools \
        kernel-modules \
        libnl \
        libxml2 \
        net-tools \
        packagegroup-android-utils \
        packagegroup-qti-teleap \
        packagegroup-qti-telematics \
        packagegroup-startup-scripts \
        pps-tools \
        spitools \
        systemd-machine-units \
        ${@bb.utils.contains('DISTRO_FEATURES','emmc-boot', 'e2fsprogs e2fsprogs-e2fsck e2fsprogs-mke2fs', '', d)} \
        ${@bb.utils.contains('DISTRO_FEATURES','selinux', 'packagegroup-selinux-minimal', '', d)} \
"
