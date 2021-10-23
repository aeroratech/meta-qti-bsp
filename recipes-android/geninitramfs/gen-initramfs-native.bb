inherit native

DESCRIPTION = "Ramdisk tool for creation of cpio archive"
LICENSE = "GPL-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"

PR = "r0"

FILESPATH =+ "${WORKSPACE}/kernel-5.10/kernel_platform/msm-kernel/usr/:"
SRC_URI = "file://gen_initramfs.sh"

S = "${WORKDIR}"
INHIBIT_SYSROOT_STRIP = "1"
do_compile[noexec] = "1"
do_configure[noexec] = "1"

do_install() {
    install -d ${D}/${bindir}/scripts/
    install -d ${D}/${bindir}/scripts/usr/
    cp ${S}/gen_initramfs.sh ${D}/${bindir}/scripts/
    cp ${KERNEL_PREBUILT_PATH}/../msm-kernel/usr/gen_init_cpio ${D}/${bindir}/scripts/usr/
}
