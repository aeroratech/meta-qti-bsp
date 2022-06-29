# if A/B support is supported, generate OTA pkg by default.
GENERATE_AB_OTA_PACKAGE ?= "${@bb.utils.contains('COMBINED_FEATURES', 'qti-ab-boot', '1', '', d)}"

QIMGSQSHCLASSES  = ""
QIMGSQSHCLASSES += "${@bb.utils.contains('GENERATE_AB_OTA_PACKAGE', '1', 'ab-ota-squashfs', '', d)}"

inherit ${QIMGSQSHCLASSES}

CORE_IMAGE_EXTRA_INSTALL += "${@bb.utils.contains('COMBINED_FEATURES', 'qti-ab-boot', ' recovery-ab', '', d)}"

CORE_IMAGE_EXTRA_INSTALL += "systemd-machine-units-ext4"

do_image_squashfs[noexec] = "1"

FS_TYPE_SQSH = "squashfs"

# Default Image names
SYSTEMIMAGE_TARGET ?= "system.img"
SYSTEMIMAGE_MAP_TARGET ?= "system.map"
USERDATAIMAGE_TARGET ?= "userdata.img"
USERDATAIMAGE_MAP_TARGET ?= "userdata.map"
PERSISTIMAGE_TARGET ?= "persist.img"
PERSISTIMAGE_MAP_TARGET ?= "persist.map"
DTBOIMAGE_TARGET ?= "dtbo.img"

# Ensure SELinux file context variable is defined
#SELINUX_FILE_CONTEXTS ?= ""
#SELINUX_IMG_S = "${@['-S ${SELINUX_FILE_CONTEXTS}', ''][d.getVar('SELINUX_FILE_CONTEXTS') == '']}"
#IMAGE_EXT4_SELINUX_OPTIONS = "${@bb.utils.contains('DISTRO_FEATURES', 'selinux', '${SELINUX_IMG_S}', '', d)}"

ROOTFS_POSTPROCESS_COMMAND += "gen_buildprop;do_fsconfig;"
ROOTFS_POSTPROCESS_COMMAND += "gen_fsconfig;"
ROOTFS_POSTPROCESS_COMMAND += "${@bb.utils.contains('MACHINE_MNT_POINTS', 'overlay', 'gen_overlayfs;', '', d)}"
USERDATA_DIR = "${@bb.utils.contains('MACHINE_MNT_POINTS', 'overlay', 'overlay', 'data', d)}"

gen_fsconfig() {
   # Setup fsconfig for persist image
   touch ${WORKDIR}/persist_fsconfig.conf
   echo "data 1000 1000 700" > ${WORKDIR}/persist_fsconfig.conf
}

gen_buildprop() {
   mkdir -p ${IMAGE_ROOTFS}/cache
   echo ro.build.version.release=`cat ${IMAGE_ROOTFS}/etc/version ` >> ${IMAGE_ROOTFS}/build.prop
   echo ro.product.name=${BASEMACHINE}-${DISTRO} >> ${IMAGE_ROOTFS}/build.prop
   echo ${MACHINE} >> ${IMAGE_ROOTFS}/target
}

gen_overlayfs() {
    mkdir -p ${IMAGE_ROOTFS}/overlay
    mkdir -p ${IMAGE_ROOTFS}/overlay/etc
    mkdir -p ${IMAGE_ROOTFS}/overlay/.etc-work
    mkdir -p ${IMAGE_ROOTFS}/overlay/data
    mkdir -p ${IMAGE_ROOTFS}/overlay/.data-work
    mkdir -p ${IMAGE_ROOTFS}/overlay/cache
    mkdir -p ${IMAGE_ROOTFS}/overlay/.cache-work
}

