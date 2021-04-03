DEPENDS += "releasetools-native zip-native fsconfig-native applypatch-native bc-native bsdiff-native qti-recovery-image"

RM_WORK_EXCLUDE_ITEMS += "rootfs rootfs-dbg"

RECOVERY_IMAGE_ROOTFS = "$(echo ${IMAGE_ROOTFS} | sed 's#${PN}#qti-recovery-image#')"

IMAGE_SYSTEM_MOUNT_POINT = "/"
OTA_TARGET_IMAGE_ROOTFS_UBI = "${WORKDIR}/ota-target-image-ubi"
OTA_TARGET_FILES_UBI = "target-files-ubi.zip"
OTA_TARGET_FILES_UBI_PATH = "${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/${OTA_TARGET_FILES_UBI}"

def get_filesmap(d):
    filesmap_path = ""
    overrides = (":" + (d.getVar("MACHINEOVERRIDES") or "")).split(":")
    overrides.reverse()

    for o in overrides:
        opath = "poky/meta-qti-bsp/recipes-bsp/base-files-recovery/" + o + "/radio/filesmap"
        path = os.path.join(d.getVar('WORKSPACEROOT'), opath)
        if os.path.exists(path):
            filesmap_path = path
            break
    return filesmap_path

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

do_recovery_ubi[depends] += "qti-recovery-image:do_build"

