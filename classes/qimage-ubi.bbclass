# if A/B support is supported, generate OTA pkg by default.
GENERATE_AB_OTA_PACKAGE ?= "${@bb.utils.contains('COMBINED_FEATURES', 'qti-ab-boot', '1', '', d)}"

QIMGUBICLASSES  = ""
# To be implemented
QIMGUBICLASSES += "${@bb.utils.contains('MACHINE_FEATURES', 'qti-recovery', 'ota-ubi', '', d)}"

inherit ${QIMGUBICLASSES}

IMAGE_FEATURES[validitems] += "persist-volume nand2x"

CORE_IMAGE_EXTRA_INSTALL += "systemd-machine-units-ubi"

SYSTEMIMAGE_UBI_TARGET ?= "sysfs.ubi"
SYSTEMIMAGE_UBIFS_TARGET ?= "sysfs.ubifs"
USERIMAGE_UBIFS_TARGET ?= "userfs.ubifs"
USERIMAGE_ROOTFS ?= "${WORKDIR}/usrfs"

UBINIZE_CFG ?= "ubinize_system.cfg"

IMAGE_UBIFS_SELINUX_OPTIONS = "${@bb.utils.contains('DISTRO_FEATURES', 'selinux', '--selinux=${SELINUX_FILE_CONTEXTS}', '', d)}"
IMAGE_UBIFS_SELINUX_OPTIONS_DATA = "${@bb.utils.contains('DISTRO_FEATURES', 'selinux', '--selinux=${SELINUX_FILE_CONTEXTS_DATA}', '', d)}"

do_image_ubi[noexec] = "1"
do_image_ubifs[noexec] = "1"
do_image_multiubi[noexec] = "1"

################################################
### Generate sysfs.ubi #########################
################################################

ROOTFS_VOLUME_SIZE = "${@bb.utils.contains('IMAGE_FEATURES', 'nand2x', '${SYSTEM_VOLUME_SIZE_G}', '${SYSTEM_VOLUME_SIZE}', d)}"

