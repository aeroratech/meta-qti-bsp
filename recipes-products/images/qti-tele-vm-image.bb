inherit qimage qramdisk

DEPENDS += "virtual/kernel"

ENABLE_SECUREMSM = "${@d.getVar('MACHINE_SUPPORTS_SECUREMSM') or "True"}"

CORE_IMAGE_EXTRA_INSTALL += " \
    e2fsprogs-mke2fs \
    packagegroup-android-utils \
    ${@bb.utils.contains('DISTRO_FEATURES', 'selinux', 'packagegroup-selinux-minimal', '', d)} \
    ${@oe.utils.conditional('ENABLE_SECUREMSM', 'True', 'packagegroup-qti-securemsm', '', d)} \
    post-boot \
    systemd-machine-units \
    ${@bb.utils.contains('MACHINE_FEATURES', 'qti-location', 'packagegroup-qti-location-vm', '', d)} \
"

# Exclude packages
PACKAGE_EXCLUDE += "readline"

ROOTFS_POSTPROCESS_COMMAND_remove = " do_fsconfig;"
USE_DEPMOD = "0"

do_gen_partition_bin[noexec] = "1"

do_compose_vmimage[recrdeptask] = "do_ramdisk_create"

IMAGE_FEATURES[validitems] += "vm"
IMAGE_FEATURES += "vm"
