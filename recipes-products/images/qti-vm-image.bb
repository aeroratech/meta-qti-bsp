inherit qimage qramdisk

DEPENDS += " virtual/kernel"

ENABLE_DISPLAY = "${@d.getVar('MACHINE_SUPPORTS_DISPLAY') or "True"}"
ENABLE_TOUCH = "${@d.getVar('MACHINE_SUPPORTS_TOUCH') or "True"}"
ENABLE_SECUREMSM = "${@d.getVar('MACHINE_SUPPORTS_SECUREMSM') or "True"}"

CORE_IMAGE_EXTRA_INSTALL += " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'selinux', 'packagegroup-selinux-minimal', '', d)} \
    post-boot \
    sdcard-scripts-automount \
    e2fsprogs-mke2fs \
    procrank \
    powerapp \
"

CORE_IMAGE_EXTRA_INSTALL += " ${@bb.utils.contains('MACHINE_FEATURES', 'qti-vm-persist', 'packagegroup-qti-encryption', '', d)}"
CORE_IMAGE_EXTRA_INSTALL += " ${@oe.utils.conditional('ENABLE_DISPLAY', 'True', 'packagegroup-qti-display', '', d)}"
CORE_IMAGE_EXTRA_INSTALL += " ${@oe.utils.conditional('ENABLE_TOUCH', 'True', 'packagegroup-qti-touch', '', d)}"
CORE_IMAGE_EXTRA_INSTALL += " ${@oe.utils.conditional('ENABLE_SECUREMSM', 'True', 'packagegroup-qti-securemsm', '', d)}"

#Exclude packages
PACKAGE_EXCLUDE += "readline"
ROOTFS_POSTPROCESS_COMMAND_remove = " do_fsconfig;"
USE_DEPMOD = "0"

do_gen_partition_bin[noexec] = "1"

IMAGE_FEATURES[validitems] += "vm"
IMAGE_FEATURES += "vm"

do_compose_vmimage[recrdeptask] = "do_ramdisk_create"
do_compose_vmimage[recrdeptask] += "do_merge_dtbs"
