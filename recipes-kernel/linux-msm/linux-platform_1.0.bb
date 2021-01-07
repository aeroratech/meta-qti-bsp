inherit autotools pkgconfig
COMPATIBLE_MACHINE = "genericarmv8"

FILESPATH =+ "${WORKSPACE}:"
SRC_URI = "file://kernel-5.4/kernel_platform/"
S = "${WORKDIR}/kernel-5.4/kernel_platform/"
PR = "r0"

LICENSE = "GPL-2.0 WITH Linux-syscall-note"
LIC_FILES_CHKSUM = "file://common/COPYING;md5=6bc538ed5bd9a7fc9398086aedcd7e46"

DEPENDS += "mkdtimg-native"

#do_unpack[cleandirs] += " ${S}"
#do_clean[cleandirs] += " ${S} ${STAGING_KERNEL_DIR} ${B} ${STAGING_KERNEL_BUILDDIR}"

#do_unpack () {
#    cp -a ${WORKSPACE}/kernel-5.4/kernel_platform/common/COPYING ${S}
#}

SSTATETASKS += "do_copy_kernelsource"
SSTATETASKS += "do_copy_kernelbuild"

COPY_KERNEL_SOURCE_DIR = "${WORKDIR}/kernel_source"
do_copy_kernelsource[sstate-inputdirs] = "${COPY_KERNEL_SOURCE_DIR}"
do_copy_kernelsource[sstate-outputdirs] = "${STAGING_KERNEL_DIR}"
do_copy_kernelsource[dirs] = "${COPY_KERNEL_SOURCE_DIR}"
do_copy_kernelsource[cleandirs] = "${COPY_KERNEL_SOURCE_DIR} ${STAGING_KERNEL_DIR}"
do_copy_kernelsource[stamp-extra-info] = "${MACHINE_ARCH}"

do_copy_kernelsource () {
    install -d ${STAGING_KERNEL_DIR}
    cp -a ${WORKSPACE}/kernel-5.4/kernel_platform/common/* ${COPY_KERNEL_SOURCE_DIR}
}

python do_copy_kernelsource_setscene() {
     sstate_setscene(d)
}

COPY_KERNEL_BUILD_DIR = "${WORKDIR}/kernel_build"
do_copy_kernelbuild[sstate-inputdirs] = "${COPY_KERNEL_BUILD_DIR}"
do_copy_kernelbuild[sstate-outputdirs] = "${STAGING_KERNEL_BUILDDIR}"
do_copy_kernelbuild[dirs] = "${COPY_KERNEL_BUILD_DIR}"
do_copy_kernelbuild[cleandirs] = "${COPY_KERNEL_BUILD_DIR} ${STAGING_KERNEL_BUILDDIR}"
do_copy_kernelbuild[stamp-extra-info] = "${MACHINE_ARCH}"

do_copy_kernelbuild () {
    install -d ${STAGING_KERNEL_BUILDDIR}
    cp -a ${WORKSPACE}/kernel-5.4/out/msm-*-*_*-debug_defconfig/common/* ${COPY_KERNEL_BUILD_DIR}
    cp -a ${WORKSPACE}/kernel-5.4/out/msm-*-*_*-debug_defconfig/common/.config ${COPY_KERNEL_BUILD_DIR}
}

python do_copy_kernelbuild_setscene() {
     sstate_setscene(d)
}

addtask do_copy_kernelsource_setscene
addtask do_copy_kernelbuild_setscene
addtask do_copy_kernelsource after do_unpack before do_compile
addtask do_copy_kernelbuild after do_unpack before do_compile

do_configure () {
	:
}

do_compile () {
	:
}

do_install () {
	:
}
