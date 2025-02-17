# QTI Linux Telematics image file.
# Provides packages required to build
# QTI Linux Telematics NAD-Core image.

inherit qimage

IMAGE_FEATURES += "read-only-rootfs"

CORE_IMAGE_EXTRA_INSTALL += "\
        e2fsprogs \
        e2fsprogs-e2fsck \
        e2fsprogs-mke2fs \
        glib-2.0 \
        i2c-tools \
        kernel-modules \
        net-tools \
        pps-tools \
        spitools \
        coreutils \
        packagegroup-android-utils \
        packagegroup-qti-core \
        packagegroup-qti-data \
        ${@bb.utils.contains_any('COMBINED_FEATURES', 'qti-adsp qti-cdsp qti-modem qti-slpi', 'packagegroup-qti-dsp', '', d)} \
        ${@bb.utils.contains('MACHINE_FEATURES', 'qti-location', 'packagegroup-qti-location packagegroup-qti-location-auto', '', d)} \
        ${@bb.utils.contains('COMBINED_FEATURES', 'qti-security', 'packagegroup-qti-securemsm', '', d)} \
        ${@bb.utils.contains('COMBINED_FEATURES', 'qti-audio', 'packagegroup-qti-audio', '', d)} \
        packagegroup-qti-ss-mgr \
        packagegroup-qti-telematics \
        packagegroup-qti-telsdk \
        ${@bb.utils.contains('DISTRO_FEATURES','selinux', 'packagegroup-selinux-minimal', '', d)} \
        packagegroup-startup-scripts \
        packagegroup-support-utils \
        subsystem-ramdump \
        systemd-machine-units \
        qmi-shutdown-modem \
        modem-shutdown \
"
