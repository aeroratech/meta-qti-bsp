inherit autotools pkgconfig
COMPATIBLE_MACHINE = "genericarmv8"

FILESPATH =+ "${WORKSPACE}:"
SRC_URI = "file://kernel-5.4/"
S = "${WORKDIR}/kernel-5.4/"
PR = "r0"

LICENSE = "GPL-2.0 WITH Linux-syscall-note"
LIC_FILES_CHKSUM = "file://kernel_platform/common/COPYING;md5=6bc538ed5bd9a7fc9398086aedcd7e46"

DEPENDS += "mkdtimg-native"

do_install[cleandirs] += " ${STAGING_KERNEL_BUILDDIR}"
do_install[cleandirs] += " ${STAGING_KERNEL_DIR}"

do_configure () {
	:
}

do_compile () {
	:
}

do_install () {
    cp -a ${WORKSPACE}/kernel-5.4/kernel_platform/common/* ${STAGING_KERNEL_DIR}
    cp -a ${WORKSPACE}/kernel-5.4/out/*/common/* ${STAGING_KERNEL_BUILDDIR}
}
