SUMMARY = "A System and service manager"
HOMEPAGE = "http://www.freedesktop.org/wiki/Software/systemd"

DESCRIPTION = "libsystemdq is library for systemd  utility library"

LICENSE = "LGPLv2.1"
LIC_FILES_CHKSUM = "file://LICENSE.LGPL2.1;md5=4fbd65380cdd255951079008b364516c"

SRCREV = "b7ed902b2394f94e7f1fbe6c3194b5cd9a9429e6"
SRCBRANCH = "caf_migration/systemd-stable/v244-stable"
SRC_URI = "${CLO_LE_GIT}/systemd-stable.git;protocol=https;branch=${SRCBRANCH}"

S = "${WORKDIR}/git"
