inherit autotools
SUMMARY = "ALSA sound library for compress format"
LICENSE = "BSD & LGPLv2.1"
LIC_FILES_CHKSUM = "file://COPYING;md5=7b60fb27ed2ff685a5c5f41b8b59cca6"

PVR = "v1.1.0"

SRCREV = "e605f5684997565ba50cf9ad57df2a7980b5e327"
SRC_URI = "git://codeaurora.org/quic/le/platform/external/tinycompress.git;protocol=git;branch=alsa-project/master"


S = "${WORKDIR}/git"
