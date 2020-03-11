inherit autotools-brokensep pkgconfig
PR = "r1"

DESCRIPTION = "OEM Recovery"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=550794465ba0ec5312d6919e203a55f9"
HOMEPAGE = "https://www.codeaurora.org/gitweb/quic/la?p=device/qcom/common.git"

FILESPATH =+ "${WORKSPACE}:"
SRC_URI = "file://OTA/device/qcom/common/recovery/oem-recovery/"

S = "${WORKDIR}/OTA/device/qcom/common/recovery/oem-recovery/"

DEPENDS += "glib-2.0 virtual/kernel libion"

EXTRA_OECONF = "--with-glib --with-sanitized-headers=${STAGING_KERNEL_BUILDDIR}/usr/include \
                --with-core-headers=${STAGING_INCDIR}"

PARALLEL_MAKE = ""
