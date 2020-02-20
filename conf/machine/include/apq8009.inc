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
# Keep it same as defined in *.partition.conf, for the dm verity to work
SYSTEM_SIZE_EXT4 ?= "536870912"
OVERLAY_SIZE_EXT4 ?= "2100000000"

# Formats of root filesystem images.
IMAGE_FSTYPES += "ext4"

# Disable some default features supported from upstream
MACHINE_FEATURES_BACKFILL_CONSIDERED += "qemu-usermode rtc"

# This flag is valid only when "dm-verity" feature is enabled.
# Pick dm-android-verity kernel driver (defined by CONFIG_DM_ANDROID_VERITY=y)
# that is supported on 4.9 and earlier kernel versions.
# Otherwise, dm-verity kernel driver is picked, by default.
LEGACY_DM_ANDROID_VERITY_DRIVER = "1"

# Use legacy ion implementation if msm kernel version is 4.9 or below
LEGACY_ION_USAGE = "True"
