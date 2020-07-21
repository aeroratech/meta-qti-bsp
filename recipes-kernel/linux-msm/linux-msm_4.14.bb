require recipes-kernel/linux-msm/linux-msm.inc

# if is TARGET_KERNEL_ARCH is set inherit qtikernel-arch to compile for that arch.
inherit ${@bb.utils.contains('TARGET_KERNEL_ARCH', 'aarch64', 'qtikernel-arch', '', d)}

COMPATIBLE_MACHINE = "(qcs40x|qcs610)"

# Additional configs for qcs610 machine
SRC_URI_append_qcs610 = " \
    file://disableipa3.cfg \
    file://sdmsteppe_iot_configs.cfg \
    ${@bb.utils.contains_any('COMBINED_FEATURES', 'qti-video qti-camera', 'file://multimedia.cfg', '', d)} \
    ${@bb.utils.contains('COMBINED_FEATURES', 'qti-video', 'file://video.cfg', '', d)} \
    ${@bb.utils.contains('COMBINED_FEATURES', 'drm', 'file://gfx.cfg', '', d)} \
    ${@bb.utils.contains_any('COMBINED_FEATURES', 'qti-camera mm-camera', 'file://camera.cfg', '', d)} \
    ${@bb.utils.contains('COMBINED_FEATURES', 'drm', 'file://display_drm.cfg', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'qti-fastcv', 'file://fastcv.cfg', '', d)} \
"

# Additional configs for qcs40x machines
SRC_URI_append_qcs40x = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'selinux', '', 'file://disableselinux.cfg', d)} \
"

SRC_DIR   =  "${WORKSPACE}/kernel/msm-4.14"
S         =  "${WORKDIR}/kernel/msm-4.14"

DEPENDS += "dtc-native"

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
