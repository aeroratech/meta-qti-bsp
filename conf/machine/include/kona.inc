SOC_FAMILY ?= "kona"
include conf/machine/include/soc-family.inc

require conf/machine/include/arm/arch-armv8a.inc

PREFERRED_PROVIDER_virtual/kernel = "linux-msm"
PREFERRED_VERSION_linux-msm ?= "4.19"
