BASEMACHINE ?= "apq8009"
require conf/machine/include/basemachine.inc

SOC_FAMILY ?= "msm8909"
include conf/machine/include/soc-family.inc

DEFAULTTUNE ?= "armv7ahf-neon"

include conf/machine/include/tune-cortexa7.inc

PREFERRED_PROVIDER_virtual/kernel = "linux-msm"
PREFERRED_VERSION_linux-msm ?= "4.9"

SERIAL_CONSOLE ?= "115200 ttyHSL0"

PAGE_SIZE ?= '4096'

# Max supported inodes
EXTRA_IMAGECMD ?= "-N 2048"

MACHINE_MNT_POINTS = "/firmware \
                      /overlay \
                     "

# Sizes for EXT4 (in bytes)
SYSTEM_SIZE_EXT4 ?= "524288000"
OVERLAY_SIZE_EXT4 ?= "2100000000"

# Formats of root filesystem images.
IMAGE_FSTYPES += "ext4"

MACHINE_FEATURES_BACKFILL_CONSIDERED += "rtc"
