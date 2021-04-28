require recipes-kernel/linux-msm/linux-msm.inc

COMPATIBLE_MACHINE = "apq8009"

S         =  "${WORKDIR}/kernel/msm-4.9"
PR = "r5"

DEPENDS += "dtc-native"

SRC_URI_append = " \
      ${@bb.utils.contains_any('COMBINED_FEATURES', 'fbdev qti-camera qti-video mm-camera', 'file://graphics_fb.cfg', '', d)} \
      ${@bb.utils.contains_any('COMBINED_FEATURES', 'qti-camera qti-video mm-camera', 'file://multimedia.cfg', '', d)} \
      ${@bb.utils.contains_any('DISTRO_FEATURES', 'dm-verity', 'file://verity_android.cfg', '', d)} \
"
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
