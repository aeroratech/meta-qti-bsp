DEPENDS += " linux-platform bison-native mkdtimg-native"

do_compile_kernelmodules () {
       :
}

addtask compile_kernelmodules after do_compile before do_install

do_deploy () {
     # Copy vmlinux and zImage into deploydir for boot.img creation
     install -d ${DEPLOY_DIR_IMAGE}/build-artifacts
     install -d ${DEPLOY_DIR_IMAGE}/build-artifacts/kernel_scripts/scripts
     install -d ${DEPLOY_DIR_IMAGE}/build-artifacts/dtb
     cp  ${STAGING_KERNEL_DIR}/usr/gen_initramfs.sh ${DEPLOY_DIR_IMAGE}/build-artifacts/kernel_scripts/scripts
     cp -a ${STAGING_KERNEL_BUILDDIR}/usr/ ${DEPLOY_DIR_IMAGE}/build-artifacts/kernel_scripts/
     cp -a ${STAGING_KERNEL_BUILDDIR}/arch/arm64/boot/dts/vendor/qcom/*.dtb ${DEPLOY_DIR_IMAGE}/build-artifacts/dtb
     cp -a ${STAGING_KERNEL_BUILDDIR}/vmlinux ${DEPLOY_DIR_IMAGE}
     cp -a ${STAGING_KERNEL_BUILDDIR}/System.map ${DEPLOY_DIR_IMAGE}

     install -m 0644 ${STAGING_KERNEL_BUILDDIR}/arch/arm64/boot/${KERNEL_IMAGETYPE} ${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGETYPE}

     if ${@bb.utils.contains('MACHINE_FEATURES', 'qti-vm', 'true', 'false', d)}; then
             mkdtimg create ${DEPLOY_DIR_IMAGE}/${DTB_TARGET} --page_size=${PAGE_SIZE} ${DEPLOY_DIR_IMAGE}/build-artifacts/dtb/*.dtb
     fi
}

addtask do_deploy after do_install before do_package

