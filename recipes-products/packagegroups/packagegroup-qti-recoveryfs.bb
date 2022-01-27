SUMMARY = "Grouping of programs for recovery file system on Embedded Linux System"
DESCRIPTION = "Package group to bring in packages for recovery file system"
LICENSE = "BSD-3-Clause"

inherit packagegroup

PROVIDES = "${PACKAGES}"

PACKAGES = ' \
    packagegroup-qti-recoveryfs \
    '

# Startup scripts needed during device bootup
RDEPENDS_packagegroup-qti-recoveryfs = " \
            adbd \
            coreutils \
            find-recovery-partitions \
            mtd-utils-ubifs \
            logd \
            recovery \
            usb-composition-recovery \
            ${@bb.utils.contains('MACHINE_FEATURES', 'qti-sdx', 'systemd-machine-units-recovery', '', d)} \
            ${@bb.utils.contains('DISTRO_FEATURES', 'ota-package-verification', 'openssl', '', d)} \
            ${@bb.utils.contains('DISTRO_FEATURES', 'ota-package-verification', 'openssl-bin', '', d)} \
            ${@bb.utils.contains('DISTRO_FEATURES', 'selinux', 'packagegroup-selinux-minimal', '', d)} \
"
