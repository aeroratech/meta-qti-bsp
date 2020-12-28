BASEMACHINE ?= "sxr2130"
require conf/machine/include/basemachine.inc

include conf/machine/include/kona.inc

PAGE_SIZE ?= '4096'

# Max supported inodes
EXTRA_IMAGECMD ?= "-N 2048"

MACHINE_MNT_POINTS = "/firmware \
                      /dsp \
                      /bt_firmware \
                      /overlay \
                      /persist \
                     "

# Sizes for EXT4 (in bytes)
SYSTEM_SIZE_EXT4 ?= "524288000"
USERDATA_SIZE_EXT4 ?= "2147483648"

# Formats of root filesystem images.
IMAGE_FSTYPES += "ext4"

# Disable some default features supported from upstream
MACHINE_FEATURES_BACKFILL_CONSIDERED += "qemu-usermode rtc"
