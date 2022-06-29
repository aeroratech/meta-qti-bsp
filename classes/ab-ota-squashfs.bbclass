# To add OTA upgrade support on an emmc/ufs target,
# add the MACHINE name to this list.
# This is the "only" list that will control whether
# OTA upgrade will be supported on a target.
DEPENDS += "releasetools-native zip-native fsconfig-native applypatch-native bc-native bsdiff-native"

RM_WORK_EXCLUDE_ITEMS += "rootfs rootfs-dbg"

IMAGE_SYSTEM_MOUNT_POINT = "/"

OTA_TARGET_IMAGE_ROOTFS_SQSH = "${WORKDIR}/ota-target-image-sqsh"

OTA_TARGET_FILES_SQSH = "target-files-sqsh.zip"
OTA_TARGET_FILES_SQSH_PATH = "${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/${FS_TYPE_SQSH}/${OTA_TARGET_FILES_SQSH}"
OTA_FULL_UPDATE_SQSH = "full_update_sqsh.zip"
OTA_FULL_UPDATE_SQSH_PATH = "${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/${FS_TYPE_SQSH}/${OTA_FULL_UPDATE_SQSH}"
OTA_INCREMENTAL_UPDATE_SQSH = "incremental_update_sqsh.zip"
OTA_INCREMENTAL_UPDATE_SQSH_PATH = "${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/${FS_TYPE_SQSH}/${OTA_INCREMENTAL_UPDATE_SQSH}"

MACHINE_FILESMAP_SEARCH_PATH ?= "${@':'.join('%s/conf/machine/filesmap' % p for p in '${BBPATH}'.split(':'))}}"
MACHINE_FILESMAP_FULL_PATH = "${@machine_search(d.getVar('MACHINE_FILESMAP_CONF'), d.getVar('MACHINE_FILESMAP_SEARCH_PATH')) or ''}"

#Create directory structure for targetfiles.zip
do_recovery_sqsh[cleandirs] += "${OTA_TARGET_IMAGE_ROOTFS_SQSH}"
do_recovery_sqsh[cleandirs] += "${OTA_TARGET_IMAGE_ROOTFS_SQSH}/BOOTABLE_IMAGES"
do_recovery_sqsh[cleandirs] += "${OTA_TARGET_IMAGE_ROOTFS_SQSH}/DATA"
do_recovery_sqsh[cleandirs] += "${OTA_TARGET_IMAGE_ROOTFS_SQSH}/META"
do_recovery_sqsh[cleandirs] += "${OTA_TARGET_IMAGE_ROOTFS_SQSH}/OTA"
do_recovery_sqsh[cleandirs] += "${OTA_TARGET_IMAGE_ROOTFS_SQSH}/RECOVERY"
do_recovery_sqsh[cleandirs] += "${OTA_TARGET_IMAGE_ROOTFS_SQSH}/SYSTEM"
do_recovery_sqsh[cleandirs] += "${OTA_TARGET_IMAGE_ROOTFS_SQSH}/RADIO"
do_recovery_sqsh[cleandirs] += "${OTA_TARGET_IMAGE_ROOTFS_SQSH}/IMAGES"
do_recovery_sqsh[cleandirs] += "${OTA_TARGET_IMAGE_ROOTFS_SQSH}/DTBO"

# Create this folder just for saving file_contexts(SElinux security context file),
# It will be used to generate OTA packages when selinux_fc is set.
do_recovery_sqsh[cleandirs] += "${OTA_TARGET_IMAGE_ROOTFS_SQSH}/BOOT/RAMDISK"

# recovery rootfs is required for generating OTA files.
# Wait till all tasks of machine-recovery-image complete.

