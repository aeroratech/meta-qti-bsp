DEPENDS += "releasetools-native zip-native fsconfig-native applypatch-native bc-native bsdiff-native"

RM_WORK_EXCLUDE_ITEMS += "rootfs rootfs-dbg"

IMAGE_SYSTEM_MOUNT_POINT = "/system"
OTA_TARGET_IMAGE_ROOTFS_UBI = "${WORKDIR}/ota-target-image-ubi"
OTA_TARGET_FILES_UBI = "target-files-ubi.zip"
OTA_TARGET_FILES_UBI_PATH = "${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/${OTA_TARGET_FILES_UBI}"

MACHINE_FILESMAP_SEARCH_PATH ?= "${@':'.join('%s/conf/machine/filesmap' % p for p in '${BBPATH}'.split(':'))}}"
MACHINE_FILESMAP_FULL_PATH = "${@machine_search(d.getVar('MACHINE_FILESMAP_CONF_NAND'), d.getVar('MACHINE_FILESMAP_SEARCH_PATH')) or ''}"

#Create directory structure for targetfiles.zip
do_recovery_ubi[cleandirs] += "${OTA_TARGET_IMAGE_ROOTFS_UBI}"
do_recovery_ubi[cleandirs] += "${OTA_TARGET_IMAGE_ROOTFS_UBI}/BOOTABLE_IMAGES"
do_recovery_ubi[cleandirs] += "${OTA_TARGET_IMAGE_ROOTFS_UBI}/DATA"
do_recovery_ubi[cleandirs] += "${OTA_TARGET_IMAGE_ROOTFS_UBI}/META"
do_recovery_ubi[cleandirs] += "${OTA_TARGET_IMAGE_ROOTFS_UBI}/OTA"
do_recovery_ubi[cleandirs] += "${OTA_TARGET_IMAGE_ROOTFS_UBI}/RECOVERY"
do_recovery_ubi[cleandirs] += "${OTA_TARGET_IMAGE_ROOTFS_UBI}/SYSTEM"
do_recovery_ubi[cleandirs] += "${OTA_TARGET_IMAGE_ROOTFS_UBI}/RADIO"
do_recovery_ubi[cleandirs] += "${OTA_TARGET_IMAGE_ROOTFS_UBI}/IMAGES"
do_recovery_ubi[cleandirs] += "${OTA_TARGET_IMAGE_ROOTFS_UBI}/BOOT/RAMDISK"


