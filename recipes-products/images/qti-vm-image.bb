inherit qimage

DEPENDS += " virtual/kernel"

CORE_IMAGE_EXTRA_INSTALL += "\
    ${@bb.utils.contains('DISTRO_FEATURES', 'selinux', 'packagegroup-selinux-minimal', '', d)} \
    systemd-machine-units \
    packagegroup-startup-scripts \
    packagegroup-qti-display \
    packagegroup-qti-securemsm \
"

#Exclude packages
PACKAGE_EXCLUDE += "readline"
ROOTFS_POSTPROCESS_COMMAND_remove = " do_fsconfig;"

do_gen_partition_bin[noexec] = "1"
do_makeuserdata[noexec] = "1"

IMAGE_FEATURES[validitems] += "vm"
IMAGE_FEATURES += " vm"
