# QTI Linux mbb minimal image file.
# Provides packages required to build a csm image with
# boot to console

inherit qimage qramdisk

IMAGE_FEATURES[validitems] += "csm"
IMAGE_FEATURES += "read-only-rootfs csm"

CORE_IMAGE_EXTRA_INSTALL += "\
              glib-2.0 \
              coreutils \
              powerapp \
              powerapp-powerconfig \
              powerapp-reboot \
              powerapp-shutdown \
              packagegroup-qti-data \
              systemd-machine-units \
              packagegroup-android-utils \
              packagegroup-startup-scripts \
              ${@bb.utils.contains('DISTRO_FEATURES','selinux', 'packagegroup-selinux-minimal', '', d)} \
              packagegroup-qti-core \
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

addtask do_merge_dtbs after do_makesystem before do_makeboot
