require conf/machine/include/qcs40x.inc

# Build architecture configuration
DEFAULTTUNE = "aarch64"

PREFERRED_PROVIDER_virtual/kernel = "linux-msm"
PREFERRED_VERSION_linux-msm = "5.4"
PREFERRED_VERSION_linux-msm-headers = "5.4"

KERNEL_IMAGETYPE = "Image.gz"
KERNEL_BASE = "0x80000000"
KERNEL_TAGS_OFFSET = "0x1e00000"
KERNEL_DYNAMIC_DEFCONFIG = "True"

SERIAL_CONSOLES = "115200;ttyMSM0"

# Bootloader configuration
EXTRA_IMAGEDEPENDS += "edk2"

# Fixed load address to support multiple DDR configuration
ABL_LOAD_ADDRESS = "0X8B500000"

# MACHINE_FEATURES ##
# qti-adsp:               Machine supports QTI adsp solution
# qti-cdsp:               Machine supports QTI cdsp solution
# qti-ab-boot:            Machine supports a/b boot
# qti-security:           Machine supports QTI security solution
# dm-verity-bootloader:   Machine supports bootloader-based dm-verity implementation
# qti-wifi:               Machine supports QTI WiFi solution
# qti-audio:              Machine supports QTI audio solution
# qti-bluetooth:          Machine supports QTI bluetooth solution
# qti-sensors:            Machine supports sensors qti solution
# qti-location:           Machine supports Location solution
# qti-data-modem:         Machine supports QTI data modem solution
# qti-external-ap         Machine supports QTI external AP solution
# qti-cv2x:               Machine supports QTI Cellular V2X solution

MACHINE_FEATURES += "qti-security qti-location qti-external-ap"

MACHINE_SUPPORTS_PDMAPPER = "False"
MACHINE_SUPPORTS_INIT_RAMDISK = "False"

USBCOMPOSITION = "901D"

PREFERRED_VERSION_protobuf = "3.11.4"
PREFERRED_VERSION_protobuf-native = "3.11.4"
PREFERRED_VERSION_iproute2 = "5.5.0"

# On msm-5.4 or above ufs driver supports BSG Device.
UFS_BSG_DEV_USAGE = "True"
