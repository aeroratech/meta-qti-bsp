######################################################################
# This configuration defines an OE Linux based distribution containing
# reference stack for running extended reality on qti chipsets.
######################################################################

# Get basic distro configuration
require conf/distro/include/qti-distro-base.inc

DISTRO_NAME = "QTI Linux extended realit distro."

##################################################################
# list of distro features
##################################################################
#
# drm:             Use DRM display drivers, provided machine supports it.
# fbdev:           Use FBDEV display drivers, provided machine supports it.
# opencl:          Include the Open Computing Language
# opengl:          Include the Open Graphics Library,
# pulseaudio:      Use pulseaudio audio server
# wayland:         Include the Wayland display server protocol.

DISTRO_FEATURES_append = " drm fbdev opencl opengl pulseaudio wayland"

## QTI defined distro features ##
# qti-audio-cal: Support QTI audio calibration solution
# qti-audio-encoder: Support QRI audio encoder
# qti-bluetooth: Support QTI bluetooth solution
# qti-camera:    Support QTI camera solution
# qti-mm-parser: Support QTI multimeida parsers
# qti-video-encoder: Support QTI video encode
# qti-adsp:      Support QTI adsp solution
# qti-security:      Support QTI security solution
#

DISTRO_FEATURES_append = " qti-audio-cal qti-audio-encoder qti-bluetooth qti-camera qti-mm-parser qti-video-encoder qti-adsp qti-security "

# inherit distro_featres_check class across the distro
INHERIT += "distro_features_check"

# Set selinux in disabled state
DEFAULT_ENFORCING ?= "disabled"
