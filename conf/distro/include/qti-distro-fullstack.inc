######################################################################
# This configuration defines an OE Linux based distribution containing
# full reference stack for running the system on qti chipsets.
######################################################################

# Get basic distro configuration
require conf/distro/include/qti-distro-base.inc

DISTRO_NAME = "QTI Linux full refrence stack distro."

##################################################################
# list of distro features
##################################################################
#
# wayland:  Include the Wayland display server protocol.
# opengl :  Include the Open Graphics Library,
# fbdev  :  Use fbdev display drivers

DISTRO_FEATURES   += " wayland fbdev opengl"

## QTI defined distro features ##
# qti-audio:     Support QTI audio solution
# qti-bluetooth: Support QTI bluetooth solution
# qti-camera:    Support QTI camera solution
# qti-display:   Support QTI display solution
# qti-video:     Support QTI video solution
#

DISTRO_FEATURES   += " qti-audio qti-bluetooth qti-camera qti-display qti-video"
