# QTI Linux Telematics image file.
# Provides packages required to build
# QTI Linux Telematics image.

inherit qimage

IMAGE_FEATURES += "read-only-rootfs ${@bb.utils.contains('IMAGE_FSTYPES', 'ubi', 'persist-volume', '', d)}"

CORE_IMAGE_EXTRA_INSTALL += "\
        ${@bb.utils.contains('MACHINE_FEATURES', 'emmc-boot', 'e2fsprogs e2fsprogs-e2fsck e2fsprogs-mke2fs', '', d)} \
        glib-2.0 \
        i2c-tools \
        kernel-modules \
        net-tools \
        pps-tools \
        spitools \
        coreutils \
        packagegroup-android-utils \
        packagegroup-qti-core \
        ${@bb.utils.contains('MACHINE_FEATURES', 'qti-data-modem', 'packagegroup-qti-data', '', d)} \
        ${@bb.utils.contains_any('COMBINED_FEATURES', 'qti-adsp qti-cdsp qti-modem qti-slpi', 'packagegroup-qti-dsp', '', d)} \
        ${@bb.utils.contains('MACHINE_FEATURES', 'qti-location', 'packagegroup-qti-location packagegroup-qti-location-auto', '', d)} \
        ${@bb.utils.contains('MACHINE_FEATURES', 'qti-bluetooth', 'packagegroup-qti-bt', '', d)} \
        ${@bb.utils.contains('MACHINE_FEATURES', 'qti-wlan', 'packagegroup-qti-wlan', '', d)} \
        ${@bb.utils.contains('COMBINED_FEATURES', 'qti-security', 'packagegroup-qti-securemsm', '', d)} \
        ${@bb.utils.contains('COMBINED_FEATURES', 'qti-audio', 'packagegroup-qti-audio', '', d)} \
        packagegroup-qti-ss-mgr \
        packagegroup-qti-telematics \
        ${@bb.utils.contains('DISTRO_FEATURES', 'qti-telux', 'packagegroup-qti-telsdk', '', d)} \
        ${@bb.utils.contains('DISTRO_FEATURES', 'selinux', 'packagegroup-selinux-minimal', '', d)} \
        packagegroup-startup-scripts \
        packagegroup-support-utils \
        subsystem-ramdump \
        systemd-machine-units \
        qmi-shutdown-modem \
        modem-shutdown \
        ${@oe.utils.conditional('DEBUG_BUILD', '1', 'packagegroup-qti-debug-tools', '', d )} \
"

# Following packages will be enabled later
CORE_IMAGE_EXTRA_INSTALL_remove_sa410m = "\
       packagegroup-qti-ss-mgr \
       qmi-shutdown-modem \
       packagegroup-qti-telsdk \
"
