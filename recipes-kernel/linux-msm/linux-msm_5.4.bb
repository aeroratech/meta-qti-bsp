require recipes-kernel/linux-msm/linux-msm.inc
COMPATIBLE_MACHINE = "genericarmv8|sdxlemur"

SRC_DIR   =  "${WORKSPACE}/kernel/msm-5.4"
S         =  "${WORKDIR}/kernel/msm-5.4"
PR = "r0"

DEPENDS += "llvm-arm-toolchain-native dtc-native rsync-native"

LDFLAGS_aarch64 = "-O1 --hash-style=gnu --as-needed"
TARGET_CXXFLAGS += "-Wno-format"
KERNEL_CC = "${STAGING_BINDIR_NATIVE}/llvm-arm-toolchain/bin/clang -target ${TARGET_ARCH}${TARGET_VENDOR}-${TARGET_OS}"

LIC_FILES_CHKSUM = "file://COPYING;md5=bbea815ee2795b2f4230826c0c6b8814"
DYNAMIC_DEFCONFIG_SUPPORT = "sdxlemur"

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
         install -d ${DEPLOYDIR}/kernel_scripts/scripts
         cp  ${STAGING_KERNEL_DIR}/usr/gen_initramfs_list.sh ${DEPLOYDIR}/kernel_scripts/scripts
         cp -a ${STAGING_KERNEL_BUILDDIR}/usr/ ${DEPLOYDIR}/kernel_scripts/
}
