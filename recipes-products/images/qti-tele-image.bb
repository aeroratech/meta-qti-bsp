# QTI Linux Telematics image file.
# Provides packages required to build
# QTI Linux Telematics image.

inherit qimage

IMAGE_FEATURES += "read-only-rootfs ${@bb.utils.contains('IMAGE_FSTYPES', 'ubi', 'persist-volume', '', d)}"

CORE_IMAGE_EXTRA_INSTALL += "\
        ${@bb.utils.contains('MACHINE_FEATURES', 'emmc-boot', 'e2fsprogs e2fsprogs-e2fsck e2fsprogs-mke2fs', '', d)} \
        glib-2.0 \
        i2c-tools \
        kernel-modules \
        net-tools \
        pps-tools \
        spitools \
        coreutils \
        packagegroup-android-utils \
        packagegroup-qti-core \
        ${@bb.utils.contains('MACHINE_FEATURES', 'qti-data-modem', 'packagegroup-qti-data', '', d)} \
        ${@bb.utils.contains_any('COMBINED_FEATURES', 'qti-adsp qti-cdsp qti-modem qti-slpi', 'packagegroup-qti-dsp', '', d)} \
        ${@bb.utils.contains('MACHINE_FEATURES', 'qti-location', 'packagegroup-qti-location packagegroup-qti-location-auto', '', d)} \
        ${@bb.utils.contains('MACHINE_FEATURES', 'qti-bluetooth', 'packagegroup-qti-bt', '', d)} \
        ${@bb.utils.contains('MACHINE_FEATURES', 'qti-wlan', 'packagegroup-qti-wlan', '', d)} \
        ${@bb.utils.contains('COMBINED_FEATURES', 'qti-security', 'packagegroup-qti-securemsm', '', d)} \
        ${@bb.utils.contains('COMBINED_FEATURES', 'qti-audio', 'packagegroup-qti-audio', '', d)} \
        packagegroup-qti-ss-mgr \
        packagegroup-qti-telematics \
        ${@bb.utils.contains('DISTRO_FEATURES', 'qti-telux', 'packagegroup-qti-telsdk', '', d)} \
        ${@bb.utils.contains('DISTRO_FEATURES', 'selinux', 'packagegroup-selinux-minimal', '', d)} \
        packagegroup-startup-scripts \
        packagegroup-support-utils \
        subsystem-ramdump \
        systemd-machine-units \
        ${@bb.utils.contains('MACHINE_FEATURES', 'nand-boot', 'mtd-utils-ubifs', '', d)} \
        qmi-shutdown-modem \
        modem-shutdown \
        ${@oe.utils.conditional('DEBUG_BUILD', '1', 'packagegroup-qti-debug-tools', '', d )} \
"

# Following packages will be enabled later
CORE_IMAGE_EXTRA_INSTALL_remove_sa410m = "\
       qmi-shutdown-modem \
       packagegroup-qti-telsdk \
"

# Following packages will be enabled later
CORE_IMAGE_EXTRA_INSTALL_remove_sa525m = "\
       packagegroup-qti-telsdk subsystem-ramdump \
       qmi-shutdown-modem modem-shutdown \
       packagegroup-qti-internal packagegroup-qti-security-test \
       packagegroup-support-utils \
"

python () {
    if d.getVar('PREFERRED_VERSION_linux-msm') == "5.15":
        bb.build.addtask('do_merge_dtbs', 'do_makeboot', 'do_makesystem', d)
        bb.build.addtask('do_copy_abl', 'do_image_complete', 'do_makeboot', d)
}

do_merge_dtbs() {
    install -d ${DEPLOY_DIR_IMAGE}/build-artifacts/techpack-dtbos
    cd ${WORKSPACE}/kernel-${PREFERRED_VERSION_linux-msm}/kernel_platform && \
    LD_LIBRARY_PATH=../out/msm-kernel-${MACHINE}-${KERNEL_VARIANT}defconfig/host/lib/:LD_LIBRARY_PATH \
    OUT_DIR=${KERNEL_OUT_PATH}/ \
    BUILD_CONFIG=${KERNEL_BUILD_CONFIG}  \
    ./build/android/merge_dtbs.sh \
    ${DEPLOY_DIR_IMAGE}/build-artifacts/dtb \
    ${DEPLOY_DIR_IMAGE}/build-artifacts/techpack-dtbos ${DEPLOY_DIR_IMAGE}/dtbs
}
do_merge_dtbs[depends] += "virtual/kernel:do_deploy"

do_copy_abl[dirs] = "${DEPLOY_DIR_IMAGE}"
do_copy_abl() {
    if [ -f ${KERNEL_PREBUILT_PATH}/abl_userdebug.elf ]; then
        install -m 0644 ${KERNEL_PREBUILT_PATH}/abl_userdebug.elf ${DEPLOY_DIR_IMAGE}/${PN}/abl_userdebug.elf
    fi
}

# Following pacakges will be enabled later.
CORE_IMAGE_EXTRA_INSTALL_remove_sa415m = "qmi-shutdown-modem"
