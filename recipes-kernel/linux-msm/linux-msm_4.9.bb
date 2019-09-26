require recipes-kernel/linux-msm/linux-msm.inc

COMPATIBLE_MACHINE = "apq8009"

SRC_DIR   =  "${WORKSPACE}/kernel/msm-4.9"
S         =  "${WORKDIR}/kernel/msm-4.9"
PR = "r5"

DEPENDS += "dtc-native"

KERNEL_EXTRA_ARGS += "${@bb.utils.contains('DISTRO_FEATURES', 'avble', 'DTC_EXT=${STAGING_DIR_NATIVE}/usr/bin/dtc CONFIG_BUILD_ARM64_DT_OVERLAY=y', '', d)}"

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
        cp ${STAGING_KERNEL_DIR}/scripts/gen_initramfs_list.sh $kerneldir/scripts/

        # Generate kernel headers
        oe_runmake_call -C ${STAGING_KERNEL_DIR} ARCH=${ARCH} CC="${KERNEL_CC}" LD="${KERNEL_LD}" headers_install O=${STAGING_KERNEL_BUILDDIR}
}

do_deploy_append () {
        # Copy vmlinux and zImage into deplydir for boot.img creation
        install -d ${DEPLOYDIR}
        install -m 0644 ${KERNEL_OUTPUT_DIR}/${KERNEL_IMAGETYPE} ${DEPLOYDIR}/${KERNEL_IMAGETYPE}
        install -m 0644 vmlinux ${DEPLOYDIR}
}
