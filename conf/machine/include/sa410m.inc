BASEMACHINE ?= "sa410m"
require conf/machine/include/basemachine.inc

SOC_FAMILY ?= "bengal"
include conf/machine/include/soc-family.inc

DEFAULTTUNE ?= "aarch64"
include conf/machine/include/arm/arch-armv8a.inc

PREFERRED_PROVIDER_virtual/kernel = "linux-msm"
PREFERRED_PROVIDER_virtual/mkbootimg-native = "mkbootimg-gki-native"
PREFERRED_PROVIDER_virtual/dtc-native = "dtc-android-build-native"
PREFERRED_PROVIDER_virtual/mkdtimg-native = "mkdtimg-gki-native"
PREFERRED_VERSION_linux-msm = "5.15"
PREFERRED_VERSION_linux-msm-headers = "5.15"
PREFERRED_VERSION_kernel-toolchain = "5.15"
PREFERRED_VERSION_dtc-android-build = "5.15"
PREFERRED_VERSION_mkbootimg-gki-native = "5.15"
PREFERRED_VERSION_dtc-android-build-native = "5.15"
PREFERRED_VERSION_mkdtimg-gki-native = "5.15"
SERIAL_CONSOLES = "115200;ttyMSM0"
KERNEL_IMAGETYPE = "Image"
KERNEL_BASE = "0x40000000"
KERNEL_TAGS_OFFSET = "0x1e00000"
KERNEL_DYNAMIC_DEFCONFIG = "True"
KERNEL_CONFIG ?= "vendor/sa410m_auto_defconfig"
KERNEL_CONFIG_qti-distro-debug ?= "vendor/sa410m_auto-debug_defconfig"
KERNEL_CMD_PARAMS = "noinitrd ro rootwait console=ttyMSM0,115200,n8 no_console_suspend=1 androidboot.hardware=qcom androidboot.console=ttyMSM0 lpm_levels.sleep_disabled=1 service_locator.enable=1 firmware_class.path=/lib/firmware/updates msm_rtb.filter=0x237 earlycon=qcom_geni,0x4a90000 systemd.setenv="SLOT_SUFFIX"="_a""

KERNEL_VARIANT = ""
KERNEL_VARIANT_qti-distro-debug = "debug_"
KERNEL_VARIANT_qti-distro-perf = "perf_"

MACHINE_SUPPORTS_DTBO = "True"
KERNEL_DTB_NAMES      = "dtbs/dtb.img"

MACHINE_USES_KERNEL_PREBUILTS = "True"
KERNEL_PREBUILT_PATH ?= "${WORKSPACE}/kernel-5.15/out/msm-kernel-sa410m_auto-${KERNEL_VARIANT}defconfig/dist"
KERNEL_OUT_PATH ?= "${WORKSPACE}/kernel-5.15/out/msm-kernel-sa410m_auto-${KERNEL_VARIANT}defconfig"
KERNEL_BUILD_CONFIG ?= "msm-kernel/build.config.msm.sa410m_auto"

# Bootloader configuration
#EXTRA_IMAGEDEPENDS += "edk2"

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

MACHINE_FEATURES += "qti-ab-boot qti-sdx nossd_listener dm-verity-none qti-remoteproc qti-sensors qti-qseecom qti-tzlog qti-security"

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

MACHINE_SUPPORTS_INIT_RAMDISK = "False"
MACHINE_SUPPORTS_ANDROID_PROPERTIES = "False"
MACHINE_SUPPORTS_USB_AUTOSUSPEND = "False"

USBCOMPOSITION = "90DB"

# On msm-5.4 or above ufs driver supports BSG Device.
UFS_BSG_DEV_USAGE = "True"

PREFERRED_VERSION_protobuf = "3.11.4"
PREFERRED_VERSION_protobuf-native = "3.11.4"
PREFERRED_VERSION_iproute2 = "5.5.0"

# Fixes for boot image dtb appending
BOOT_HEADER_VERSION = "2"
