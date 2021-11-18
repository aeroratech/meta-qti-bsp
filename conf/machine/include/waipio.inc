SOC_FAMILY ?= "waipio"
include conf/machine/include/soc-family.inc

require conf/machine/include/arm/arch-armv8a.inc

PREFERRED_PROVIDER_virtual/kernel = "linux-msm"
PREFERRED_VERSION_linux-msm ?= "5.10"
PREFERRED_VERSION_linux-msm-headers ?= "5.10"
PREFERRED_VERSION_kernel-toolchain ?= "5.10"
PREFERRED_VERSION_dtc-android-build ?= "5.10"
