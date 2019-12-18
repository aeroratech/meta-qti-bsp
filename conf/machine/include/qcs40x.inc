BASEMACHINE ?= "qcs40x"
require conf/machine/include/basemachine.inc

SOC_FAMILY ?= "qcs405"
include conf/machine/include/soc-family.inc

DEFAULTTUNE ?= "aarch64"
include conf/machine/include/arm/arch-armv8.inc

PREFERRED_PROVIDER_virtual/kernel = "linux-msm"
PREFERRED_VERSION_linux-msm ?= "4.14"

LLVM_VERSION = "6.0"

PAGE_SIZE ?= '4096'

EXTRA_IMAGECMD ?= "-N 2048"

MACHINE_MNT_POINTS = "/dsp \
                      /firmware \
                      /overlay \
                     "

# Sizes for EXT4 (in bytes)
SYSTEM_SIZE_EXT4 ?= "681574400"
OVERLAY_SIZE_EXT4 ?= "33554432"

# Formats of root filesystem images
IMAGE_FSTYPES += "ext4"
