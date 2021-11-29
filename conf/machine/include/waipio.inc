SOC_FAMILY ?= "waipio"
include conf/machine/include/soc-family.inc

require conf/machine/include/arm/arch-armv8a.inc

# Set virtual providers
PREFERRED_PROVIDER_virtual/kernel = "linux-msm"

# Set preferred versions
PREFERRED_VERSION_linux-msm = "5.10"
PREFERRED_VERSION_linux-msm-headers = "5.10"
PREFERRED_VERSION_kernel-toolchain-native = "5.10"
PREFERRED_VERSION_dtc-android-build-native = "1.6.0"
