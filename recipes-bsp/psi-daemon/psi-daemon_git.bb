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
DEPENDS += "libcutils liblog libutils libbase libvmmem libvmmem-headers"

PACKAGES +="${PN}-test-bin"

FILES_${PN} = "${bindir}/*"

PACKAGE_ARCH = "${MACHINE_ARCH}"
