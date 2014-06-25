# List of FOSS packages installed onto the root file system as specified by the user.
require ${MACHINE}-image.inc

IMAGE_LINGUAS = ""

# Use busybox as login manager
IMAGE_LOGIN_MANAGER = "busybox-static"

# Include minimum init and init scripts
IMAGE_DEV_MANAGER = "busybox-static-mdev"
IMAGE_INIT_MANAGER = "sysvinit sysvinit-pidof"
IMAGE_INITSCRIPTS = ""

inherit core-image

# Variables for switching to ubifs (for system partition)
MKUBIFS_ARGS = "-m 2048 -e 126976 -c 300 -F"