do_fsconfig() {
    chmod go-r ${IMAGE_ROOTFS}/etc/passwd || :
    chmod -R o-rwx ${IMAGE_ROOTFS}/etc/init.d/ || :

    # For ext4, fs_config setting is covered by make_ext4fs tool with specific arg
    # In case of squashfs, mksquashfs doesn't support fs_config arg
    # applying the fs_config for rootfs

    cp ${MACHINE_FSCONFIG_CONF_FULL_PATH} ${WORKDIR}/rootfs-fsconfig.conf
    export FILE_PERMISSIONS=$(<${WORKDIR}/rootfs-fsconfig.conf)
    if [ "$FILE_PERMISSIONS" != "" ] ; then
       IFS=$'\n'
       for each_file in $FILE_PERMISSIONS; do
          echo $each_file
          path="$(cut -d " " -f 1 <<< $each_file)"
          user="$(cut -d " " -f 2 <<< $each_file)"
          group="$(cut -d " " -f 3 <<< $each_file)"
	  if [ -f "${IMAGE_ROOTFS}/$path" ] ; then
             chown -R $user:$group ${IMAGE_ROOTFS}/$path
          fi
        done
     fi
}

do_fsconfig_append_qti-distro-user() {
 rm ${IMAGE_ROOTFS}/lib/systemd/system/sys-kernel-debug.mount
}

################################################
### Generate system.img #####
################################################
SPARSE_SYSTEMIMAGE_FLAG = "${@bb.utils.contains('IMAGE_FEATURES', 'vm', '', '-s', d)}"
IMAGE_ROOTFS_SQSH = "${WORKDIR}/rootfs-sqsh"

MACHINE_FSCONFIG_CONF_SEARCH_PATH ?= "${@':'.join('%s/conf/machine/fsconfig' % p for p in '${BBPATH}'.split(':'))}}"
MACHINE_FSCONFIG_CONF_FULL_PATH = "${@machine_search(d.getVar('MACHINE_FSCONFIG_CONF'), d.getVar('MACHINE_FSCONFIG_CONF_SEARCH_PATH')) or ''}"

create_symlink_systemd_sqsh_mount_rootfs() {

    # Symlink mount files to systemd targets
    for entry in ${MACHINE_MNT_POINTS}; do
        mountname="${entry:1}"
        if [[ "$mountname" == "firmware" || "$mountname" == "bt_firmware" || "$mountname" == "dsp" ]] && \
           [[ "${COMBINED_FEATURES}" =~ .*qti-ab-boot.* ]] ; then
            cp ${IMAGE_ROOTFS_SQSH}/lib/systemd/system/${mountname}-mount-ext4.service ${IMAGE_ROOTFS_SQSH}/lib/systemd/system/${mountname}-mount.service
            ln -sf ${systemd_unitdir}/system/${mountname}-mount.service ${IMAGE_ROOTFS_SQSH}/lib/systemd/system/local-fs.target.requires/${mountname}-mount.service
        else
            cp ${IMAGE_ROOTFS_SQSH}/lib/systemd/system/${mountname}-ext4.mount  ${IMAGE_ROOTFS_SQSH}/lib/systemd/system/${mountname}.mount
            if [[ "$mountname" == "$userfsdatadir" ]] ; then
                ln -sf ${systemd_unitdir}/system/${mountname}.mount ${IMAGE_ROOTFS_SQSH}/lib/systemd/system/local-fs.target.wants/${mountname}.mount
            elif [[ "$mountname" == "cache" ]] ; then
                ln -sf ${systemd_unitdir}/system/${mountname}.mount ${IMAGE_ROOTFS_SQSH}/lib/systemd/system/multi-user.target.wants/${mountname}.mount
            elif [[ "$mountname" == "persist" ]] ; then
                ln -sf ${systemd_unitdir}/system/${mountname}.mount ${IMAGE_ROOTFS_SQSH}/lib/systemd/system/local-fs.target.requires/${mountname}.mount
            else
                ln -sf ${systemd_unitdir}/system/${mountname}.mount ${IMAGE_ROOTFS_SQSH}/lib/systemd/system/local-fs.target.requires/${mountname}.mount
            fi
        fi
    done
}

create_rootfs_sqsh[cleandirs] = "${IMAGE_ROOTFS_SQSH}"
python create_rootfs_sqsh () {
    src_dir = d.getVar("IMAGE_ROOTFS")
    dest_dir = d.getVar("IMAGE_ROOTFS_SQSH")
    if os.path.isdir(src_dir):
        oe.path.copyhardlinktree(src_dir, dest_dir)
    else:
        bb.error("rootfs is not generated")
}

