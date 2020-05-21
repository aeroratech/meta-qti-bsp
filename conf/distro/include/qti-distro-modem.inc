######################################################################
# This configuration defines an OE Linux based distribution containing
# reference stack for running modem on qti chipsets.
######################################################################

# Get basic distro configuration
require conf/distro/include/qti-distro-base.inc

DISTRO_NAME = "QTI Linux modem distro."

# inherit distro_featres_check class across the distro
INHERIT += "distro_features_check"

# Add Incompatible license details
INCOMPATIBLE_LICENSE += "GPL-3.0 LGPL-3.0 AGPL-3.0"
WHITELIST_GPL-3.0 += "coreutils gettext bash grep m4 findutils elfutils gdbm readline"
PACKAGE_EXCLUDE += "gdb gdbserver gdbm gettext m4 elfutils readline"