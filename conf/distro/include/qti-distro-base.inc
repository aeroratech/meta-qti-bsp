######################################################################
# This configuration defines an OE Linux based distribution containing
# basic libraries and utilities like libc, busybox, systemd, udev and
# a few init scripts required for running the system on qti chipsets.
######################################################################

# Pull in security flags
require ${COREBASE}/meta-qti-bsp/conf/distro/include/security_flags.inc

# DISTRO CONFIGURATION
DISTRO_VERSION ?= "${BUILDNAME}"

DISTROOVERRIDES =. "qti-distro-base:"

# DISTRO FEATURE SELECTION
MICRO_GOLD ?= "ld-is-gold"

USE_DEVFS = "0"

# Use Debian naming scheme for library (.so) files
INHERIT += "recipe_sanity"

# TOOLCHAIN
PREFERRED_VERSION_autoconf = "2.68"
ARM_INSTRUCTION_SET       ?= "arm"

######################################################################
# Optimization flags.
######################################################################
COMMON_OPTIMIZATION = " \
  -g -Wa,--noexecstack -fexpensive-optimizations \
  -frename-registers -ftree-vectorize \
  -finline-functions -finline-limit=64 \
  -Wno-error=maybe-uninitialized -Wno-error=unused-result \
"

FULL_OPTIMIZATION  = " -O2 ${COMMON_OPTIMIZATION} "
DEBUG_OPTIMIZATION = " ${FULL_OPTIMIZATION} "

# NLS
USE_NLS = "no"
USE_NLS_glib-2.0 = "yes"
USE_NLS_glib-2.0-native = "yes"
USE_NLS_gcc-cross = "no"

# Disable GIO module cache creation
GIO_MODULE_PACKAGES=""

# Disable binary locale generation
ENABLE_BINARY_LOCALE_GENERATION = "0"

#Allow library symlinks to exist alongside soname files
PACKAGE_SNAP_LIB_SYMLINKS = "0"

# Don't install ldconfig and associated gubbins
USE_LDCONFIG = "0"
LDCONFIGDEPEND = ""
COMMERCIAL_LICENSE_DEPENDEES = ""

# Directory structure for distro images.
DEPLOY_NAME      ?= "${MACHINE}-${DISTRO}"
DEPLOY_DIR_IMAGE  = "${DEPLOY_DIR}/images/${DEPLOY_NAME}"

# Add qti custom user permissions
USERADDEXTENSION = "qpermissions"

##################################################################
# list of distro features
##################################################################
# eabi:       Embedded Application Binary Interface(EABI).
# ipv4,ipv6:  Basic networking tools - ipv6,ipv4.
# largefile:  LargeFile support in Linux.
# selinux:    Use selinux for mandatory access control.
# systemd:    Use systemd init manager.
# thumb-interwork: Linker can detect thumb function called from ARM
#             state and alter call, return sequences etc to change
#             processor state as necessary.
# xattr:      Extended attributes(xattr) to filesystem.
DISTRO_FEATURES   += " selinux systemd eabi ipv6 ipv4 largefile thumb-interwork xattr ${DISTRO_FEATURES_LIBC}"

## QTI Defined distro features ##
# emmc-boot:  Support eMMC device
# qti-wifi:   Support QTI WiFi solution
#
DISTRO_FEATURES   += " emmc-boot qti-wifi"

# Set selinux in disabled state
DEFAULT_ENFORCING ?= "disabled"

# Consider sysVinit for backfilling systemd.
DISTRO_FEATURES_BACKFILL_CONSIDERED += "sysvinit"
VIRTUAL-RUNTIME_dev_manager = "udev"
VIRTUAL-RUNTIME_init_manager = "systemd"

# Change Image features for systemd.
IMAGE_DEV_MANAGER = "udev"
IMAGE_INIT_MANAGER = "systemd"
IMAGE_INITSCRIPTS = ""

RM_WORK_EXCLUDE += "make-mod-scripts"
