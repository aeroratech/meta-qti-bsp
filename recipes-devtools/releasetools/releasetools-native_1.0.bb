inherit native

DESCRIPTION = "releasetools used for OTA"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=89aea4e17d99a7cacdbeed46a0096b10"

PR = "r0"

DEPENDS += "libselinux libpcre2 liblog fsconfig-native applypatch-native libdivsufsort-native bsdiff-native"

FILESPATH =+ "${WORKSPACE}/OTA/build/tools/:"

SRC_URI   = "file://releasetools/"
SRC_URI  += "file://full_ota.sh"
SRC_URI  += "file://incremental_ota.sh"

S = "${WORKDIR}"


do_install() {
    install -d ${D}${sbindir}
    install -d ${D}${sbindir}/releasetools/
    cp -r ${WORKDIR}/releasetools/* ${D}${sbindir}/releasetools/
    install -m 0755 ${S}/full_ota.sh  -D ${D}/${sbindir}/releasetools/
    install -m 0755 ${S}/incremental_ota.sh  -D ${D}/${sbindir}/releasetools/
}
do_configure[noexec] = "1"
do_compile[noexec] = "1"