do_recovery_sqsh() {
    echo "base image rootfs: ${IMAGE_ROOTFS}"

    # if exists copy filesmap into RADIO directory
    radiofilesmap=${MACHINE_FILESMAP_FULL_PATH}
    [[ ! -z "$radiofilesmap" ]] && install -m 755 $radiofilesmap ${OTA_TARGET_IMAGE_ROOTFS_SQSH}/RADIO/

    # copy the boot\recovery images
    cp ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/${FS_TYPE_SQSH}/${BOOTIMAGE_TARGET} ${OTA_TARGET_IMAGE_ROOTFS_SQSH}/BOOTABLE_IMAGES/boot.img
    cp ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/${FS_TYPE_SQSH}/${BOOTIMAGE_TARGET} ${OTA_TARGET_IMAGE_ROOTFS_SQSH}/BOOTABLE_IMAGES/recovery.img
    cp ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/${FS_TYPE_SQSH}/${BOOTIMAGE_TARGET} ${OTA_TARGET_IMAGE_ROOTFS_SQSH}/IMAGES/boot.img
    cp ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/${FS_TYPE_SQSH}/${BOOTIMAGE_TARGET} ${OTA_TARGET_IMAGE_ROOTFS_SQSH}/IMAGES/recovery.img

    # what we have is a squashfs image.
    # OTA scripts expect a sparse image for block-based package.
    # run img2simg on the squashfs image - this is purely aesthetic
    # and adds no value to the compression of the image.
   
    squashfs2sparse ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/${FS_TYPE_SQSH}/${SYSTEMIMAGE_TARGET} ${OTA_TARGET_IMAGE_ROOTFS_SQSH}/IMAGES/system.img


    cp ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/${FS_TYPE_SQSH}/${USERDATAIMAGE_TARGET} ${OTA_TARGET_IMAGE_ROOTFS_SQSH}/IMAGES/userdata.img
    cp ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/${FS_TYPE_SQSH}/${USERDATAIMAGE_MAP_TARGET} ${OTA_TARGET_IMAGE_ROOTFS_SQSH}/IMAGES/userdata.map

    # if dtbo.img file exist then copy
    if [ -f ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/${DTBOIMAGE_TARGET} ]; then
        cp ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/${DTBOIMAGE_TARGET} ${OTA_TARGET_IMAGE_ROOTFS_SQSH}/IMAGES/dtbo.img
    fi

    # copy the contents of system rootfs
    cp -r ${IMAGE_ROOTFS_SQSH}/. ${OTA_TARGET_IMAGE_ROOTFS_SQSH}/SYSTEM/.
    cd  ${OTA_TARGET_IMAGE_ROOTFS_SQSH}/SYSTEM
    rm -rf var/run
    ln -snf ../run var/run

    # copy the contents of system overlayfs
    cp -r ${IMAGE_ROOTFS_SQSH}/overlay/. ${OTA_TARGET_IMAGE_ROOTFS_SQSH}/DATA/.

    cp -r ${IMAGE_ROOTFS_SQSH}/. ${OTA_TARGET_IMAGE_ROOTFS_SQSH}/RECOVERY/.

    # set block img diff version to v3
    echo "blockimgdiff_versions=3" >> ${OTA_TARGET_IMAGE_ROOTFS_SQSH}/META/misc_info.txt

    #generate recovery.fstab which is used by the updater-script
    echo #mount point fstype device [device2] >> ${OTA_TARGET_IMAGE_ROOTFS_SQSH}/RECOVERY/recovery.fstab
    echo /boot     emmc  /dev/block/bootdevice/by-name/boot >> ${OTA_TARGET_IMAGE_ROOTFS_SQSH}/RECOVERY/recovery.fstab
    echo /overlay     ext4  /dev/block/bootdevice/by-name/userdata >> ${OTA_TARGET_IMAGE_ROOTFS_SQSH}/RECOVERY/recovery.fstab
    echo ${IMAGE_SYSTEM_MOUNT_POINT}   squashfs  /dev/block/bootdevice/by-name/system >> ${OTA_TARGET_IMAGE_ROOTFS_SQSH}/RECOVERY/recovery.fstab

    #Getting content for OTA folder
    mkdir -p ${OTA_TARGET_IMAGE_ROOTFS_SQSH}/OTA/bin
    cp ${OTA_TARGET_IMAGE_ROOTFS_SQSH}/RECOVERY/usr/bin/applypatch ${OTA_TARGET_IMAGE_ROOTFS_SQSH}/OTA/bin/.

    cp ${OTA_TARGET_IMAGE_ROOTFS_SQSH}/RECOVERY/usr/bin/updater ${OTA_TARGET_IMAGE_ROOTFS_SQSH}/OTA/bin/.

    # Pack releasetools.py into META folder itself.
    # This could also have been done by passing "--device_specific" to
    # ota_from_target_files.py but it would be hacky to find the absolute path there.
    cp ${WORKSPACE}/OTA/device/qcom/common/releasetools.py ${OTA_TARGET_IMAGE_ROOTFS_SQSH}/META/.

    # copy contents of META folder
    #recovery_api_version is from recovery module
    echo recovery_api_version=3 >> ${OTA_TARGET_IMAGE_ROOTFS_SQSH}/META/misc_info.txt

    #blocksize = BOARD_FLASH_BLOCK_SIZE
    echo blocksize=131072 >> ${OTA_TARGET_IMAGE_ROOTFS_SQSH}/META/misc_info.txt

    export BOOT_SIZE=$(sed -r 's/.*label="boot_a".*size_in_kb="([0-9]+\.*[0-9]*).*/\1/;t;d' ${WORKDIR}/partition.xml)
    export SYSTEM_SIZE=$(sed -r 's/.*label="system_a".*size_in_kb="([0-9]+\.*[0-9]*).*/\1/;t;d' ${WORKDIR}/partition.xml)
    export USERDATA_SIZE=$(sed -r 's/.*label="userdata".*size_in_kb="([0-9]+\.*[0-9]*).*/\1/;t;d' ${WORKDIR}/partition.xml)

    # convert kb to bytes
    export BOOT_SIZE="$(expr $BOOT_SIZE \* 1024)"
    export SYSTEM_SIZE="$(expr $SYSTEM_SIZE \* 1024)"
    export USERDATA_SIZE="$(expr $USERDATA_SIZE \* 1024)"

    #boot_size: Size of boot partition from partition.xml
    echo "boot_size=0x$(echo "obase=16; $BOOT_SIZE" | bc)" >> ${OTA_TARGET_IMAGE_ROOTFS_SQSH}/META/misc_info.txt

    #system_size : Size of system partition from partition.xml
    echo "system_size=0x$(echo "obase=16; $SYSTEM_SIZE" | bc)" >> ${OTA_TARGET_IMAGE_ROOTFS_SQSH}/META/misc_info.txt

    #userdata_size : Size of data partition from partition.xml
    echo "userdata_size=0x$(echo "obase=16; $USERDATA_SIZE" | bc)" >> ${OTA_TARGET_IMAGE_ROOTFS_SQSH}/META/misc_info.txt

    #cache_size : Size of data partition from partition.xml
    echo "cache_size=0x$(echo "obase=16; $USERDATA_SIZE" | bc)" >> ${OTA_TARGET_IMAGE_ROOTFS_SQSH}/META/misc_info.txt

    #mkyaffs2_extra_flags : -c $(BOARD_KERNEL_PAGESIZE) -s $(BOARD_KERNEL_SPARESIZE)
    echo mkyaffs2_extra_flags=-c 4096 -s 16 >> ${OTA_TARGET_IMAGE_ROOTFS_SQSH}/META/misc_info.txt

    #extfs_sparse_flag : definition in build
    echo extfs_sparse_flags=-s >> ${OTA_TARGET_IMAGE_ROOTFS_SQSH}/META/misc_info.txt

    #default_system_dev_certificate : Dummy location
    echo default_system_dev_certificate=build/abcd >> ${OTA_TARGET_IMAGE_ROOTFS_SQSH}/META/misc_info.txt

    # set block img diff version to v3
    echo "blockimgdiff_versions=3" >> ${OTA_TARGET_IMAGE_ROOTFS_SQSH}/META/misc_info.txt

    # Targets that support A/B boot do not need recovery(fs)-updater
    echo le_target_supports_ab=1 >> ${OTA_TARGET_IMAGE_ROOTFS_SQSH}/META/misc_info.txt

    cd ${OTA_TARGET_IMAGE_ROOTFS_SQSH} && zip -qry ${OTA_TARGET_FILES_SQSH_PATH} *
}
addtask do_recovery_sqsh after do_image_complete before do_build

