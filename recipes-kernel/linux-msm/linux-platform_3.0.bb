inherit autotools pkgconfig deploy
COMPATIBLE_MACHINE = "genericarmv8|trustedvm|trustedvm-v2"

FILESPATH =+ "${WORKSPACE}:"
SRC_URI = "file://kernel-${PREFERRED_VERSION_linux-msm}/kernel_platform/msm-kernel/"
S = "${WORKDIR}/kernel-${PREFERRED_VERSION_linux-msm}/kernel_platform/msm-kernel/"
PR = "r0"

LICENSE = "GPL-2.0 WITH Linux-syscall-note"
LIC_FILES_CHKSUM = "file://COPYING;md5=6bc538ed5bd9a7fc9398086aedcd7e46"

DEPENDS += "virtual/mkdtimg-native bison-native"

do_setup_module_compilation[lockfiles] = "${TMPDIR}/build_modules.lock"

do_unpack[cleandirs] += " ${S}"

do_unpack () {
    cp -a ${WORKSPACE}/kernel-${PREFERRED_VERSION_linux-msm}/kernel_platform/msm-kernel/COPYING ${S}

    # Temp workaround for path update
    mkdir -p ${KERNEL_PREBUILT_PATH}/../msm-kernel/usr/
    mkdir -p ${KERNEL_PREBUILT_PATH}/../msm-kernel/certs/
    mkdir -p ${KERNEL_PREBUILT_PATH}/../msm-kernel/scripts/
    cp -a ${KERNEL_PREBUILT_PATH}/gen_init_cpio ${KERNEL_PREBUILT_PATH}/../msm-kernel/usr/
    cp -a ${KERNEL_PREBUILT_PATH}/initramfs_data.cpio ${KERNEL_PREBUILT_PATH}/../msm-kernel/usr/
    cp -a ${KERNEL_PREBUILT_PATH}/initramfs_inc_data ${KERNEL_PREBUILT_PATH}/../msm-kernel/usr/
    cp -a ${KERNEL_PREBUILT_PATH}/signing_key.pem ${KERNEL_PREBUILT_PATH}/../msm-kernel/certs/
    cp -a ${KERNEL_PREBUILT_PATH}/verity_cert.pem ${KERNEL_PREBUILT_PATH}/../msm-kernel/certs/
    cp -a ${KERNEL_PREBUILT_PATH}/verity_key.pem ${KERNEL_PREBUILT_PATH}/../msm-kernel/certs/
    cp -a ${KERNEL_PREBUILT_PATH}/signing_key.x509 ${KERNEL_PREBUILT_PATH}/../msm-kernel/certs/
    cp -a ${KERNEL_PREBUILT_PATH}/sign-file ${KERNEL_PREBUILT_PATH}/../msm-kernel/scripts/
}

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
    KERNEL_KIT=${KERNEL_OUT_PATH}/ \
    OUT_DIR=temp_out_dir \
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

     cp -R ${KERNEL_PREBUILT_PATH}/../msm-kernel/usr/gen_init_cpio ${DEPLOYDIR}/build-artifacts/kernel_scripts/usr/
     cp -R ${KERNEL_PREBUILT_PATH}/../msm-kernel/usr/initramfs_data.cpio ${DEPLOYDIR}/build-artifacts/kernel_scripts/usr/
     cp -R ${KERNEL_PREBUILT_PATH}/../msm-kernel/usr/initramfs_inc_data ${DEPLOYDIR}/build-artifacts/kernel_scripts/usr/
     # gen_initramfs.sh is present in kernel source
     cp -R ${KERNEL_PREBUILT_PATH}/../../../kernel_platform/msm-kernel/usr/gen_initramfs.sh ${DEPLOYDIR}/build-artifacts/kernel_scripts/scripts

     if ${@oe.utils.conditional('OEMVM_SUPPORT', 'True', 'true', 'false', d)}; then
         mkdir -p ${DEPLOYDIR}/build-artifacts/oemvm-dtb
         cp -a ${KERNEL_PREBUILT_PATH}/${VM_TARGET}-vm-*.dtb ${DEPLOYDIR}/build-artifacts/dtb
         cp -a ${KERNEL_PREBUILT_PATH}/${VM_TARGET}p-vm-*.dtb ${DEPLOYDIR}/build-artifacts/dtb
         cp -a ${KERNEL_PREBUILT_PATH}/${VM_TARGET}-oemvm-*.dtb ${DEPLOYDIR}/build-artifacts/oemvm-dtb
         cp -a ${KERNEL_PREBUILT_PATH}/${VM_TARGET}p-oemvm-*.dtb ${DEPLOYDIR}/build-artifacts/oemvm-dtb
         cp -a ${KERNEL_PREBUILT_PATH}/cliffs-vm-*.dtb ${DEPLOYDIR}/build-artifacts/dtb
         cp -a ${KERNEL_PREBUILT_PATH}/cliffs-oemvm-*.dtb ${DEPLOYDIR}/build-artifacts/oemvm-dtb
     else
         cp -a ${KERNEL_PREBUILT_PATH}/${VM_TARGET}-vm-*.dtb  ${DEPLOYDIR}/build-artifacts/dtb
         cp -a ${KERNEL_PREBUILT_PATH}/${VM_TARGET}p-vm-*.dtb  ${DEPLOYDIR}/build-artifacts/dtb
         cp -a ${KERNEL_PREBUILT_PATH}/cliffs-vm-*.dtb ${DEPLOYDIR}/build-artifacts/dtb
     fi
     cp -a ${KERNEL_PREBUILT_PATH}/vmlinux ${DEPLOYDIR}
     cp -a ${KERNEL_PREBUILT_PATH}/System.map ${DEPLOYDIR}
     install -m 0644 ${KERNEL_PREBUILT_PATH}/${KERNEL_IMAGETYPE} ${DEPLOYDIR}/${KERNEL_IMAGETYPE}

}

addtask do_deploy after do_install before do_package