create_symlink_userfs() {
    #Symlink modules
    LIB_MODULES="${IMAGE_ROOTFS}/lib/modules"
    if [ -d ${LIB_MODULES} ]; then
        cp -rp ${LIB_MODULES} ${IMAGE_ROOTFS}/usr/lib/
        rm -rf ${LIB_MODULES}
    fi
    ln -sf /usr/lib/modules ${IMAGE_ROOTFS}/lib

    # Move rootfs data to userfs directory
    # Content of userfs is added to data volume
    DATA_DIR="${IMAGE_ROOTFS}/data"
    CONFIG_DIR="${DATA_DIR}/configs"
    LOGS_DIR="${DATA_DIR}/logs"
    if [ ! -d ${DATA_DIR} ]; then
        mkdir ${DATA_DIR}
    fi
    if [ ! -d ${CONFIG_DIR} ]; then
        mkdir ${CONFIG_DIR}
    fi
    if [ ! -d ${LOGS_DIR} ]; then
        mkdir ${LOGS_DIR}
    fi
    rm -rf ${USERIMAGE_ROOTFS}
    mkdir -p ${USERIMAGE_ROOTFS}
    mv ${DATA_DIR}/* ${USERIMAGE_ROOTFS}
}

create_symlink_systemd_ubi_mount_rootfs() {
    # Symlink ubi mount files to systemd targets
    for entry in ${MACHINE_MNT_POINTS}; do
        mountname="${entry:1}"
        if [[ "$mountname" == "firmware" || "$mountname" == "bt_firmware" || "$mountname" == "dsp" ]] ; then
            cp -f ${IMAGE_ROOTFS}/lib/systemd/system/${mountname}-mount-ubi.service ${IMAGE_ROOTFS}/lib/systemd/system/${mountname}-mount.service
            ln -sf ${systemd_unitdir}/system/${mountname}-mount.service ${IMAGE_ROOTFS}/lib/systemd/system/local-fs.target.requires/${mountname}-mount.service
        else
            cp ${IMAGE_ROOTFS}/lib/systemd/system/${mountname}-ubi.mount ${IMAGE_ROOTFS}/lib/systemd/system/${mountname}.mount
            if [ "$mountname" = "systemrw" ]; then
                mkdir -p ${IMAGE_ROOTFS}/lib/systemd/system/systemrw.mount.d
                cp ${IMAGE_ROOTFS}/lib/systemd/system/systemrw-ubi.conf ${IMAGE_ROOTFS}/lib/systemd/system/systemrw.mount.d/systemrw.conf
            fi
            if [[ "$mountname" == "$userfsdatadir" ]] ; then
                ln -sf ${systemd_unitdir}/system/${mountname}.mount ${IMAGE_ROOTFS}/lib/systemd/system/local-fs.target.wants/${mountname}.mount
            elif [[ "$mountname" == "cache" ]] ; then
                ln -sf ${systemd_unitdir}/system/${mountname}.mount ${IMAGE_ROOTFS}/lib/systemd/system/multi-user.target.wants/${mountname}.mount
            elif [[ "$mountname" == "persist" ]] ; then
                ln -sf ${systemd_unitdir}/system/${mountname}.mount ${IMAGE_ROOTFS}/lib/systemd/system/sysinit.target.wants/${mountname}.mount
            else
                ln -sf ${systemd_unitdir}/system/${mountname}.mount ${IMAGE_ROOTFS}/lib/systemd/system/local-fs.target.requires/${mountname}.mount
            fi
        fi
    done

    #remove additional ext4 symlinks if present
    rm -rf ${IMAGE_ROOTFS}/lib/systemd/system/local-fs-pre.target.requires/systemd-fsck*
    rm -rf ${IMAGE_ROOTFS}/lib/systemd/system/local-fs.target.requires/firmware.mount
    rm -rf ${IMAGE_ROOTFS}/lib/systemd/system/local-fs.target.requires/dsp.mount
    rm -rf ${IMAGE_ROOTFS}/lib/systemd/system/local-fs.target.requires/bt_firmware.mount
    rm -rf ${IMAGE_ROOTFS}/lib/systemd/system/sysinit.target.wants/ab-updater.service
    rm -rf ${IMAGE_ROOTFS}/lib/systemd/system/sysinit.target.wants/rmt_storage.service
    rm -rf ${IMAGE_ROOTFS}/etc/udev/rules.d/rmtstorage.rules
    rm -rf ${IMAGE_ROOTFS}/etc/systemd/system/local-fs-pre.target.wants/set-slotsuffix.service
    # Recheck when overlay support added for ubi
    rm -rf ${IMAGE_ROOTFS}/lib/systemd/system/local-fs.target.wants/overlay-restore.service

   # Remove rules to automount block devices.
   sed -i '/SUBSYSTEM=="block", TAG+="systemd"/d' ${IMAGE_ROOTFS}/lib/udev/rules.d/99-systemd.rules
   sed -i '/SUBSYSTEM=="block", ACTION=="add", ENV{DM_UDEV_DISABLE_OTHER_RULES_FLAG}=="1", ENV{SYSTEMD_READY}="0"/d' ${IMAGE_ROOTFS}/lib/udev/rules.d/99-systemd.rules

   # Remove generator binaries and ensure that we don't rely on generators for mount or service files.
   rm -rf ${IMAGE_ROOTFS}/lib/systemd/system-generators/systemd-debug-generator
   rm -rf ${IMAGE_ROOTFS}/lib/systemd/system-generators/systemd-fstab-generator
   rm -rf ${IMAGE_ROOTFS}/lib/systemd/system-generators/systemd-getty-generator
   rm -rf ${IMAGE_ROOTFS}/lib/systemd/system-generators/systemd-gpt-auto-generator
   rm -rf ${IMAGE_ROOTFS}/lib/systemd/system-generators/systemd-hibernate-resume-generator
   rm -rf ${IMAGE_ROOTFS}/lib/systemd/system-generators/systemd-rc-local-generator
   rm -rf ${IMAGE_ROOTFS}/lib/systemd/system-generators/systemd-system-update-generator
   rm -rf ${IMAGE_ROOTFS}/lib/systemd/system-generators/systemd-sysv-generator

   # Start systemd-udev-trigger.service after sysinit.target
   sed -i '/Before=sysinit.target/a After=sysinit.target init_sys_mss.service' ${IMAGE_ROOTFS}/lib/systemd/system/systemd-udev-trigger.service
   sed -i '/Before=sysinit.target/d' ${IMAGE_ROOTFS}/lib/systemd/system/systemd-udev-trigger.service

   # Copy sdcard mount rules
   cp ${IMAGE_ROOTFS}/etc/udev/rules.d/mountpartitions ${IMAGE_ROOTFS}/etc/udev/rules.d/mountpartitions.rules
}

# Need to copy ubinize.cfg file in the deploy directory
do_create_ubinize_config[dirs] = "${IMGDEPLOYDIR}/${IMAGE_BASENAME}"

do_create_ubinize_config() {
    cat << EOF > ${UBINIZE_CFG}
[sysfs_volume]
mode=ubi
image="${SYSTEMIMAGE_UBIFS_TARGET}"
vol_id=0
vol_type=dynamic
vol_name=rootfs
vol_size="${ROOTFS_VOLUME_SIZE}"
[usrfs_volume]
mode=ubi
image="${USERIMAGE_UBIFS_TARGET}"
vol_id=1
vol_type=dynamic
vol_name=usrfs
vol_flags=autoresize
[cache_volume]
mode=ubi
vol_id=2
vol_type=dynamic
vol_name=cachefs
vol_size="${CACHE_VOLUME_SIZE}"
[systemrw_volume]
mode=ubi
vol_id=3
vol_type=dynamic
vol_name=systemrw
vol_size="${SYSTEMRW_VOLUME_SIZE}"
EOF
    if $(echo ${IMAGE_FEATURES} | grep -q "persist-volume"); then
        cat << EOF >> ${UBINIZE_CFG}
[persist_volume]
mode=ubi
vol_id=4
vol_type=dynamic
vol_name=persist
vol_size="${PERSIST_VOLUME_SIZE}"
EOF
    fi

}

do_makesystem_ubi[prefuncs] += "create_symlink_userfs"
do_makesystem_ubi[prefuncs] += "create_symlink_systemd_ubi_mount_rootfs"
do_makesystem_ubi[prefuncs] += "do_create_ubinize_config"
do_makesystem_ubi[postfuncs] += "${@bb.utils.contains('INHERIT', 'uninative', 'do_patch_ubitools', '', d)}"
do_makesystem_ubi[dirs] = "${IMGDEPLOYDIR}/${IMAGE_BASENAME}"

fakeroot do_makesystem_ubi() {
    mkfs.ubifs -r ${IMAGE_ROOTFS} ${IMAGE_UBIFS_SELINUX_OPTIONS} -o ${SYSTEMIMAGE_UBIFS_TARGET} ${MKUBIFS_ARGS}
    mkfs.ubifs -r ${USERIMAGE_ROOTFS} ${IMAGE_UBIFS_SELINUX_OPTIONS_DATA} -o ${USERIMAGE_UBIFS_TARGET} ${MKUBIFS_ARGS}
    ubinize -o ${SYSTEMIMAGE_UBI_TARGET} ${UBINIZE_ARGS} ${UBINIZE_CFG}
}

python () {
    if bb.utils.contains('IMAGE_FSTYPES', 'ext4', True, False, d):
        bb.build.addtask('do_makesystem_ubi', 'do_image_complete', 'do_makesystem', d)
    else:
        bb.build.addtask('do_makesystem_ubi', 'do_image_complete', 'do_rootfs', d)
}

do_patch_ubitools() {
    ${UNINATIVE_STAGING_DIR}-uninative/x86_64-linux/usr/bin/patchelf-uninative --set-interpreter /lib64/ld-linux-x86-64.so.2 ${STAGING_DIR}-components/x86_64/mtd-utils-native/usr/sbin/mkfs.ubifs
    ${UNINATIVE_STAGING_DIR}-uninative/x86_64-linux/usr/bin/patchelf-uninative --set-interpreter /lib64/ld-linux-x86-64.so.2 ${STAGING_DIR}-components/x86_64/mtd-utils-native/usr/sbin/ubinize
}
