inherit autotools qprebuilt pkgconfig

LICENSE          = "BSD-3-Clause-Clear"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta-qti-bsp/files/common-licenses/\
${LICENSE};md5=3771d4920bd6cdb8cbdf1e8344489ee0"

DESCRIPTION = "Library and Utility to get system reboot reason"

FILESEXTRAPATHS_prepend := "${WORKSPACE}/QPlatformUtils:"
SRC_URI += "file://${PN}"

S = "${WORKDIR}/${PN}"
