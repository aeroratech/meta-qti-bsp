inherit autotools-brokensep deploy

DESCRIPTION = "csm host tools"

LICENSE = "BSD"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=3775480a712fc46a69647678acb234cb"

FILESPATH =+ "${WORKSPACE}/platform/:"

SRC_URI = "file://mhi-host/"

S = "${WORKDIR}/mhi-host/"

do_install[noexec] = "1"
do_configure[noexec] = "1"

RM_WORK_EXCLUDE += "${PN}"

do_compile() {
    source ${S}/build/envsetup.sh
    bash ${S}/build/build.sh
}

do_deploy[cleandirs] = "${DEPLOYDIR}/${PN}"

do_deploy() {
    # Deploy mhi ko files
    install -d ${DEPLOYDIR}/${PN}/mhi-host

    cp ${S}/drivers/bus/mhi/core/mhi.ko ${DEPLOYDIR}/${PN}/mhi-host
    cp ${S}/drivers/bus/mhi/mhi_uci.ko ${DEPLOYDIR}/${PN}/mhi-host
    cp ${S}/drivers/bus/mhi/mhi_pci.ko ${DEPLOYDIR}/${PN}/mhi-host
    cp ${S}/drivers/net/mhi/mhi_net.ko ${DEPLOYDIR}/${PN}/mhi-host
    cp ${S}/drivers/net/wwan/wwan.ko ${DEPLOYDIR}/${PN}/mhi-host
    cp ${S}/drivers/net/wwan/wwan_mhi.ko ${DEPLOYDIR}/${PN}/mhi-host
}

addtask deploy after do_populate_sysroot