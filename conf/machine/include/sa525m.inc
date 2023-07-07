BASEMACHINE ?= "sa525m"
require conf/machine/include/basemachine.inc

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
PREFERRED_VERSION_qcrosvm = "1.1"
PREFERRED_VERSION:securemsmdlkm ?= "1.0"
SERIAL_CONSOLES = "115200;ttyMSM0"
KERNEL_IMAGETYPE = "Image"
KERNEL_BASE = "0xa8000000"
KERNEL_TAGS_OFFSET = "0x1e00000"
KERNEL_CONFIG ?= "vendor/sa525_defconfig"
KERNEL_CONFIG_qti-distro-debug ?= "vendor/sa525-debug_defconfig"
CONSOLE_PARAM ?= "console=ttyMSM0,115200,n8 no_console_suspend=1"
CONSOLE_PARAM_qti-distro-perf ?= "console=ttyMSM0,115200,n8 no_console_suspend=1 loglevel=0 systemd.log_level=0 systemd.show_status=0"
KERNEL_CMD_PARAMS = "ro rootwait ${CONSOLE_PARAM} androidboot.console=ttyMSM0 lpm_levels.sleep_disabled=1 firmware_class.path=/lib/firmware/updates,/vm-bootsys/boot service_locator.enable=1 net.ifnames=0"
KERNEL_VARIANT ??= ""
KERNEL_VARIANT_qti-distro-debug ??= "debug_"
KERNEL_VARIANT_qti-distro-perf ??= "perf_"
KERNEL_DTB_NAMES = "dtbs/dtb.img"

MACHINE_USES_KERNEL_PREBUILTS = "True"
KERNEL_PREBUILT_PATH ?= "${WORKSPACE}/kernel-5.15/out/msm-kernel-sa525-${KERNEL_VARIANT}defconfig/dist"
KERNEL_OUT_PATH ?= "${WORKSPACE}/kernel-5.15/out/msm-kernel-sa525-${KERNEL_VARIANT}defconfig"
KERNEL_BUILD_CONFIG ?= "msm-kernel/build.config.msm.sa525"


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
# qti-mvm:                Machine supports QTI MVM solution
# qseecompat:             Machine supports qseecom compat solution
# qti-tzlog:              Machine supports tz/qsee logs
# qti-smciqseecomd:       Machine supports smcinvoke based listeners
# android-binder:         Machine supports android binder
# dm-verity-initramfs-v4: Machine supports Initramfs and dm-verity working with AVB
# qti-nad-telaf:          Machine supports telematics application framework
# qti-nad-mrc             Machine supports mrcd feature

MACHINE_FEATURES += "qti-sdx dm-verity-initramfs-v4 qti-sensors qti-mvm qti-security qseecompat qti-tzlog qti-data-modem qti-location qti-audio qti-smciqseecomd qti-recovery qti-wwan-plus-cv2x qti-wlan qti-bluetooth qwesd android-binder qti-c2c qti-cv2x-compensator qti-dynamic-tsensreset qti-nad-telaf qti-nad-mrc qti-softsku"

CONFLICT_MACHINE_FEATURES += "qti-cv2x"

MACHINE_MNT_POINTS = " \
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

# Fixes for boot image dtb appending
BOOT_HEADER_VERSION = "2"
