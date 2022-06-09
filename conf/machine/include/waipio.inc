SOC_FAMILY ?= "waipio"
include conf/machine/include/soc-family.inc

require conf/machine/include/arm/arch-armv8a.inc

# Set virtual providers
PREFERRED_PROVIDER_virtual/kernel = "linux-msm"
PREFERRED_PROVIDER_virtual/mkbootimg-native = "mkbootimg-gki-native"
PREFERRED_PROVIDER_virtual/dtc-native = "dtc-android-build-native"

# Set preferred versions
PREFERRED_VERSION_linux-msm = "5.10"
PREFERRED_VERSION_linux-msm-headers = "5.10"
PREFERRED_VERSION_kernel-toolchain-native = "5.10"
PREFERRED_VERSION_dtc-android-build-native = "1.6.0"
PREFERRED_VERSION_mkbootimg-gki-native = "5.10"

# Waipio abl expects boot image with header version set.
BOOT_HEADER_VERSION = "2"

# On msm-5.4 or above ufs driver supports BSG Device.
UFS_BSG_DEV_USAGE = "True"
