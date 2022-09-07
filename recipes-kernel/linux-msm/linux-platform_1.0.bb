inherit autotools pkgconfig deploy
COMPATIBLE_MACHINE = "genericarmv8|trustedvm"

FILESPATH =+ "${WORKSPACE}:"
SRC_URI = "file://kernel-${PREFERRED_VERSION_linux-msm}/kernel_platform/"
S = "${WORKDIR}/kernel-${PREFERRED_VERSION_linux-msm}/kernel_platform/"
PR = "r0"

LICENSE = "GPL-2.0 WITH Linux-syscall-note"
LIC_FILES_CHKSUM = "file://COPYING;md5=6bc538ed5bd9a7fc9398086aedcd7e46"

DEPENDS += "virtual/mkdtimg-native bison-native"

do_unpack[cleandirs] += " ${S}"
do_clean[cleandirs] += " ${S} ${STAGING_KERNEL_DIR} ${B} ${STAGING_KERNEL_BUILDDIR}"

do_unpack () {
    cp -a ${WORKSPACE}/kernel-${PREFERRED_VERSION_linux-msm}/kernel_platform/msm-kernel/COPYING ${S}
}

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
    cp -a ${WORKSPACE}/kernel-${PREFERRED_VERSION_linux-msm}/kernel_platform/msm-kernel/* ${COPY_KERNEL_SOURCE_DIR}
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
    cp -a ${WORKSPACE}/kernel-${PREFERRED_VERSION_linux-msm}/out/msm-*-*_*-${KERNEL_VARIANT}defconfig/msm-kernel/* ${COPY_KERNEL_BUILD_DIR}
    cp -a ${WORKSPACE}/kernel-${PREFERRED_VERSION_linux-msm}/out/msm-*-*_*-${KERNEL_VARIANT}defconfig/msm-kernel/.config ${COPY_KERNEL_BUILD_DIR}
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

# Set up hosttools for techpack module compilation
do_setup_module_compilation() {
    cd ${WORKSPACE}/kernel-${PREFERRED_VERSION_linux-msm}/kernel_platform  && \

    BUILD_CONFIG=${KERNEL_BUILD_CONFIG} \
    OUT_DIR=${KERNEL_OUT_PATH}/ \
    KERNEL_UAPI_HEADERS_DIR=${STAGING_KERNEL_BUILDDIR} \
    INSTALL_MODULE_HEADERS=1 \
    ./build/build_module.sh
}
addtask do_setup_module_compilation after do_unpack before do_compile

OEMVM_SUPPORT = "${@d.getVar('MACHINE_SUPPORTS_OEMVM') or "False"}"
do_deploy () {
     # Copy vmlinux and zImage into deploydir for boot.img creation
     install -d ${DEPLOYDIR}/build-artifacts
     install -d ${DEPLOYDIR}/build-artifacts/kernel_scripts/scripts
     install -d ${DEPLOYDIR}/build-artifacts/kernel_scripts/usr/
     install -d ${DEPLOYDIR}/build-artifacts/dtb

     cp  ${STAGING_KERNEL_DIR}/usr/gen_initramfs.sh ${DEPLOYDIR}/build-artifacts/kernel_scripts/scripts
     cp -a ${STAGING_KERNEL_BUILDDIR}/usr/gen_init_cpio ${DEPLOYDIR}/build-artifacts/kernel_scripts/usr/
     cp -a ${STAGING_KERNEL_BUILDDIR}/usr/initramfs_data.cpio ${DEPLOYDIR}/build-artifacts/kernel_scripts/usr/
     cp -a ${STAGING_KERNEL_BUILDDIR}/usr/initramfs_inc_data ${DEPLOYDIR}/build-artifacts/kernel_scripts/usr/

     if ${@oe.utils.conditional('OEMVM_SUPPORT', 'True', 'true', 'false', d)}; then
         mkdir -p ${DEPLOYDIR}/build-artifacts/oemvm-dtb
         cp -a ${KERNEL_PREBUILT_PATH}/${VM_TARGET}-vm-*.dtb ${DEPLOYDIR}/build-artifacts/dtb
         cp -a ${KERNEL_PREBUILT_PATH}/${VM_TARGET}-oemvm-*.dtb ${DEPLOYDIR}/build-artifacts/oemvm-dtb
     else
         cp -a ${STAGING_KERNEL_BUILDDIR}/arch/arm64/boot/dts/vendor/qcom/*.dtb  ${DEPLOYDIR}/build-artifacts/dtb
     fi
     cp -a ${STAGING_KERNEL_BUILDDIR}/vmlinux ${DEPLOYDIR}
     cp -a ${STAGING_KERNEL_BUILDDIR}/System.map ${DEPLOYDIR}
     install -m 0644 ${STAGING_KERNEL_BUILDDIR}/arch/arm64/boot/${KERNEL_IMAGETYPE} ${DEPLOYDIR}/${KERNEL_IMAGETYPE}

}

addtask do_deploy after do_install before do_package
