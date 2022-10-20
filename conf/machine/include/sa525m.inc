BASEMACHINE ?= "sa525m"
require conf/machine/include/basemachine.inc

DEFAULTTUNE ?= "aarch64"
include conf/machine/include/arm/arch-armv8a.inc

PREFERRED_PROVIDER_virtual/kernel = "linux-msm"
PREFERRED_PROVIDER_virtual/mkbootimg-native = "mkbootimg-gki-native"
PREFERRED_PROVIDER_virtual/dtc-native = "dtc-android-build-native"
PREFERRED_VERSION_linux-msm ?= "5.15"
PREFERRED_VERSION_linux-msm-headers ?= "5.15"
PREFERRED_VERSION_kernel-toolchain ?= "5.15"
PREFERRED_VERSION_dtc-android-build ?= "5.15"
PREFERRED_VERSION_mkbootimg-gki-native ?= "5.15"
PREFERRED_VERSION_dtc-android-build-native ?= "5.15"
SERIAL_CONSOLES = "115200;ttyMSM0"
KERNEL_IMAGETYPE = "Image"
KERNEL_BASE = "0xa8000000"
KERNEL_TAGS_OFFSET = "0x1e00000"
KERNEL_CONFIG ?= "vendor/sa525_defconfig"
KERNEL_CONFIG_qti-distro-debug ?= "vendor/sa525-debug_defconfig"
KERNEL_CMD_PARAMS = "ro rootwait console=ttyMSM0,115200,n8 androidboot.hardware=qcom msm_rtb.filter=0x237 androidboot.console=ttyMSM0 lpm_levels.sleep_disabled=1 firmware_class.path=/lib/firmware/updates service_locator.enable=1 net.ifnames=0"
KERNEL_VARIANT = ""
KERNEL_VARIANT_qti-distro-debug = "debug_"
KERNEL_VARIANT_qti-distro-perf = "perf_"
KERNEL_DTB_NAMES = "dtbs/dtb.img"

MACHINE_USES_KERNEL_PREBUILTS = "True"
KERNEL_PREBUILT_PATH ?= "${WORKSPACE}/kernel-5.15/out/msm-kernel-sa525m-${KERNEL_VARIANT}defconfig/dist"
KERNEL_OUT_PATH ?= "${WORKSPACE}/kernel-5.15/out/msm-kernel-sa525m-${KERNEL_VARIANT}defconfig"
KERNEL_BUILD_CONFIG ?= "msm-kernel/build.config.msm.sa525m"

DEFAULT_ENFORCING = "permissive"

# MACHINE_FEATURES ##
# qti-adsp:               Machine supports QTI adsp solution
# qti-cdsp:               Machine supports QTI cdsp solution
# qti-ab-boot:            Machine supports a/b boot
# qti-security:           Machine supports QTI security solution
# qti-wifi:               Machine supports QTI WiFi solution
# qti-audio:              Machine supports QTI audio solution
# qti-bluetooth:          Machine supports QTI bluetooth solution
# qti-sensors:            Machine supports sensors qti solution
# qti-location:           Machine supports Location solution
# qti-data-modem:         Machine supports QTI data modem solution

MACHINE_FEATURES += "qti-sdx dm-verity-none qti-sensors"

MACHINE_MNT_POINTS = " \
    /dsp \
    /firmware \
    /systemrw \
    /persist \
    /data \
    /cache \
"

PAGE_SIZE ?= '4096'
EXTRA_IMAGECMD ?= "-N 2048"

MACHINE_SUPPORTS_DTBO = "True"
MACHINE_SUPPORTS_PDMAPPER = "False"
MACHINE_SUPPORTS_INIT_RAMDISK = "False"
TOYBOX_RAMDISK = "False"
MACHINE_SUPPORTS_ANDROID_PROPERTIES = "False"

USBCOMPOSITION = "90DB"

# On msm-5.4 or above ufs driver supports BSG Device.
UFS_BSG_DEV_USAGE = "True"

PREFERRED_VERSION_protobuf = "3.11.4"
PREFERRED_VERSION_protobuf-native = "3.11.4"
PREFERRED_VERSION_iproute2 = "5.5.0"

# Fixes for boot image dtb appending
BOOT_HEADER_VERSION = "2"
