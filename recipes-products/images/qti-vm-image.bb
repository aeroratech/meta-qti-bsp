inherit qimage qramdisk

DEPENDS += " virtual/kernel"

ENABLE_DISPLAY = "${@d.getVar('MACHINE_SUPPORTS_DISPLAY') or "True"}"
ENABLE_SECUREMSM = "${@d.getVar('MACHINE_SUPPORTS_SECUREMSM') or "True"}"

CORE_IMAGE_EXTRA_INSTALL += " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'selinux', 'packagegroup-selinux-minimal', '', d)} \
    packagegroup-startup-scripts \
    e2fsprogs-mke2fs \
    powerapp \
    procrank \
"
CORE_IMAGE_EXTRA_INSTALL += " ${@oe.utils.conditional('ENABLE_DISPLAY', 'True', 'packagegroup-qti-display', '', d)}"
CORE_IMAGE_EXTRA_INSTALL += " ${@oe.utils.conditional('ENABLE_SECUREMSM', 'True', 'packagegroup-qti-securemsm', '', d)}"

#Exclude packages
PACKAGE_EXCLUDE += "readline"
ROOTFS_POSTPROCESS_COMMAND_remove = " do_fsconfig;"
USE_DEPMOD = "0"

do_gen_partition_bin[noexec] = "1"

IMAGE_FEATURES[validitems] += "vm"
IMAGE_FEATURES += "vm"
