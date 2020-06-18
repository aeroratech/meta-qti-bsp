inherit native deploy

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

do_deploy[cleandirs] = "${DEPLOYDIR}/ota-scripts"
do_deploy() {
    install -m 755 ${WORKDIR}/full_ota.sh  ${DEPLOYDIR}/ota-scripts
    install -m 755 ${WORKDIR}/incremental_ota.sh ${DEPLOYDIR}/ota-scripts
    install -m 755 ${WORKDIR}/releasetools.py ${DEPLOYDIR}/ota-scripts
    install -m 755 ${S}/blockimgdiff.py ${DEPLOYDIR}/ota-scripts
    install -m 755 ${S}/common.py ${DEPLOYDIR}/ota-scripts
    install -m 755 ${S}/edify_generator.py ${DEPLOYDIR}/ota-scripts
    install -m 755 ${S}/img_from_target_files ${DEPLOYDIR}/ota-scripts
    install -m 755 ${S}/ota_from_target_files ${DEPLOYDIR}/ota-scripts
    install -m 755 ${S}/rangelib.py ${DEPLOYDIR}/ota-scripts
    install -m 755 ${S}/sparse_img.py ${DEPLOYDIR}/ota-scripts
}
addtask deploy after do_install
