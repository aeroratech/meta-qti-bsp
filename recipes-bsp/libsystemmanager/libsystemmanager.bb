inherit autotools pkgconfig

LICENSE          = "BSD-3-Clause-Clear"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta-qti-bsp/files/common-licenses/\
${LICENSE};md5=3771d4920bd6cdb8cbdf1e8344489ee0"

DESCRIPTION = "Library and Utility to pet systemd watchdog"

DEPENDS += "systemd"
RDEPENDS_${PN} += "libsystemd"

FILESEXTRAPATHS_prepend := "${WORKSPACE}/QPlatformUtils:"
SRC_URI += "file://${BPN}"

CPPFLAGS += "${@oe.utils.conditional('DEBUG_BUILD', '1', '-D_DEBUG', '',d)}"

S = "${WORKDIR}/${BPN}"
