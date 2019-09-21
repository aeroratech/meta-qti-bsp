inherit native

DESCRIPTION = "Boot image creation tool from Android"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=89aea4e17d99a7cacdbeed46a0096b10"

FILESEXTRAPATHS_prepend := "${WORKSPACE}/system/core/:"
SRC_URI   = "file://mkbootimg"

S = "${WORKDIR}/${BPN}"

DEPENDS += "libmincrypt-native"

EXTRA_OEMAKE = "INCLUDES='-Imincrypt' LIBS='${libdir}/libmincrypt.a'"

do_configure[noexec]="1"

do_install() {
   install -d ${D}${bindir}
   install ${BPN} ${D}${bindir}
}

NATIVE_INSTALL_WORKS = "1"
