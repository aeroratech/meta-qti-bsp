require conf/machine/include/basemachine.inc

DEFAULTTUNE ?= "aarch64"
include conf/machine/include/arm/arch-armv8a.inc

PREFERRED_PROVIDER_virtual/kernel ?= "linux-msm"
PREFERRED_PROVIDER_virtual/mkbootimg-native ?= "mkbootimg-gki-native"
PREFERRED_PROVIDER_virtual/dtc-native ?= "dtc-android-build-native"
PREFERRED_PROVIDER_virtual/mkdtimg-native ?= "mkdtimg-gki-native"
PREFERRED_VERSION_linux-msm ?= "5.15"
PREFERRED_VERSION_linux-msm-headers ?= "5.15"
PREFERRED_VERSION_kernel-toolchain ?= "5.15"
PREFERRED_VERSION_dtc-android-build ?= "5.15"
PREFERRED_VERSION_mkbootimg-gki-native ?= "5.15"
PREFERRED_VERSION_dtc-android-build-native ?= "5.15"
PREFERRED_VERSION_mkdtimg-gki-native ?= "5.15"

KERNEL_VARIANT = ""
KERNEL_VARIANT_qti-distro-debug = "debug_"
KERNEL_VARIANT_qti-distro-perf = "perf_"

PAGE_SIZE ?= '4096'

EXTRA_IMAGECMD ?= "-N 2048"

KERNEL_IMAGETYPE = "Image"
KERNEL_CMD_PARAMS = ""
KERNEL_DYNAMIC_DEFCONFIG = "True"
SERIAL_CONSOLE = "115200 hvc0"

MACHINE_FEATURES += "qti-vm qti-location qti-sensors"

MACHINE_SUPPORTS_INIT_RAMDISK = "False"
TOYBOX_RAMDISK = "False"
MACHINE_USES_KERNEL_PREBUILTS = "True"
MACHINE_SUPPORTS_USB = "False"
MACHINE_SUPPORTS_ANDROID_PROPERTIES = "False"
MACHINE_SUPPORTS_DISPLAY = "False"
MACHINE_SUPPORTS_SECUREMSM = "False"
MACHINE_MNT_POINTS = ""
ENABLE_ADB = "False"

# Formats of root filesystem images.
IMAGE_FSTYPES += "ext4 ubi"
IMAGE_INIT_MANAGER = "systemd"

SYSTEMIMAGE_TARGET = "system.img"
VMIMAGE_TARGET = "vm-bootsys.img"

# UBI arguments
UBINIZE_ARGS = "-m 4096 -p 256KiB -s 4096"
MKUBIFS_ARGS = "-m 4096 -e 253952 -c 2146 -F"

# On msm-5.4 or above ufs driver supports BSG Device.
UFS_BSG_DEV_USAGE = "True"
