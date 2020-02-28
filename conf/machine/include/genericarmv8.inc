BASEMACHINE ?= "genericarmv8"
require conf/machine/include/basemachine.inc

DEFAULTTUNE ?= "aarch64"
include conf/machine/include/arm/arch-armv8.inc

PREFERRED_PROVIDER_virtual/kernel = "linux-msm"
PREFERRED_VERSION_linux-msm ?= "5.4"

LLVM_VERSION = "8.0"

PAGE_SIZE ?= '4096'

EXTRA_IMAGECMD ?= "-N 2048"

SYSTEM_SIZE_EXT4 ?= "120000000"
VM_SIZE_EXT4 ?= "170000000"
