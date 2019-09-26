#############################################################################
#@COMMENT: This distribution configuration defines an OE Linux based
#@COMMENT: distribution. The matching buildable image target (machine-image)
#@COMMENT: basically consists of: libc, busybox, udev and a few
#@COMMENT: init scripts for running up the system on qti chipsets.
#############################################################################

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

##################################################################
# Optimization flags.
##################################################################
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

PREFERRED_VERSION_readline = "5.2"

# Retain existing directory structure for msm or mdm distro images.
DEPLOY_NAME_BASE  = "${MACHINE}${@bb.utils.contains_any('DISTRO', 'msm mdm', '', '-' + d.getVar('DISTRO'), d)}"
DEPLOY_NAME      ?= "${DEPLOY_NAME_BASE}"
DEPLOY_DIR_IMAGE  = "${DEPLOY_DIR}/images/${DEPLOY_NAME}"

# Add qti custom permissions
USERADDEXTENSION = "qpermissions"

# list of distro features
# use systemd init manager.
# use selinux for mandatory access control(MAC).
# Embedded Application Binary Interface(EABI).
# Basic networking tools - ipv6,ipv4.
# LargeFile support in Linux.
# Linker can detect thumb function called from ARM state and alter call, return sequences, insert
# interworking decoratives to change processor state as necessary.
# Extended attributes(xattr) to filesystem.
# Distro features specific to C library.
DISTRO_FEATURES   += " selinux systemd eabi ipv6 ipv4 largefile thumb-interwork xattr ${DISTRO_FEATURES_LIBC}"
#selinux in disabled state
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
