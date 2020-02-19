require recipes-kernel/linux-msm/linux-msm.inc

COMPATIBLE_MACHINE = "qrb5165"

SRC_DIR   =  "${WORKSPACE}/kernel/msm-4.19"
S         =  "${WORKDIR}/kernel/msm-4.19"

SRC_URI_append_qrb5165-rb5 = " file://disableipa3.cfg"

DEPENDS += "dtc-native"

EXTRA_OEMAKE += "INSTALL_MOD_STRIP=1"

LIC_FILES_CHKSUM = "file://COPYING;md5=bbea815ee2795b2f4230826c0c6b8814"

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


        oe_runmake_call -C ${STAGING_KERNEL_DIR} ARCH=${ARCH} CC="${KERNEL_CC}" LD="${KERNEL_LD}" headers_install O=${STAGING_KERNEL_BUILDDIR}
}

do_deploy_append () {
        install -d ${DEPLOYDIR}
        install -m 0644 ${KERNEL_OUTPUT_DIR}/${KERNEL_IMAGETYPE} ${DEPLOYDIR}/${KERNEL_IMAGETYPE}
        install -m 0644 vmlinux ${DEPLOYDIR}
}

INHIBIT_PACKAGE_STRIP = "1"
