inherit native

DESCRIPTION = "releasetools used for OTA"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=89aea4e17d99a7cacdbeed46a0096b10"

RDEPENDS_${PN} += "recovery-ab"

FILESPATH =+ "${WORKSPACE}/OTA/build/tools/:${WORKSPACE}/OTA/device/qcom/common/:"

SRC_URI   = "file://releasetools/"
SRC_URI  += "file://releasetools.py"
SRC_URI  += "file://full_ota.sh"
SRC_URI  += "file://incremental_ota.sh"

S = "${WORKDIR}/releasetools"

do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install_append() {
    install -d ${D}${bindir}/releasetools/
    install -m 755 ${WORKDIR}/full_ota.sh ${D}${bindir}/releasetools/
    install -m 755 ${WORKDIR}/incremental_ota.sh ${D}${bindir}/releasetools/
    install -m 755 ${WORKDIR}/releasetools.py ${D}${bindir}/releasetools/
    cp -rf ${S}/* ${D}${bindir}/releasetools/
}