do_recovery_ubi() {
    echo "base image rootfs: ${IMAGE_ROOTFS_UBI}"

    # if exists copy filesmap into RADIO directory
    radiofilesmap=${MACHINE_FILESMAP_FULL_PATH}
    [[ ! -z "$radiofilesmap" ]] && install -m 755 $radiofilesmap ${OTA_TARGET_IMAGE_ROOTFS_UBI}/RADIO/filesmap

    cp ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/${BOOTIMAGE_TARGET} ${OTA_TARGET_IMAGE_ROOTFS_UBI}/BOOTABLE_IMAGES/boot.img
    cp ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/${BOOTIMAGE_TARGET} ${OTA_TARGET_IMAGE_ROOTFS_UBI}/BOOTABLE_IMAGES/recovery.img


    cp -r ${IMAGE_ROOTFS_UBI}/. ${OTA_TARGET_IMAGE_ROOTFS_UBI}/SYSTEM/.
    cd  ${OTA_TARGET_IMAGE_ROOTFS_UBI}/SYSTEM
    rm -rf var/run
    ln -snf ../run var/run

    cp -r ${IMAGE_ROOTFS_UBI}/. ${OTA_TARGET_IMAGE_ROOTFS_UBI}/RECOVERY/.
    #generate recovery.fstab which is used by the updater-script
    #echo #mount point fstype device [device2] >> ${OTA_TARGET_IMAGE_ROOTFS_UBI}/RECOVERY/recovery.fstab
    echo /boot     mtd     boot >> ${OTA_TARGET_IMAGE_ROOTFS_UBI}/RECOVERY/recovery.fstab
    echo /cache    ubifs  cache >> ${OTA_TARGET_IMAGE_ROOTFS_UBI}/RECOVERY/recovery.fstab
    echo /data     ubifs  userdata >> ${OTA_TARGET_IMAGE_ROOTFS_UBI}/RECOVERY/recovery.fstab
    echo /recovery mtd     recovery >> ${OTA_TARGET_IMAGE_ROOTFS_UBI}/RECOVERY/recovery.fstab
    echo /system   ubifs     system >> ${OTA_TARGET_IMAGE_ROOTFS_UBI}/RECOVERY/recovery.fstab

    #Getting content for OTA folder
    mkdir -p ${OTA_TARGET_IMAGE_ROOTFS_UBI}/OTA/bin
    cp   ${OTA_TARGET_IMAGE_ROOTFS_UBI}/RECOVERY/usr/bin/applypatch ${OTA_TARGET_IMAGE_ROOTFS_UBI}/OTA/bin/.
    cp   ${OTA_TARGET_IMAGE_ROOTFS_UBI}/RECOVERY/usr/bin/updater ${OTA_TARGET_IMAGE_ROOTFS_UBI}/OTA/bin/.


    # Pack releasetools.py into META folder itself.
    # This could also have been done by passing "--device_specific" to
    # ota_from_target_files.py but it would be hacky to find the absolute path there.
    cp ${WORKSPACE}/OTA/device/qcom/common/releasetools.py ${OTA_TARGET_IMAGE_ROOTFS_UBI}/META/.


    # copy contents of META folder
    #recovery_api_version is from recovery module
    echo recovery_api_version=3 >> ${OTA_TARGET_IMAGE_ROOTFS_UBI}/META/misc_info.txt

    #blocksize = BOARD_FLASH_BLOCK_SIZE
    echo blocksize=131072 >> ${OTA_TARGET_IMAGE_ROOTFS_UBI}/META/misc_info.txt

    # boot_size: Size of boot partition from partition.xml
    echo boot_size=0x1900000 >> ${OTA_TARGET_IMAGE_ROOTFS_UBI}/META/misc_info.txt

    # recovery_size : Size of recovery partition from partition.xml
    echo recovery_size=0x00C00000 >> ${OTA_TARGET_IMAGE_ROOTFS_UBI}/META/misc_info.txt

    #system_size : Size of system partition from partition.xml
    echo system_size=0x00A00000 >> ${OTA_TARGET_IMAGE_ROOTFS_UBI}/META/misc_info.txt

    #userdate_size : Size of data partition from partition.xml
    echo userdata_size=0x00A00000 >> ${OTA_TARGET_IMAGE_ROOTFS_UBI}/META/misc_info.txt

    #cache_size : Size of data partition from partition.xml
    echo cache_size=0x00A00000 >> ${OTA_TARGET_IMAGE_ROOTFS_UBI}/META/misc_info.txt

    #mkyaffs2_extra_flags : -c $(BOARD_KERNEL_PAGESIZE) -s $(BOARD_KERNEL_SPARESIZE)
    echo mkyaffs2_extra_flags=-c 4096 -s 16 >> ${OTA_TARGET_IMAGE_ROOTFS_UBI}/META/misc_info.txt

    #extfs_sparse_flag : definition in build
    echo extfs_sparse_flags=-s >> ${OTA_TARGET_IMAGE_ROOTFS_UBI}/META/misc_info.txt

    #default_system_dev_certificate : Dummy location
    echo default_system_dev_certificate=build/abcd >> ${OTA_TARGET_IMAGE_ROOTFS_UBI}/META/misc_info.txt

    echo le_target_supports_ab=1 >> ${OTA_TARGET_IMAGE_ROOTFS_UBI}/META/misc_info.txt

    echo "blockimgdiff_versions=3" >> ${OTA_TARGET_IMAGE_ROOTFS_UBI}/META/misc_info.txt

    echo dm_verity_nand=1 >> ${OTA_TARGET_IMAGE_ROOTFS_UBI}/META/misc_info.txt
    cp ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/sysfs.ubifs ${OTA_TARGET_IMAGE_ROOTFS_UBI}/BOOTABLE_IMAGES/system.img
    cd ${OTA_TARGET_IMAGE_ROOTFS_UBI} && zip -qry ${OTA_TARGET_FILES_UBI_PATH} *
}

addtask do_recovery_ubi after do_image_complete before do_build

do_gen_otazip_ubi[dirs] += "${DEPLOY_DIR_IMAGE}/ota-scripts"
do_gen_otazip_ubi() {
    ./full_ota.sh ${OTA_TARGET_FILES_UBI_PATH} ${IMAGE_ROOTFS_UBI} ubi --block --system_path ${IMAGE_SYSTEM_MOUNT_POINT}

    if [[ -e update_ubi.zip ]]; then
        cp update_ubi.zip ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}
    else
        bbwarn "update_ubi.zip failed to create"
    fi
}
addtask do_gen_otazip_ubi after do_recovery_ubi before do_build
