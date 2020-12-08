require recipes-kernel/linux-msm/linux-msm.inc
COMPATIBLE_MACHINE = "genericarmv8|sdxlemur|scuba"

SRC_DIR   =  "${WORKSPACE}/kernel/msm-5.4"
S         =  "${WORKDIR}/kernel/msm-5.4"
PR = "r0"

DEPENDS += "llvm-arm-toolchain-native dtc-native rsync-native"

LDFLAGS_aarch64 = "-O1 --hash-style=gnu --as-needed"
TARGET_CXXFLAGS += "-Wno-format"
KERNEL_CC = "${STAGING_BINDIR_NATIVE}/llvm-arm-toolchain/bin/clang -target ${TARGET_ARCH}${TARGET_VENDOR}-${TARGET_OS}"

LIC_FILES_CHKSUM = "file://COPYING;md5=bbea815ee2795b2f4230826c0c6b8814"

#dts path is changed to vendor/qcom
DTBO_SRC_PATH = "${STAGING_KERNEL_BUILDDIR}/arch/${ARCH}/boot/dts/vendor/qcom/"

DYNAMIC_DEFCONFIG_SUPPORT = "sdxlemur scuba-32"

do_configure_prepend() {
        if ${@bb.utils.contains('DYNAMIC_DEFCONFIG_SUPPORT', '${MACHINE}', 'true', 'false', d)}; then
                ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} REAL_CC=${STAGING_BINDIR_NATIVE}/llvm-arm-toolchain/bin/clang \
                LD=arm-oe-linux-gnueabi-ld KERN_OUT=${STAGING_KERNEL_BUILDDIR} \
                ${STAGING_KERNEL_DIR}/scripts/gki/generate_defconfig.sh ${KERNEL_CONFIG}
        fi
}

do_shared_workdir_append () {
        cp Makefile $kerneldir/
        cp -fR usr $kerneldir/

        cp include/config/auto.conf $kerneldir/include/config/auto.conf

        if [ -d arch/${ARCH}/include ]; then
                mkdir -p $kerneldir/arch/${ARCH}/include/
                cp -fR arch/${ARCH}/include/* $kerneldir/arch/${ARCH}/include/
        fi

        if [ -d arch/${ARCH}/boot ]; then
                mkdir -p $kerneldir/arch/${ARCH}/boot/
                cp -fR arch/${ARCH}/boot/* $kerneldir/arch/${ARCH}/boot/
        fi

        mkdir -p $kerneldir/scripts

        cp ${STAGING_KERNEL_DIR}/usr/gen_initramfs_list.sh $kerneldir/scripts/

        # Generate kernel headers
        oe_runmake_call -C ${STAGING_KERNEL_DIR} ARCH=${ARCH} CC="${KERNEL_CC}" LD="${KERNEL_LD}" headers_install O=${STAGING_KERNEL_BUILDDIR}
}

do_deploy_append () {
         # Copy vmlinux and zImage into deplydir for boot.img creation
         install -d ${DEPLOYDIR}/build-artifacts
         install -d ${DEPLOYDIR}/build-artifacts/kernel_scripts/scripts
         install -d ${DEPLOYDIR}/build-artifacts/dtb
         cp  ${STAGING_KERNEL_DIR}/usr/gen_initramfs_list.sh ${DEPLOYDIR}/build-artifacts/kernel_scripts/scripts
         cp -a ${STAGING_KERNEL_BUILDDIR}/usr/ ${DEPLOYDIR}/build-artifacts/kernel_scripts/
         cp -a ${STAGING_KERNEL_BUILDDIR}/arch/${ARCH}/boot/dts/vendor/qcom/*.dtb ${DEPLOYDIR}/build-artifacts/dtb
         install -m 0644 ${KERNEL_OUTPUT_DIR}/${KERNEL_IMAGETYPE} ${DEPLOYDIR}/${KERNEL_IMAGETYPE}
         install -m 0644 vmlinux ${DEPLOYDIR}
         install -m 0644 System.map ${DEPLOYDIR}

         if ${@bb.utils.contains('MACHINE_FEATURES', 'qti-vm', 'true', 'false', d)}; then
                 mkdtimg create ${DEPLOYDIR}/${DTB_TARGET} --page_size=${PAGE_SIZE} ${DEPLOYDIR}/build-artifacts/dtb/*.dtb
         fi
}
