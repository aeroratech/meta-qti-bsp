BASEMACHINE ?= "qrb5165"
require conf/machine/include/basemachine.inc

SOC_FAMILY ?= "kona"
include conf/machine/include/soc-family.inc

require conf/machine/include/arm/arch-armv8a.inc

PREFERRED_PROVIDER_virtual/kernel = "linux-msm"
PREFERRED_VERSION_linux-msm ?= "4.19"

PAGE_SIZE ?= '4096'

# Max supported inodes
EXTRA_IMAGECMD ?= "-N 2048"

MACHINE_MNT_POINTS = "/firmware \
                      /dsp \
                      /bt_firmware \
                     "

# Sizes for EXT4 (in bytes)
SYSTEM_SIZE_EXT4 ?= "524288000"
USERDATA_SIZE_EXT4 ?= "33554432"

# Formats of root filesystem images.
IMAGE_FSTYPES += "ext4"

# Disable some default features supported from upstream
MACHINE_FEATURES_BACKFILL_CONSIDERED += "qemu-usermode rtc"
