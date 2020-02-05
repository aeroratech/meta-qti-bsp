BASEMACHINE ?= "sdmsteppe"
require conf/machine/include/basemachine.inc

SOC_FAMILY ?= "qcs610"
include conf/machine/include/soc-family.inc

DEFAULTTUNE ?= "aarch64"
include conf/machine/include/arm/arch-armv8.inc

PREFERRED_PROVIDER_virtual/kernel = "linux-msm"
PREFERRED_VERSION_linux-msm ?= "4.14"

PAGE_SIZE ?= '4096'

# Max supported inodes
EXTRA_IMAGECMD ?= "-N 2048"

MACHINE_MNT_POINTS = "/firmware \
                      /overlay \
                      /dsp \
                      /bt_firmware \
                     "

# Sizes for EXT4 (in bytes)
SYSTEM_SIZE_EXT4 ?= "681574400"
OVERLAY_SIZE_EXT4 ?= "33554432"

# Formats of root filesystem images.
IMAGE_FSTYPES += "ext4"

# Disable some default features supported from upstream
MACHINE_FEATURES_BACKFILL_CONSIDERED += "qemu-usermode rtc"
