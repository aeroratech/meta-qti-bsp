inherit qimage

DEPENDS += " virtual/kernel"

CORE_IMAGE_EXTRA_INSTALL += "\
"

#Exclude packages
PACKAGE_EXCLUDE += "readline"
ROOTFS_POSTPROCESS_COMMAND_remove = " do_fsconfig;"

do_gen_partition_bin[noexec] = "1"
do_makeoverlay[noexec] = "1"

IMAGE_FEATURES[validitems] += "vm"
IMAGE_FEATURES += " vm"
