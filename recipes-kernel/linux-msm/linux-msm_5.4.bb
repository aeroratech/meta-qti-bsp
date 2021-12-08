require recipes-kernel/linux-msm/linux-msm.inc
COMPATIBLE_MACHINE = "genericarmv8|sdxlemur|scuba|qrbx210-rbx|sa2150p|sa2150p-nand|sa410m|qcs610|qrb5165|sa515m"

SRC_URI_append_sdxlemur += "${@bb.utils.contains('MACHINE_FEATURES', 'qti-audio', 'file://0001-ALSA-uapi-add-check-to-avoid-duplicate-include-of-ti.patch', '', d)}"
SRC_URI_append_sdxlemur += "${@bb.utils.contains('DISTRO_FEATURES', 'dm-verity', 'file://gluebi.cfg', '', d)}"

S         =  "${WORKDIR}/kernel/msm-5.4"
PR        =  "r0"

# QCS610 specific
SRC_URI_append_qcs610 += "file://qcs610.cfg"
SRC_URI_append_qcs610 += "file://android_binderfs.cfg"

DEPENDS += "llvm-arm-toolchain-native virtual/dtc-native rsync-native clang-native"
TOOLCHAIN = "clang"
RUNTIME = "llvm"

LDFLAGS_aarch64 = "-O1 --hash-style=gnu --as-needed"
TARGET_CXXFLAGS += "-Wno-format"
KERNEL_CC = "${STAGING_BINDIR_NATIVE}/clang -target ${TARGET_ARCH}${TARGET_VENDOR}-${TARGET_OS}"

LIC_FILES_CHKSUM = "file://COPYING;md5=bbea815ee2795b2f4230826c0c6b8814"

#dts path is changed to vendor/qcom
DTBO_SRC_PATH = "${STAGING_KERNEL_BUILDDIR}/arch/${ARCH}/boot/dts/vendor/qcom/"

# Auto generate kernel config by appending .cfg(s) from kernel tree.
DYNAMIC_DEFCONFIG = "${@d.getVar('KERNEL_DYNAMIC_DEFCONFIG') or "False"}"

do_generate_defconfig () {
        ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} REAL_CC=${STAGING_BINDIR_NATIVE}/clang \
        LD=${CCACHE}${HOST_PREFIX}ld KERN_OUT=${STAGING_KERNEL_BUILDDIR} \
        ${STAGING_KERNEL_DIR}/scripts/gki/generate_defconfig.sh ${KERNEL_CONFIG}
}
do_configure[prefuncs] += "${@oe.utils.conditional('DYNAMIC_DEFCONFIG', 'True', 'do_generate_defconfig', '', d)}"

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

do_deploy_append () {
        # Copy all modules from kernel techpack(s) into deploy directory
        COPY_SRC=$(find ${D}/lib/modules/ -type d -wholename "*/techpack")
        for TECHPACK in ${COPY_SRC}; do
                COPY_DEST="${DEPLOYDIR}/kernel_modules"
                find ${TECHPACK} -type f -name "*.ko" -exec sh -c '
                MODULE_DEST=$(dirname $2/$(echo $1 | sed 's/.*techpack.//'))
                install -d $MODULE_DEST
                install -m 0644 $1 $MODULE_DEST' sh {} ${COPY_DEST} ';'
        done
}