# Generate OTA zip files
do_gen_ota_incremental_zip_sqsh[dirs] += "${DEPLOY_DIR_IMAGE}/ota-scripts"
do_gen_ota_incremental_zip_sqsh() {
    if [ -f "${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/${OTA_TARGET_FILES_SQSH}" ]; then

        ./incremental_ota.sh ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/${OTA_TARGET_FILES_SQSH} ${OTA_TARGET_FILES_SQSH_PATH} ${IMAGE_ROOTFS} ext4 --block --system_path ${IMAGE_SYSTEM_MOUNT_POINT}

        cp update_incr_ext4.zip ${DEPLOY_DIR_IMAGE}/${OTA_INCREMENTAL_UPDATE_SQSH}
    else
        return 0
    fi
}

do_gen_ota_full_zip_sqsh[dirs] += "${DEPLOY_DIR_IMAGE}/ota-scripts"
do_gen_ota_full_zip_sqsh() {
    ./full_ota.sh ${OTA_TARGET_FILES_SQSH_PATH} ${IMAGE_ROOTFS} emmc_sqsh --block --system_path ${IMAGE_SYSTEM_MOUNT_POINT}

    cp update_emmc_sqsh.zip ${OTA_FULL_UPDATE_SQSH_PATH}
}
addtask do_gen_ota_full_zip_sqsh after do_recovery_sqsh before do_build
