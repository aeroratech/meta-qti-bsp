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
# drm:             Use DRM display drivers, provided machine supports it.
# dm-verity:       Support block integrity check on system image
# fbdev:           Use FBDEV display drivers, provided machine supports it.
# opencl:          Include the Open Computing Language
# opengl:          Include the Open Graphics Library,
# pulseaudio:      Use pulseaudio audio server
# selinux:         Use selinux for mandatory access control.
# tensorflow-lite: Include the tensorflow lite inference engine.
# wayland:         Include the Wayland display server protocol.

DISTRO_FEATURES_append = " drm dm-verity fbdev opencl opengl pulseaudio selinux tensorflow-lite wayland"

## QTI defined distro features ##
# qti-audio:     Support QTI audio solution
# qti-bluetooth: Support QTI bluetooth solution
# qti-camera:    Support QTI camera solution
# qti-mm-parser: Support QTI multimeida parsers
# qti-video:     Support QTI video solution
# qti-video-encoder: Support QTI video encode
# qti-cdsp:      Support QTI cdsp solution
# qti-adsp:      Support QTI adsp solution
# qti-qmmf:      Support QTI QMMF solution
# qti-security:  Support QTI security solution
# qti-vble:      Support QTI Verified boot for LE
#

DISTRO_FEATURES_append = " qti-audio qti-bluetooth qti-camera qti-mm-parser qti-video qti-video-encoder qti-cdsp qti-adsp qti-fastcv qti-qmmf qti-security qti-vble "

# inherit distro_featres_check class across the distro
INHERIT += "distro_features_check"

# Include in native DISTRO_FEATURES if present in the target DISTRO_FEATURES.
DISTRO_FEATURES_FILTER_NATIVE += " selinux"

# Set selinux in enforcing state by default
DEFAULT_ENFORCING = "enforcing"
