DEPENDS += "releasetools-native zip-native fsconfig-native applypatch-native bc-native bsdiff-native qti-recovery-image"

RM_WORK_EXCLUDE_ITEMS += "rootfs rootfs-dbg"

RECOVERY_IMAGE_ROOTFS = "$(echo ${IMAGE_ROOTFS} | sed 's#/${PN}/#/qti-recovery-image/#')"

IMAGE_SYSTEM_MOUNT_POINT = "/system"
OTA_TARGET_IMAGE_ROOTFS_UBI = "${WORKDIR}/ota-target-image-ubi"
OTA_TARGET_FILES_UBI = "target-files-ubi.zip"
OTA_TARGET_FILES_UBI_PATH = "${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/${OTA_TARGET_FILES_UBI}"

OTA_TARGET_FILES_UBI_AB = "target-files-ubi_ab.zip"
OTA_TARGET_FILES_UBI_AB_PATH = "${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/${OTA_TARGET_FILES_UBI_AB}"

MACHINE_FILESMAP_SEARCH_PATH ?= "${@':'.join('%s/conf/machine/filesmap' % p for p in '${BBPATH}'.split(':'))}}"
MACHINE_FILESMAP_FULL_PATH = "${@machine_search(d.getVar('MACHINE_FILESMAP_CONF'), d.getVar('MACHINE_FILESMAP_SEARCH_PATH')) or ''}"

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
    echo "base image rootfs: ${IMAGE_ROOTFS_UBI}"
    echo "recovery image rootfs: ${RECOVERY_IMAGE_ROOTFS}"

    # if exists copy filesmap into RADIO directory
    radiofilesmap=${MACHINE_FILESMAP_FULL_PATH}
    [[ ! -z "$radiofilesmap" ]] && install -m 755 $radiofilesmap ${OTA_TARGET_IMAGE_ROOTFS_UBI}/RADIO/filesmap

    # copy the boot\recovery images
    if ${@bb.utils.contains('DISTRO_FEATURES', 'dm-verity', bb.utils.contains('IMAGE_FEATURES', 'gluebi', 'true', 'false', d), 'false', d)}; then
        cp ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/verity/system-gluebi.ext4/${BOOTIMAGE_TARGET} ${OTA_TARGET_IMAGE_ROOTFS_UBI}/BOOTABLE_IMAGES/boot.img
        cp ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/verity/system-gluebi.ext4/${BOOTIMAGE_TARGET} ${OTA_TARGET_IMAGE_ROOTFS_UBI}/BOOTABLE_IMAGES/recovery.img
    else
        cp ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/${BOOTIMAGE_TARGET} ${OTA_TARGET_IMAGE_ROOTFS_UBI}/BOOTABLE_IMAGES/boot.img
        cp ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/${BOOTIMAGE_TARGET} ${OTA_TARGET_IMAGE_ROOTFS_UBI}/BOOTABLE_IMAGES/recovery.img
    fi

    # if dtbo.img file exist then copy
    if [ -f ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/${DTBOIMAGE_TARGET} ]; then
        cp ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/${DTBOIMAGE_TARGET} ${OTA_TARGET_IMAGE_ROOTFS_UBI}/IMAGES/dtbo.img
    fi

    # copy the contents of system rootfs
    if ${@bb.utils.contains('DISTRO_FEATURES', 'dm-verity', bb.utils.contains('IMAGE_FEATURES', 'gluebi', 'true', 'false', d), 'false', d)}; then
        cp ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/verity/system-gluebi.ext4/system-gluebi.ext4 ${OTA_TARGET_IMAGE_ROOTFS_UBI}/BOOTABLE_IMAGES/system.img
        echo dm_verity_nand=1 >> ${OTA_TARGET_IMAGE_ROOTFS_UBI}/META/misc_info.txt
    fi
    cp -r ${IMAGE_ROOTFS_UBI}/. ${OTA_TARGET_IMAGE_ROOTFS_UBI}/SYSTEM/.
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

    #Copy contents of userdata rootfs
    cp -r ${USERIMAGE_ROOTFS}/. ${OTA_TARGET_IMAGE_ROOTFS_UBI}/DATA/.

    #Getting content for OTA folder
    mkdir -p ${OTA_TARGET_IMAGE_ROOTFS_UBI}/OTA/bin
    cp   ${OTA_TARGET_IMAGE_ROOTFS_UBI}/RECOVERY/usr/bin/applypatch ${OTA_TARGET_IMAGE_ROOTFS_UBI}/OTA/bin/.
    cp   ${OTA_TARGET_IMAGE_ROOTFS_UBI}/RECOVERY/usr/bin/updater ${OTA_TARGET_IMAGE_ROOTFS_UBI}/OTA/bin/.

    if ${@bb.utils.contains('COMBINED_FEATURES', 'qti-nad-core', 'true', 'false', d)}; then
        cp -r ${IMAGE_ROOTFS_SQUASHFS_UBI}/. ${OTA_TARGET_IMAGE_ROOTFS_UBI}/RECOVERY/.
        cp   ${OTA_TARGET_IMAGE_ROOTFS_UBI}/RECOVERY/usr/bin/applypatch ${OTA_TARGET_IMAGE_ROOTFS_UBI}/OTA/bin/.
        cp   ${OTA_TARGET_IMAGE_ROOTFS_UBI}/RECOVERY/usr/bin/updater ${OTA_TARGET_IMAGE_ROOTFS_UBI}/OTA/bin/.
        if ${@bb.utils.contains('MACHINE_FEATURES', 'tele-squashfs-ubi', 'true', 'false', d)}; then
            SQUASHFS_SUPPORTED="1"
        fi
    fi

    # if squashfs is supported, we use block-based OTA upgrade.
    if [[ "${SQUASHFS_SUPPORTED}" == "1" ]]; then
        # what we have is a squashfs image.
        # OTA scripts expect a sparse image for block-based package.
        # run img2simg on the squashfs image - this is purely aesthetic
        # and adds no value to the compression of the image.
        # use squashfs2sparse for generating image for squashfs

        if ${@bb.utils.contains('COMBINED_FEATURES', 'qti-nad-core', 'true', 'false', d)}; then
            squashfs2sparse ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/squashfs/sysfs.squash ${OTA_TARGET_IMAGE_ROOTFS_UBI}/IMAGES/system.img
        else
            img2simg ${DEPLOY_DIR_IMAGE}/${BASEMACHINE}-sysfs.squash ${OTA_TARGET_IMAGE_ROOTFS_UBI}/IMAGES/system.img
        fi

        # set block img diff version to v3
        echo "blockimgdiff_versions=3" >> ${OTA_TARGET_IMAGE_ROOTFS_UBI}/META/misc_info.txt

        # change system partitions fs_type to squashfs and the block-device instead of mtd device's name
        echo /system   squashfs  /dev/block/bootdevice/by-name/system >> ${OTA_TARGET_IMAGE_ROOTFS_UBI}/RECOVERY/recovery.fstab

        if ${@bb.utils.contains('COMBINED_FEATURES', 'qti-nad-core', 'true', 'false', d)}; then
            if ${@bb.utils.contains('IMAGE_FEATURES', 'nad-modem-volume', 'true', 'false', d)}; then
                echo /modem squashfs /dev/block/bootdevice/by-name/modem >> ${OTA_TARGET_IMAGE_ROOTFS_UBI}/RECOVERY/recovery.fstab
                if [ -f ${DEPLOY_DIR_IMAGE}/NON-HLOS.squash ]; then
                    squashfs2sparse  ${DEPLOY_DIR_IMAGE}/NON-HLOS.squash ${OTA_TARGET_IMAGE_ROOTFS_UBI}/IMAGES/modem.img
                fi
            fi

            if ${@bb.utils.contains('IMAGE_FEATURES', 'telaf-volume', 'true', 'false', d)}; then
                echo /telaf squashfs /dev/block/bootdevice/by-name/telaf >> ${OTA_TARGET_IMAGE_ROOTFS_UBI}/RECOVERY/recovery.fstab
                if [ -f ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/squashfs/telaf_ro.squashfs ]; then
                    squashfs2sparse  ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/squashfs/telaf_ro.squashfs ${OTA_TARGET_IMAGE_ROOTFS_UBI}/IMAGES/telaf.img
                fi
            fi

            if ${@bb.utils.contains('IMAGE_FEATURES', 'vm-bootsys_volume', 'true', 'false', d)}; then
                echo /vm-bootsys squashfs /dev/block/bootdevice/by-name/vm-bootsys >> ${OTA_TARGET_IMAGE_ROOTFS_UBI}/RECOVERY/recovery.fstab
                if [ -f ${DEPLOY_DIR_IMAGE}/vm-bootsys.squash ]; then
                    squashfs2sparse  ${DEPLOY_DIR_IMAGE}/vm-bootsys.squash ${OTA_TARGET_IMAGE_ROOTFS_UBI}/IMAGES/vm-bootsys.img
                fi
            fi
        fi
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
        cp -a ${IMAGE_ROOTFS_UBI}/etc/selinux/mls/contexts/files/. ${OTA_TARGET_IMAGE_ROOTFS_UBI}/BOOT/RAMDISK/.
        sed -i 's#^/#/system/#g' ${OTA_TARGET_IMAGE_ROOTFS_UBI}/BOOT/RAMDISK/file_contexts
        # Keep a copy of file_context.subs_dist & file_contexts.homedirs
        # in the same folder as file_contexts
        # Also append "/system" to each absolute path entry in these files
        [[ -e ${OTA_TARGET_IMAGE_ROOTFS_UBI}/BOOT/RAMDISK/homedir_template ]] && \
            sed -i 's#^/#/system/#g' ${OTA_TARGET_IMAGE_ROOTFS_UBI}/BOOT/RAMDISK/homedir_template
        grep -v -e '^$' ${IMAGE_ROOTFS_UBI}/etc/selinux/mls/contexts/files/file_contexts.subs_dist | \
            grep -v '^[#]' | awk '{print "/system"$1,"/system"$2}' > \
            ${OTA_TARGET_IMAGE_ROOTFS_UBI}/BOOT/RAMDISK/file_contexts.subs_dist
        sed -i 's#^/#/system/#g' ${OTA_TARGET_IMAGE_ROOTFS_UBI}/BOOT/RAMDISK/file_contexts.homedirs
        #set selinux_fc
        echo selinux_fc=BOOT/RAMDISK/file_contexts >> ${OTA_TARGET_IMAGE_ROOTFS_UBI}/META/misc_info.txt
        #set use_set_metadata to 1 so that updater-script
        #will have rules to apply selabels
        echo use_set_metadata=1 >> ${OTA_TARGET_IMAGE_ROOTFS_UBI}/META/misc_info.txt
    fi

    if ${@bb.utils.contains('COMBINED_FEATURES', 'qti-nad-core', 'true', 'false', d)}; then
      echo le_target_supports_nad=1 >> ${OTA_TARGET_IMAGE_ROOTFS_UBI}/META/misc_info.txt
    fi

    # copy contents of META folder
    #recovery_api_version is from recovery module
    echo recovery_api_version=3 >> ${OTA_TARGET_IMAGE_ROOTFS_UBI}/META/misc_info.txt

    #blocksize = BOARD_FLASH_BLOCK_SIZE
    echo blocksize=131072 >> ${OTA_TARGET_IMAGE_ROOTFS_UBI}/META/misc_info.txt

    # boot_size: Size of boot partition from partition.xml
    echo boot_size=0x2400000 >> ${OTA_TARGET_IMAGE_ROOTFS_UBI}/META/misc_info.txt

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

    if ${@bb.utils.contains('COMBINED_FEATURES', 'qti-nad-core', 'true', 'false', d)}; then
        cd ${OTA_TARGET_IMAGE_ROOTFS_UBI} && zip -qry ${OTA_TARGET_FILES_UBI_AB_PATH} *
    fi
}