do_recovery_ubi() {
    echo "base image rootfs: ${IMAGE_ROOTFS}"
    echo "recovery image rootfs: ${RECOVERY_IMAGE_ROOTFS}"

    # if exists copy filesmap into RADIO directory
    radiofilesmap=${@get_filesmap(d)}
    [[ ! -z "$radiofilesmap" ]] && install -m 755 $radiofilesmap ${OTA_TARGET_IMAGE_ROOTFS_UBI}/RADIO/

    # copy the boot\recovery images
    cp ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/${BOOTIMAGE_TARGET} ${OTA_TARGET_IMAGE_ROOTFS_UBI}/BOOTABLE_IMAGES/boot.img
    cp ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/${BOOTIMAGE_TARGET} ${OTA_TARGET_IMAGE_ROOTFS_UBI}/BOOTABLE_IMAGES/recovery.img

    # copy the contents of system rootfs
    cp -r ${IMAGE_ROOTFS}/. ${OTA_TARGET_IMAGE_ROOTFS_UBI}/SYSTEM/.
    cd  ${OTA_TARGET_IMAGE_ROOTFS_UBI}/SYSTEM
    rm -rf var/run
    ln -snf ../run var/run

    #copy contents of recovery rootfs
    cp -r ${RECOVERY_IMAGE_ROOTFS}/. ${OTA_TARGET_IMAGE_ROOTFS_UBI}/RECOVERY/.

    #generate recovery.fstab which is used by the updater-script
    #echo #mount point fstype device [device2] >> ${OTA_TARGET_IMAGE_ROOTFS_UBI}/RECOVERY/recovery.fstab
    echo /boot     mtd     boot >> ${OTA_TARGET_IMAGE_ROOTFS_UBI}/RECOVERY/recovery.fstab
    echo /cache    ubifs  cache >> ${OTA_TARGET_IMAGE_ROOTFS_UBI}/RECOVERY/recovery.fstab
    echo /data     ubifs  userdata >> ${OTA_TARGET_IMAGE_ROOTFS_UBI}/RECOVERY/recovery.fstab
    echo /recovery mtd     recovery >> ${OTA_TARGET_IMAGE_ROOTFS_UBI}/RECOVERY/recovery.fstab
    echo ${IMAGE_SYSTEM_MOUNT_POINT}   mtd  rootfs >> ${OTA_TARGET_IMAGE_ROOTFS_UBI}/RECOVERY/recovery.fstab

    #Copy contents of userdata rootfs
    cp -r ${IMAGE_ROOTFS}/data/. ${OTA_TARGET_IMAGE_ROOTFS_UBI}/DATA/.

    #Getting content for OTA folder
    mkdir -p ${OTA_TARGET_IMAGE_ROOTFS_UBI}/OTA/bin
    cp   ${OTA_TARGET_IMAGE_ROOTFS_UBI}/RECOVERY/usr/bin/applypatch ${OTA_TARGET_IMAGE_ROOTFS_UBI}/OTA/bin/.
    cp   ${OTA_TARGET_IMAGE_ROOTFS_UBI}/RECOVERY/usr/bin/updater ${OTA_TARGET_IMAGE_ROOTFS_UBI}/OTA/bin/.

    # if squashfs is supported, we use block-based OTA upgrade.
    if [[ "${SQUASHFS_SUPPORTED}" == "1" ]]; then
        # what we have is a squashfs image.
        # OTA scripts expect a sparse image for block-based package.
        # run img2simg on the squashfs image - this is purely aesthetic
        # and adds no value to the compression of the image.
        img2simg ${DEPLOY_DIR_IMAGE}/${BASEMACHINE}-sysfs.squash ${OTA_TARGET_IMAGE_ROOTFS_UBI}/IMAGES/system.img

        # set block img diff version to v3
        echo "blockimgdiff_versions=3" >> ${OTA_TARGET_IMAGE_ROOTFS_UBI}/META/misc_info.txt

        # change system partitions fs_type to squashfs and the block-device instead of mtd device's name
        echo /system   squashfs  /dev/block/bootdevice/by-name/system >> ${OTA_TARGET_IMAGE_ROOTFS_UBI}/RECOVERY/recovery.fstab
    else
        # File-based OTA upgrade

        echo /system   ubifs  system >> ${OTA_TARGET_IMAGE_ROOTFS_UBI}/RECOVERY/recovery.fstab

        # File-based OTA upgrade is also responsible for assigning the correct
        # uid/gid to each file in the system's rootfs. For this, we use canned_fs_config.
        # The fsconfig file is the complete snapshot of file-attributes
        # collected from the fakeroot/pseudo build environment.
        #TODO
        #cp ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/system.canned.fsconfig ${OTA_TARGET_IMAGE_ROOTFS_UBI}/META/.
    fi

    # Pack releasetools.py into META folder itself.
    # This could also have been done by passing "--device_specific" to
    # ota_from_target_files.py but it would be hacky to find the absolute path there.
    cp ${WORKSPACE}/OTA/device/qcom/common/releasetools.py ${OTA_TARGET_IMAGE_ROOTFS_UBI}/META/.

    # Since /dev is populated at compile-time, pack the device_table used by 'makedevs'
    # into target-files.zip also so that 'makedevs' can be run during OTA upgrade as well.
    # This only applies for file-based OTA and since nand/ubifs targets use file-based OTA
    # by default, this mechanism is limited to nand targets and not emmc.
    cp ${COREBASE}/meta/files/device_table-minimal.txt ${OTA_TARGET_IMAGE_ROOTFS_UBI}/META/device_table.txt

    #cp and modify file_contexts to BOOT/RAMDISK folder
    if [[ "${DISTRO_FEATURES}" =~ "selinux" ]]; then
        cp -a ${IMAGE_ROOTFS}/etc/selinux/mls/contexts/files/. ${OTA_TARGET_IMAGE_ROOTFS_UBI}/BOOT/RAMDISK/.
        sed -i 's#^/#/system/#g' ${OTA_TARGET_IMAGE_ROOTFS_UBI}/BOOT/RAMDISK/file_contexts
        # Keep a copy of file_context.subs_dist & file_contexts.homedirs
        # in the same folder as file_contexts
        # Also append "/system" to each absolute path entry in these files
        [[ -e ${OTA_TARGET_IMAGE_ROOTFS_UBI}/BOOT/RAMDISK/homedir_template ]] && \
            sed -i 's#^/#/system/#g' ${OTA_TARGET_IMAGE_ROOTFS_UBI}/BOOT/RAMDISK/homedir_template
        grep -v -e '^$' ${IMAGE_ROOTFS}/etc/selinux/mls/contexts/files/file_contexts.subs_dist | \
            grep -v '^[#]' | awk '{print "/system"$1,"/system"$2}' > \
            ${OTA_TARGET_IMAGE_ROOTFS_UBI}/BOOT/RAMDISK/file_contexts.subs_dist
        sed -i 's#^/#/system/#g' ${OTA_TARGET_IMAGE_ROOTFS_UBI}/BOOT/RAMDISK/file_contexts.homedirs
        #set selinux_fc
        echo selinux_fc=BOOT/RAMDISK/file_contexts >> ${OTA_TARGET_IMAGE_ROOTFS_UBI}/META/misc_info.txt
        #set use_set_metadata to 1 so that updater-script
        #will have rules to apply selabels
        echo use_set_metadata=1 >> ${OTA_TARGET_IMAGE_ROOTFS_UBI}/META/misc_info.txt
    fi

    # copy contents of META folder
    #recovery_api_version is from recovery module
    echo recovery_api_version=3 >> ${OTA_TARGET_IMAGE_ROOTFS_UBI}/META/misc_info.txt

    #blocksize = BOARD_FLASH_BLOCK_SIZE
    echo blocksize=131072 >> ${OTA_TARGET_IMAGE_ROOTFS_UBI}/META/misc_info.txt

    # boot_size: Size of boot partition from partition.xml
    echo boot_size=0x00C00000 >> ${OTA_TARGET_IMAGE_ROOTFS_UBI}/META/misc_info.txt

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

    cd ${OTA_TARGET_IMAGE_ROOTFS_UBI} && zip -qry ${OTA_TARGET_FILES_UBI_PATH} *
}

addtask do_recovery_ubi after do_image_complete before do_build

do_gen_otazip_ubi[dirs] += "${DEPLOY_DIR_IMAGE}/ota-scripts"
do_gen_otazip_ubi() {
    ./full_ota.sh ${OTA_TARGET_FILES_UBI_PATH} ${IMAGE_ROOTFS} ubi --system_path ${IMAGE_SYSTEM_MOUNT_POINT}

    cp update_ubi.zip ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}
}
addtask do_gen_otazip_ubi after do_recovery_ubi before do_build