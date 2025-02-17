require recipes-kernel/linux-msm/linux-msm.inc

COMPATIBLE_MACHINE = "qrb5165|sxr2130"

S         =  "${WORKDIR}/kernel/msm-4.19"

# Kona specific
SRC_URI_append_kona  = " file://disableipa3.cfg"
SRC_URI_append_kona += " file://android_binderfs.cfg"

# Robotics specific
SRC_URI_append_qrb5165 += " file://fbcon.cfg"
SRC_URI_append_qrb5165 += " file://qca6390.cfg"
SRC_URI_append_qrb5165 += " file://qcs7230.cfg"
SRC_URI_append_qrb5165 += "${@bb.utils.contains('DISTRO_FEATURES', 'virtualization', 'file://virtualization_robomaker.cfg', '', d)}"

#XR specific
SRC_URI_append_sxr2130 += " file://qca6490.cfg"

DEPENDS += "virtual/dtc-native"

EXTRA_OEMAKE += "INSTALL_MOD_STRIP=1"

LIC_FILES_CHKSUM = "file://COPYING;md5=bbea815ee2795b2f4230826c0c6b8814"

# Path for dtbo generation is kernel version dependent.
DTBO_SRC_PATH = "${STAGING_KERNEL_BUILDDIR}/arch/${ARCH}/boot/dts/vendor/qcom/"

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

INHIBIT_PACKAGE_STRIP = "1"