addtask do_recovery_ubi after do_image_complete before do_build

do_gen_otazip_ubi[dirs] += "${DEPLOY_DIR_IMAGE}/ota-scripts"
do_gen_otazip_ubi() {
    ./full_ota.sh ${OTA_TARGET_FILES_UBI_PATH} ${IMAGE_ROOTFS_UBI} ubi --system_path ${IMAGE_SYSTEM_MOUNT_POINT}

    if [[ -e update_ubi.zip ]]; then
        cp update_ubi.zip ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}
    else
        bbwarn "update_ubi.zip failed to create"
    fi

    if ${@bb.utils.contains('COMBINED_FEATURES', 'qti-nad-core', 'true', 'false', d)}; then
        ./full_ota.sh ${OTA_TARGET_FILES_UBI_AB_PATH} ${IMAGE_ROOTFS_UBI} ubi_ab --block --system_path ${IMAGE_SYSTEM_MOUNT_POINT}
    fi

    if ${@bb.utils.contains('COMBINED_FEATURES', 'qti-nad-core', 'true', 'false', d)}; then
      if [[ -e update_ubi_ab.zip ]]; then
           cp update_ubi_ab.zip ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}
       else
           bbwarn "update_ubi_ab.zip failed to create"
       fi
    fi
}
addtask do_gen_otazip_ubi after do_recovery_ubi before do_build
