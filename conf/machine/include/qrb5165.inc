BASEMACHINE ?= "qrb5165"
require conf/machine/include/basemachine.inc

SOC_FAMILY ?= "qrb5165"
include conf/machine/include/soc-family.inc

require conf/machine/include/arm/arch-armv8.inc

PREFERRED_PROVIDER_virtual/kernel = "linux-msm"
PREFERRED_VERSION_linux-msm ?= "4.19"
MACHINE_FEATURES_BACKFILL_CONSIDERED += "qemu-usermode"

SERIAL_CONSOLE ?= "115200 ttyMSM0"

PAGE_SIZE ?= '4096'

# Max supported inodes
EXTRA_IMAGECMD ?= "-N 2048"

MACHINE_MNT_POINTS = "/firmware \
                      /overlay \
                     "

# Sizes for EXT4 (in bytes)
SYSTEM_SIZE_EXT4 ?= "524288000"
OVERLAY_SIZE_EXT4 ?= "33554432"

# Formats of root filesystem images.
IMAGE_FSTYPES += "ext4"
