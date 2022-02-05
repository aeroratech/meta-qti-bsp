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

DEPENDS += "virtual/kernel linux-msm-headers"

# To get kernel headers for compilation
do_configure[depends] += "virtual/kernel:do_shared_workdir"

EXTRA_OECONF = " \
    --with-sanitized-headers=${STAGING_KERNEL_BUILDDIR}/usr/include \
    --with-sanitized-headers=${STAGING_INCDIR}/linux-msm/usr/include \
    --with-core-headers=${STAGING_INCDIR} \
"

UFSBSG = "${@d.getVar('UFS_BSG_DEV_USAGE') or "False"}"

CPPFLAGS_append = "${@oe.utils.conditional('UFSBSG', 'True', ' -D_BSG_FRAMEWORK_KERNEL_HEADERS ', '', d)}"

PACKAGECONFIG ?= " \
    glib \
    ion \
    ${@oe.utils.conditional('UFSBSG', 'True', 'ufsbsg', '', d)} \
"

PACKAGECONFIG[glib] = "--with-glib, --without-glib, glib-2.0"
PACKAGECONFIG[ion] = "--with-ion, --without-ion, libion"
PACKAGECONFIG[ufsbsg] = "--with-ufsbsg, --without-ufsbsg"

PARALLEL_MAKE = ""
