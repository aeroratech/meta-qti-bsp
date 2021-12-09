BASEMACHINE ?= "sdmsteppe"
require conf/machine/include/basemachine.inc

SOC_FAMILY ?= "qcs610"
include conf/machine/include/soc-family.inc

include conf/machine/include/arm/arch-armv8a.inc

PREFERRED_PROVIDER_virtual/kernel = "linux-msm"
PREFERRED_VERSION_linux-msm ?= "5.4"
PREFERRED_VERSION_linux-msm-headers ?= "5.4"

PAGE_SIZE ?= '4096'

# Max supported inodes
EXTRA_IMAGECMD ?= "-N 2048"

MACHINE_MNT_POINTS = "/firmware \
                      /overlay \
                      /dsp \
                      /bt_firmware \
                      /persist \
                     "

# Sizes for EXT4 (in bytes)
SYSTEM_SIZE_EXT4  ?= "1050214400"
USERDATA_SIZE_EXT4 ?= "8589934592"

# Formats of root filesystem images.
IMAGE_FSTYPES += "ext4"

# Disable some default features supported from upstream
MACHINE_FEATURES_BACKFILL_CONSIDERED += "qemu-usermode rtc"
