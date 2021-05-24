inherit qimage

DEPENDS += " virtual/kernel"

CORE_IMAGE_EXTRA_INSTALL += " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'selinux', 'packagegroup-selinux-minimal', '', d)} \
    packagegroup-startup-scripts \
"
CORE_IMAGE_EXTRA_INSTALL += "packagegroup-qti-display"

#Exclude packages
PACKAGE_EXCLUDE += "readline"
ROOTFS_POSTPROCESS_COMMAND_remove = " do_fsconfig;"
USE_DEPMOD = "0"

do_gen_partition_bin[noexec] = "1"

IMAGE_FEATURES[validitems] += "vm"
IMAGE_FEATURES += " vm"
