# Provides packages required to build
# QTI Ramdisk archive

#inherit linux-kernel-base

LICENSE = "BSD-3-Clause"
DEPENDS += "gen-initramfs-native"

INIT_RAMDISK = "${@d.getVar('MACHINE_SUPPORTS_INIT_RAMDISK') or "False"}"
#KERNEL_VERSION = "${@get_kernelversion_headers('${STAGING_KERNEL_DIR}')}"
KERNEL_VERSION = "${@d.getVar('PREFERRED_VERSION_linux-msm')}"

PACKAGE_INSTALL = "\
    adbd \
    usb-composition \
    busybox \
    ext4-utils \
    libbase \
    fsmgr \
    liblog \
    libcutils \
    libsparse \
    libmincrypt \
    glib-2.0 \
    logwrapper \
    libgcc \
    zlib \
    glibc \
    ${@bb.utils.contains('DISTRO_FEATURES', 'selinux', 'libselinux', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'selinux', 'libpcre', '', d)} \
"

IMAGE_FEATURES = ""
IMAGE_LINGUAS = ""

inherit core-image

fakeroot do_ramdisk_create() {
    bbnote kernel version is: ${KERNEL_VERSION}
    mkdir -p ${IMAGE_ROOTFS}/bin
    mkdir -p ${IMAGE_ROOTFS}/dev
    mkdir -p ${IMAGE_ROOTFS}/etc/init.d
    mkdir -p ${IMAGE_ROOTFS}/lib/modules
    mkdir -p ${IMAGE_ROOTFS}/lib/modules/${KERNEL_VERSION}

    mknod -m 0600 ${IMAGE_ROOTFS}/dev/console c 5 1
    mknod -m 0600 ${IMAGE_ROOTFS}/dev/tty c 5 0
    mknod -m 0600 ${IMAGE_ROOTFS}/dev/tty0 c 4 0
    mknod -m 0600 ${IMAGE_ROOTFS}/dev/tty1 c 4 1
    mknod -m 0600 ${IMAGE_ROOTFS}/dev/tty2 c 4 2
    mknod -m 0600 ${IMAGE_ROOTFS}/dev/tty3 c 4 3
    mknod -m 0600 ${IMAGE_ROOTFS}/dev/tty4 c 4 4
    mknod -m 0600 ${IMAGE_ROOTFS}/dev/zero c 1 5

    mkdir -p ${IMAGE_ROOTFS}/dev/pts
    mkdir -p ${IMAGE_ROOTFS}/root
    mkdir -p ${IMAGE_ROOTFS}/proc
    mkdir -p ${IMAGE_ROOTFS}/sys

    cp ${COREBASE}/meta-qti-bsp/recipes-core/busybox/files/fstab ${IMAGE_ROOTFS}/etc/
    cp ${COREBASE}/meta-qti-bsp/recipes-core/busybox/files/inittab ${IMAGE_ROOTFS}/etc/
    cp ${COREBASE}/meta-qti-bsp/recipes-core/busybox/files/profile ${IMAGE_ROOTFS}/etc/
    cp ${COREBASE}/meta-qti-bsp/recipes-core/busybox/files/rcS ${IMAGE_ROOTFS}/etc/init.d

    # Run rcS script only if busybox is init manager in ramdisk.
    # In other cases, ramdisk will be used in early boot but no init in busybox.
    if ${@oe.utils.conditional('INIT_RAMDISK', 'True', 'true', 'false', d)}; then
      chmod 744 ${IMAGE_ROOTFS}/etc/init.d/rcS
    fi

    if [ -f ${KERNEL_PREBUILT_PATH}/modules.list.neo ]; then
        while read p; do
            if [ -f ${KERNEL_PREBUILT_PATH}/$p ]; then
                cp ${KERNEL_PREBUILT_PATH}/$p ${IMAGE_ROOTFS}/lib/modules/${KERNEL_VERSION}
            else
                bbnote skip $p module since not available as prebuilt
            fi
        done < ${KERNEL_PREBUILT_PATH}/modules.list.neo
    else
        # work around to pack ko when "modules.list.neo" is not available. This code will be deleted later
        cp ${KERNEL_PREBUILT_PATH}/qcom_ipc_logging.ko ${IMAGE_ROOTFS}/lib/modules/${KERNEL_VERSION}
        cp ${KERNEL_PREBUILT_PATH}/ns.ko ${IMAGE_ROOTFS}/lib/modules/${KERNEL_VERSION}
        cp ${KERNEL_PREBUILT_PATH}/qrtr.ko ${IMAGE_ROOTFS}/lib/modules/${KERNEL_VERSION}
        cp ${KERNEL_PREBUILT_PATH}/crc8.ko ${IMAGE_ROOTFS}/lib/modules/${KERNEL_VERSION}
        cp ${KERNEL_PREBUILT_PATH}/lzo.ko ${IMAGE_ROOTFS}/lib/modules/${KERNEL_VERSION}
        cp ${KERNEL_PREBUILT_PATH}/lzo-rle.ko ${IMAGE_ROOTFS}/lib/modules/${KERNEL_VERSION}
        cp ${KERNEL_PREBUILT_PATH}/zsmalloc.ko ${IMAGE_ROOTFS}/lib/modules/${KERNEL_VERSION}
        cp ${KERNEL_PREBUILT_PATH}/qcom_edac.ko ${IMAGE_ROOTFS}/lib/modules/${KERNEL_VERSION}
        #    cp ${KERNEL_PREBUILT_PATH}/icc-test.ko ${IMAGE_ROOTFS}/lib/modules/${KERNEL_VERSION}
        #    cp ${KERNEL_PREBUILT_PATH}/icc-bcm-voter.ko ${IMAGE_ROOTFS}/lib/modules/${KERNEL_VERSION}
        #    cp ${KERNEL_PREBUILT_PATH}/icc-debug.ko ${IMAGE_ROOTFS}/lib/modules/${KERNEL_VERSION}
        #    cp ${KERNEL_PREBUILT_PATH}/qnoc-neo.ko ${IMAGE_ROOTFS}/lib/modules/${KERNEL_VERSION}
        #    cp ${KERNEL_PREBUILT_PATH}/icc-rpmh.ko ${IMAGE_ROOTFS}/lib/modules/${KERNEL_VERSION}
        #    cp ${KERNEL_PREBUILT_PATH}/qnoc-qos.ko ${IMAGE_ROOTFS}/lib/modules/${KERNEL_VERSION}
        cp ${KERNEL_PREBUILT_PATH}/msm-geni-se.ko ${IMAGE_ROOTFS}/lib/modules/${KERNEL_VERSION}
        #    cp ${KERNEL_PREBUILT_PATH}/qcom-pdc.ko ${IMAGE_ROOTFS}/lib/modules/${KERNEL_VERSION}
        #    cp ${KERNEL_PREBUILT_PATH}/stub-regulator.ko ${IMAGE_ROOTFS}/lib/modules/${KERNEL_VERSION}
        cp ${KERNEL_PREBUILT_PATH}/qcom-scm.ko ${IMAGE_ROOTFS}/lib/modules/${KERNEL_VERSION}
        cp ${KERNEL_PREBUILT_PATH}/arm_smmu.ko ${IMAGE_ROOTFS}/lib/modules/${KERNEL_VERSION}
        cp ${KERNEL_PREBUILT_PATH}/iommu-logger.ko ${IMAGE_ROOTFS}/lib/modules/${KERNEL_VERSION}
        cp ${KERNEL_PREBUILT_PATH}/qcom_iommu_util.ko ${IMAGE_ROOTFS}/lib/modules/${KERNEL_VERSION}
        cp ${KERNEL_PREBUILT_PATH}/qcom_llcc_pmu.ko ${IMAGE_ROOTFS}/lib/modules/${KERNEL_VERSION}
        cp ${KERNEL_PREBUILT_PATH}/llcc-qcom.ko ${IMAGE_ROOTFS}/lib/modules/${KERNEL_VERSION}
        cp ${KERNEL_PREBUILT_PATH}/qmi_helpers.ko ${IMAGE_ROOTFS}/lib/modules/${KERNEL_VERSION}
        #    cp ${KERNEL_PREBUILT_PATH}/cmd-db.ko ${IMAGE_ROOTFS}/lib/modules/${KERNEL_VERSION}
        cp ${KERNEL_PREBUILT_PATH}/pmic_glink.ko ${IMAGE_ROOTFS}/lib/modules/${KERNEL_VERSION}
        cp ${KERNEL_PREBUILT_PATH}/qcom_soc_wdt.ko ${IMAGE_ROOTFS}/lib/modules/${KERNEL_VERSION}
        cp ${KERNEL_PREBUILT_PATH}/smem.ko ${IMAGE_ROOTFS}/lib/modules/${KERNEL_VERSION}
        cp ${KERNEL_PREBUILT_PATH}/qcom_sync_file.ko ${IMAGE_ROOTFS}/lib/modules/${KERNEL_VERSION}
        cp ${KERNEL_PREBUILT_PATH}/socinfo.ko ${IMAGE_ROOTFS}/lib/modules/${KERNEL_VERSION}
        cp ${KERNEL_PREBUILT_PATH}/llcc_perfmon.ko ${IMAGE_ROOTFS}/lib/modules/${KERNEL_VERSION}
        cp ${KERNEL_PREBUILT_PATH}/memory_dump_v2.ko ${IMAGE_ROOTFS}/lib/modules/${KERNEL_VERSION}
        cp ${KERNEL_PREBUILT_PATH}/pdr_interface.ko ${IMAGE_ROOTFS}/lib/modules/${KERNEL_VERSION}
        cp ${KERNEL_PREBUILT_PATH}/qcom_wdt_core.ko ${IMAGE_ROOTFS}/lib/modules/${KERNEL_VERSION}
        #    cp ${KERNEL_PREBUILT_PATH}/qcom_rpmh.ko ${IMAGE_ROOTFS}/lib/modules/${KERNEL_VERSION}
        cp ${KERNEL_PREBUILT_PATH}/clk-qcom.ko ${IMAGE_ROOTFS}/lib/modules/${KERNEL_VERSION}
        cp ${KERNEL_PREBUILT_PATH}/clk-dummy.ko ${IMAGE_ROOTFS}/lib/modules/${KERNEL_VERSION}
        cp ${KERNEL_PREBUILT_PATH}/zram.ko ${IMAGE_ROOTFS}/lib/modules/${KERNEL_VERSION}
        cp ${KERNEL_PREBUILT_PATH}/msm_geni_serial.ko ${IMAGE_ROOTFS}/lib/modules/${KERNEL_VERSION}
        #    cp ${KERNEL_PREBUILT_PATH}/pinctrl-neo.ko ${IMAGE_ROOTFS}/lib/modules/${KERNEL_VERSION}
        #    cp ${KERNEL_PREBUILT_PATH}/pinctrl-msm.ko ${IMAGE_ROOTFS}/lib/modules/${KERNEL_VERSION}
        cp ${KERNEL_PREBUILT_PATH}/phy-generic.ko ${IMAGE_ROOTFS}/lib/modules/${KERNEL_VERSION}
        cp ${KERNEL_PREBUILT_PATH}/phy-qcom-emu.ko ${IMAGE_ROOTFS}/lib/modules/${KERNEL_VERSION}
        cp ${KERNEL_PREBUILT_PATH}/dwc3-msm.ko ${IMAGE_ROOTFS}/lib/modules/${KERNEL_VERSION}
    fi

    cd ${IMAGE_ROOTFS}
    ln -sf bin sbin
    ln -s bin/busybox init

    cd ${STAGING_BINDIR_NATIVE}/scripts/
    # remove the initrd.gz file if exist
    rm -rf ${IMGDEPLOYDIR}/${PN}-initrd.gz
    ./gen_initramfs.sh -o ${IMGDEPLOYDIR}/${PN}-initrd.gz -u 0 -g 0 ${IMAGE_ROOTFS}

    cd ${CURRENT_DIR}
}

addtask do_ramdisk_create after do_image before do_image_complete
