inherit autotools-brokensep pkgconfig

DESCRIPTION      = "psi-daemon"
HOMEPAGE         = "www.codelinaro.org"
LICENSE          = "BSD-3-Clause-Clear"
LIC_FILES_CHKSUM += "file://${COREBASE}/meta-qti-bsp/files/common-licenses/\
${LICENSE};md5=3771d4920bd6cdb8cbdf1e8344489ee0"

PR = "r1"

FILESPATH =+ "${WORKSPACE}/vendor/qcom/opensource/:"
SRC_URI   = "file://psi_daemon"

S = "${WORKDIR}/psi_daemon"
DEPENDS += "virtual/kernel libcutils liblog libutils libbase libvmmem libvmmem-headers linux-msm-headers"

# To get kernel headers for compilation
do_configure[depends] += "virtual/kernel:do_shared_workdir"

EXTRA_OECONF = " --with-sanitized-headers=${STAGING_INCDIR}/linux-msm/usr/include \
                 --disable-static "

PACKAGES +="${PN}-test-bin"

FILES_${PN} = "${bindir}/*"

PACKAGE_ARCH = "${MACHINE_ARCH}"
