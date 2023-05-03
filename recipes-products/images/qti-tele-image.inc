inherit qimage populate_sdk_qti ${@bb.utils.contains('MACHINE_FEATURES', 'dm-verity-initramfs-v4', 'qramdisk', '', d)}

IMAGE_FEATURES += "read-only-rootfs ${@bb.utils.contains('IMAGE_FSTYPES', 'ubi', 'persist-volume', '', d)} \
                   ${@bb.utils.contains('MACHINE_FEATURES', 'tele-squashfs-ubi', 'nad-modem-volume telaf-volume', '', d)}"

python () {
    if d.getVar('PREFERRED_VERSION_linux-msm') == "5.15":
        bb.build.addtask('do_merge_dtbs', 'do_makeboot', bb.utils.contains('IMAGE_FSTYPES', 'ubi', 'do_makesystem_ubi', 'do_makesystem', d), d)
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

# Remove unsupported SDK packages
TOOLCHAIN_TARGET_TASK_remove = "ath6kl-utils-staticdev"
TOOLCHAIN_TARGET_TASK_remove = "kernel-devsrc"
