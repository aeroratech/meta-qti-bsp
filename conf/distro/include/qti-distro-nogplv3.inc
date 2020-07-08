######################################################################
# This configuration defines an OE Linux based distribution containing
# reference stack for running nogplv3 on qti chipsets.
######################################################################

# Get basic distro configuration
require conf/distro/include/qti-distro-base.inc

DISTRO_NAME = "QTI Linux nogplv3 distro."

# inherit distro_featres_check class across the distro
INHERIT += "distro_features_check"

# Add Incompatible license details
INCOMPATIBLE_LICENSE += "GPL-3.0 LGPL-3.0 AGPL-3.0"

WHITELIST_GPL-3.0 += "bash gettext elfutils gdbm  readline m4"
PACKAGE_EXCLUDE +=   "bash gettext elfutils gdbm  readline m4"
