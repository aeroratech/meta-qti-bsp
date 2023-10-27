# QTI Linux mbb minimal image file.
# Provides packages required to build a csm image with
# boot to console

inherit qimage qramdisk

# specify IMAGE_FEATURES += "ssh-server-openssh" to bring in
#    packagegroup-core-ssh-openssh -> openssh
IMAGE_FEATURES += "ssh-server-openssh"

IMAGE_FEATURES[validitems] += "csm"
IMAGE_FEATURES += "read-only-rootfs csm"

CORE_IMAGE_EXTRA_INSTALL += "\
              dhrystone \
              glib-2.0 \
              i2c-tools \
              coreutils \
              e2fsprogs \
              e2fsprogs-e2fsck \
              e2fsprogs-mke2fs \
              e2fsprogs-tune2fs \
              powerapp \
              powerapp-powerconfig \
              powerapp-reboot \
              powerapp-shutdown \
              packagegroup-qti-data \
              systemd-machine-units \
              packagegroup-qti-securemsm \
              packagegroup-android-utils \
              packagegroup-startup-scripts \
              packagegroup-qti-ss-mgr \
              ${@bb.utils.contains('DISTRO_FEATURES','selinux', 'packagegroup-selinux-minimal', '', d)} \
              ${@bb.utils.contains('MACHINE_FEATURES', 'qti-mplane', 'packagegroup-mplane', '', d)} \
              packagegroup-qti-core \
              packagegroup-qti-transceiver \
              packagegroup-transceiver-perf-measurement \
              packagegroup-transceiver-fault-management \
              packagegroup-sw-management \
              libbootreason \
              packagegroup-modem-ald-transport-simulation \
"

do_merge_dtbs() {
    install -d ${DEPLOY_DIR_IMAGE}/build-artifacts/techpack-dtbos
    cd ${WORKSPACE}/kernel-${PREFERRED_VERSION_linux-msm}/kernel_platform && \
    LD_LIBRARY_PATH=../out/msm-kernel-${MACHINE}-${KERNEL_VARIANT}defconfig/host/lib/:LD_LIBRARY_PATH \
    OUT_DIR=${WORKSPACE}/kernel-${PREFERRED_VERSION_linux-msm}/out/msm-kernel-${MACHINE}-${KERNEL_VARIANT}defconfig/ \
    BUILD_CONFIG=msm-kernel/build.config.msm.${MACHINE}  \
    ./build/android/merge_dtbs.sh \
    ${DEPLOY_DIR_IMAGE}/build-artifacts/dtb \
    ${DEPLOY_DIR_IMAGE}/build-artifacts/techpack-dtbos ${DEPLOY_DIR_IMAGE}/dtbs
}

do_copy_abl[dirs] = "${DEPLOY_DIR_IMAGE}"
do_copy_abl() {
    if [ -f ${KERNEL_PREBUILT_PATH}/abl_userdebug.elf ]; then
        install -m 0644 ${KERNEL_PREBUILT_PATH}/abl_userdebug.elf ${DEPLOY_DIR_IMAGE}/${PN}/abl_userdebug.elf
    fi
}

addtask do_merge_dtbs after do_makesystem before do_makeboot
addtask do_copy_abl after do_makeboot before do_image_complete
