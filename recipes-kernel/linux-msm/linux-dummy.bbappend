inherit deploy
DEPENDS += " linux-platform bison-native mkdtimg-native"

do_compile_kernelmodules () {
       :
}

addtask compile_kernelmodules after do_compile before do_install

do_deploy () {
     # Copy vmlinux and zImage into deploydir for boot.img creation
     install -d ${DEPLOYDIR}/build-artifacts
     install -d ${DEPLOYDIR}/build-artifacts/kernel_scripts/scripts
     install -d ${DEPLOYDIR}/build-artifacts/dtb
     cp  ${STAGING_KERNEL_DIR}/usr/gen_initramfs.sh ${DEPLOYDIR}/build-artifacts/kernel_scripts/scripts
     cp -a ${STAGING_KERNEL_BUILDDIR}/usr/ ${DEPLOYDIR}/build-artifacts/kernel_scripts/
     cp -a ${STAGING_KERNEL_BUILDDIR}/arch/arm64/boot/dts/vendor/qcom/*.dtb ${DEPLOYDIR}/build-artifacts/dtb
     cp -a ${STAGING_KERNEL_BUILDDIR}/vmlinux ${DEPLOYDIR}
     cp -a ${STAGING_KERNEL_BUILDDIR}/System.map ${DEPLOYDIR}

     install -m 0644 ${STAGING_KERNEL_BUILDDIR}/arch/arm64/boot/${KERNEL_IMAGETYPE} ${DEPLOYDIR}/${KERNEL_IMAGETYPE}

     if ${@bb.utils.contains('MACHINE_FEATURES', 'qti-vm', 'true', 'false', d)}; then
             mkdtimg create ${DEPLOYDIR}/${DTB_TARGET} --page_size=${PAGE_SIZE} ${DEPLOYDIR}/build-artifacts/dtb/*.dtb
     fi
}

addtask do_deploy after do_install before do_package