do_makesystem_sqsh[prefuncs] += "create_rootfs_sqsh"
do_makesystem_sqsh[prefuncs] += "create_symlink_systemd_sqsh_mount_rootfs"
# The system image size update that happens in do_make_verity_enabled_system_image
#  step is not persistent outside that task scope. Update it again within this
#  task's scope.
#do_makesystem_sqsh[prefuncs] += "${@bb.utils.contains('DISTRO_FEATURES', 'dm-verity', bb.utils.contains('MACHINE_FEATURES', 'dm-verity-bootloader', 'adjust_system_size_for_verity', '', d), '', d)}"

#Using the fakeroot for leveraging user namespace UID/GID mapping properly to rootfs
fakeroot do_makesystem_sqsh() {
    # Empty the /persist folder so that it doesn't end up
    # in system image as well
    rm -rf ${IMAGE_ROOTFS_SQSH}/persist/*
    mkdir -p ${IMGDEPLOYDIR}/${IMAGE_BASENAME}/${FS_TYPE_SQSH}
    mksquashfs ${IMAGE_ROOTFS_SQSH} ${IMGDEPLOYDIR}/${IMAGE_BASENAME}/${FS_TYPE_SQSH}/${SYSTEMIMAGE_TARGET} \
                -noappend -comp xz -Xdict-size 32K -noI -Xbcj arm -b 65536 -processors 1
}
addtask do_makesystem_sqsh after do_image before do_image_complete

### Generate userdata.img ###
do_makeuserdata_sqsh[dirs] = "${IMGDEPLOYDIR}/${IMAGE_BASENAME}/${FS_TYPE_SQSH}"

do_makeuserdata_sqsh() {
    cp ${MACHINE_FSCONFIG_CONF_FULL_PATH} ${WORKDIR}/rootfs-fsconfig.conf
    make_ext4fs -B ${IMGDEPLOYDIR}/${IMAGE_BASENAME}/${FS_TYPE_SQSH}/${USERDATAIMAGE_MAP_TARGET} \
                -a /data ${IMAGE_EXT4_SELINUX_OPTIONS} \
                -s -b 4096 -l ${USERDATA_SIZE_EXT4} \
                ${IMGDEPLOYDIR}/${IMAGE_BASENAME}/${FS_TYPE_SQSH}/${USERDATAIMAGE_TARGET} \
                ${IMAGE_ROOTFS}/${USERDATA_DIR}
}

addtask do_makeuserdata_sqsh after do_image before do_build

################################################
############ Generate persist image ############
################################################
PERSIST_IMAGE_ROOTFS_SIZE ?= "6536668"
do_makepersist_sqsh[dirs] = "${IMGDEPLOYDIR}/${IMAGE_BASENAME}/${FS_TYPE_SQSH}"

do_makepersist_sqsh() {
    make_ext4fs ${PERSISTFS_CONFIG} ${MAKEEXT4_MOUNT_OPT} \
                -B ${IMGDEPLOYDIR}/${IMAGE_BASENAME}/${FS_TYPE_SQSH}/${PERSISTIMAGE_MAP_TARGET} \
                -s -l ${PERSIST_IMAGE_ROOTFS_SIZE} \
                ${IMGDEPLOYDIR}/${IMAGE_BASENAME}/${FS_TYPE_SQSH}/${PERSISTIMAGE_TARGET} \
                ${IMAGE_ROOTFS}/persist
}

# It must be before do_makesystem_sqsh to remove /persist
addtask do_makepersist_sqsh after do_image before do_makesystem_sqsh

################################################
############### Copy boot image ################
################################################

do_copy_image() {
    mkdir -p ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/${FS_TYPE_SQSH}
    cp ${DEPLOY_DIR_IMAGE}/abl.elf ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/${FS_TYPE_SQSH}/abl.elf
    cp ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/${DTBOIMAGE_TARGET} ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/${FS_TYPE_SQSH}/${DTBOIMAGE_TARGET}
}

addtask do_copy_image after do_image before do_build
