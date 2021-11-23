DESCRIPTION = "Android DTC required to compile QTI kernel"
LICENSE = "GPL-2.0"

LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=801f80980d171dd6425610833a22dbe6"

S = "${WORKDIR}/bin"
BBCLASSEXTEND = "native"

FILESPATH =+ "${WORKSPACE}/kernel-5.15/kernel_platform/prebuilts/kernel-build-tools/linux-x86/:"
SRC_URI    = "file://bin"

INHIBIT_SYSROOT_STRIP = "1"
do_configure[noexec] = "1"
do_compile[noexec] = "1"

BBCLASSEXTEND = " native"

do_install() {
    install -d ${D}/${bindir}/dtc/
    install -d ${D}/${bindir}/dtc/bin/
    cp -rf ${S}/dtc ${D}/${bindir}/dtc/bin/
}
