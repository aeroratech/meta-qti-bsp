# QTI Linux Telematics Host VM image file.
# Provides packages required to build
# QTI Linux Telematics Host VM image.

require qti-tele-image.inc

IMAGE_FEATURES += "vm-bootsys-volume vm-systemrw-volume"

# Install km-loader for selected machines
EVDEVMODULE ?= 'False'
EVDEVMODULE_sa515m = 'True'
EVDEVMODULE_sa415m = 'True'

CORE_IMAGE_EXTRA_INSTALL += "\
        ${@bb.utils.contains('MACHINE_FEATURES', 'emmc-boot', 'e2fsprogs e2fsprogs-e2fsck e2fsprogs-mke2fs', '', d)} \
        glib-2.0 \
        kernel-modules \
        ${@oe.utils.conditional('EVDEVMODULE', 'True', 'km-loader', '', d)} \
        libgpiod \
        coreutils \
        android-tools \
        packagegroup-android-utils \
        packagegroup-qti-core \
        ${@bb.utils.contains('MACHINE_FEATURES', 'android-binder', 'binder', '', d)} \
        ${@bb.utils.contains('MACHINE_FEATURES', 'qti-data-modem', 'packagegroup-qti-data', '', d)} \
        ${@bb.utils.contains_any('COMBINED_FEATURES', 'qti-adsp qti-cdsp qti-modem qti-slpi', 'packagegroup-qti-dsp', '', d)} \
        ${@bb.utils.contains('MACHINE_FEATURES', 'qti-location', 'packagegroup-qti-location packagegroup-qti-location-auto', '', d)} \
        ${@bb.utils.contains('MACHINE_FEATURES', 'qti-bluetooth', 'packagegroup-qti-bt', '', d)} \
        ${@bb.utils.contains('MACHINE_FEATURES', 'qti-wlan', 'packagegroup-qti-wlan', '', d)} \
        ${@bb.utils.contains('COMBINED_FEATURES', 'qti-security', 'packagegroup-qti-securemsm', '', d)} \
        ${@bb.utils.contains('COMBINED_FEATURES', 'qti-audio', 'packagegroup-qti-audio', '', d)} \
        ${@bb.utils.contains('MACHINE_FEATURES', 'qti-cv2x', 'packagegroup-qti-telematics-cv2x', '', d)} \
        packagegroup-qti-ss-mgr \
        packagegroup-qti-telematics \
        ${@bb.utils.contains('DISTRO_FEATURES', 'qti-telux', 'packagegroup-qti-telsdk', '', d)} \
        ${@bb.utils.contains('DISTRO_FEATURES', 'selinux', 'packagegroup-selinux-minimal', '', d)} \
        packagegroup-startup-scripts \
        packagegroup-support-utils \
        subsystem-ramdump \
        systemd-machine-units \
        ${@bb.utils.contains('MACHINE_FEATURES', 'nand-boot', 'mtd-utils-ubifs', '', d)} \
        qmi-shutdown-modem \
        modem-shutdown \
        ${@bb.utils.contains('MACHINE_FEATURES', 'qti-virtualization', 'packagegroup-qti-virtualization', '', d)} \
        ${@oe.utils.conditional('DEBUG_BUILD', '1', 'packagegroup-qti-debug-tools libgpiod-tools', '', d )} \
        ${@bb.utils.contains('COMBINED_FEATURES', 'qti-nad-telaf', 'packagegroup-qti-telaf', '', d)} \
"

# Following packages will be enabled later
CORE_IMAGE_EXTRA_INSTALL_remove_sa525m = "\
       qmi-shutdown-modem modem-shutdown \
       packagegroup-qti-security-test \
"

PACKAGE_EXCLUDE += "shared-mime-info openssl-bin e2fsprogs-e2fsck"
