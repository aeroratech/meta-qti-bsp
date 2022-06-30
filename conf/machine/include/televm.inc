require conf/machine/include/basemachine.inc

DEFAULTTUNE ?= "aarch64"
include conf/machine/include/arm/arch-armv8a.inc

PREFERRED_PROVIDER_virtual/kernel = "linux-msm"
PREFERRED_VERSION_linux-msm ?= "5.4"
PREFERRED_VERSION_linux-msm-headers ?= "5.4"

PAGE_SIZE ?= '4096'

EXTRA_IMAGECMD ?= "-N 2048"

KERNEL_IMAGETYPE = "Image"
KERNEL_CMD_PARAMS = ""
KERNEL_DYNAMIC_DEFCONFIG = "True"
SERIAL_CONSOLE = "115200 hvc0"

MACHINE_SUPPORTS_USB = "False"
MACHINE_SUPPORTS_ANDROID_PROPERTIES = "False"
MACHINE_SUPPORTS_DISPLAY = "False"
MACHINE_SUPPORTS_SECUREMSM = "False"
MACHINE_MNT_POINTS = ""

# Formats of root filesystem images.
IMAGE_FSTYPES += "ext4"
IMAGE_INIT_MANAGER = "systemd"

SYSTEMIMAGE_TARGET = "system.img"
VMIMAGE_TARGET = "vm-bootsys.img"
VMIMAGE_FLAVOR = "televm"

# On msm-5.4 or above ufs driver supports BSG Device.
UFS_BSG_DEV_USAGE = "True"
