BASEMACHINE ?= "genericarmv8"
require conf/machine/include/basemachine.inc

DEFAULTTUNE ?= "aarch64"
include conf/machine/include/arm/arch-armv8a.inc

PREFERRED_PROVIDER_virtual/kernel = "linux-dummy"
PREFERRED_VERSION_linux-msm ?= "5.10"
PREFERRED_VERSION_linux-msm-headers ?= "5.10"

LLVM_VERSION = "8.0"

PAGE_SIZE ?= '4096'

EXTRA_IMAGECMD ?= "-N 2048"

SYSTEM_SIZE_EXT4 ?= "225000000"
USERDATA_SIZE_EXT4 ?= "25000000"
VM_SIZE_EXT4 ?= "270000000"
