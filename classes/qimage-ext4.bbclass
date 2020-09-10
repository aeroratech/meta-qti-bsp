# if A/B support is supported, generate OTA pkg by default.
GENERATE_AB_OTA_PACKAGE ?= "${@bb.utils.contains('COMBINED_FEATURES', 'qti-ab-boot', '1', '', d)}"

QIMGEXT4CLASSES  = ""
QIMGEXT4CLASSES += "${@bb.utils.contains('GENERATE_AB_OTA_PACKAGE', '1', 'ab-ota-ext4', '', d)}"

inherit ${QIMGEXT4CLASSES}

CORE_IMAGE_EXTRA_INSTALL += "${@bb.utils.contains('COMBINED_FEATURES', 'qti-ab-boot', ' recovery-ab', '', d)}"

CORE_IMAGE_EXTRA_INSTALL += "systemd-machine-units-ext4"

do_image_ext4[noexec] = "1"

# Default Image names
SYSTEMIMAGE_TARGET ?= "system.img"
SYSTEMIMAGE_MAP_TARGET ?= "system.map"
USERDATAIMAGE_TARGET ?= "userdata.img"
USERDATAIMAGE_MAP_TARGET ?= "userdata.map"
PERSISTIMAGE_TARGET ?= "persist.img"
PERSISTIMAGE_MAP_TARGET ?= "persist.map"
DTBOIMAGE_TARGET ?= "dtbo.img"
CACHEIMAGE_TARGET ?= "cache.img"
SYSTEMRWIMAGE_TARGET ?= "systemrw.img"

IMAGE_EXT4_SELINUX_OPTIONS = "${@bb.utils.contains('DISTRO_FEATURES', 'selinux', '-S ${SELINUX_FILE_CONTEXTS}', '', d)}"

ROOTFS_POSTPROCESS_COMMAND += "gen_buildprop;do_fsconfig;"
ROOTFS_POSTPROCESS_COMMAND += "${@bb.utils.contains('MACHINE_MNT_POINTS', 'overlay', 'gen_overlayfs;', '', d)}"
USERDATA_DIR = "${@bb.utils.contains('MACHINE_MNT_POINTS', 'overlay', 'overlay', 'data', d)}"

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
}

do_fsconfig_append_qti-distro-user() {
 rm ${IMAGE_ROOTFS}/lib/systemd/system/sys-kernel-debug.mount
}

################################################
### Generate system.img #####
################################################
SPARSE_SYSTEMIMAGE_FLAG = "${@bb.utils.contains('IMAGE_FEATURES', 'vm', '', '-s', d)}"
IMAGE_ROOTFS_EXT4 = "${WORKDIR}/rootfs-ext4"

MACHINE_FSCONFIG_CONF_SEARCH_PATH ?= "${@':'.join('%s/conf/machine/fsconfig' % p for p in '${BBPATH}'.split(':'))}}"
MACHINE_FSCONFIG_CONF_FULL_PATH = "${@machine_search(d.getVar('MACHINE_FSCONFIG_CONF'), d.getVar('MACHINE_FSCONFIG_CONF_SEARCH_PATH')) or ''}"

create_symlink_systemd_ext4_mount_rootfs() {

    # Symlink ext4 mount files to systemd targets
    for entry in ${MACHINE_MNT_POINTS}; do
        mountname="${entry:1}"
        if [[ "$mountname" == "firmware" || "$mountname" == "bt_firmware" || "$mountname" == "dsp" ]] && \
           [[ "${COMBINED_FEATURES}" =~ .*qti-ab-boot.* ]] ; then
            cp ${IMAGE_ROOTFS_EXT4}/lib/systemd/system/${mountname}-mount-ext4.service ${IMAGE_ROOTFS_EXT4}/lib/systemd/system/${mountname}-mount.service
            ln -sf ${systemd_unitdir}/system/${mountname}-mount.service ${IMAGE_ROOTFS_EXT4}/lib/systemd/system/local-fs.target.requires/${mountname}-mount.service
        else
            cp ${IMAGE_ROOTFS_EXT4}/lib/systemd/system/${mountname}-ext4.mount  ${IMAGE_ROOTFS_EXT4}/lib/systemd/system/${mountname}.mount
            if [[ "$mountname" == "$userfsdatadir" ]] ; then
                ln -sf ${systemd_unitdir}/system/${mountname}.mount ${IMAGE_ROOTFS_EXT4}/lib/systemd/system/local-fs.target.wants/${mountname}.mount
            elif [[ "$mountname" == "cache" ]] ; then
                ln -sf ${systemd_unitdir}/system/${mountname}.mount ${IMAGE_ROOTFS_EXT4}/lib/systemd/system/multi-user.target.wants/${mountname}.mount
            elif [[ "$mountname" == "persist" ]] ; then
                ln -sf ${systemd_unitdir}/system/${mountname}.mount ${IMAGE_ROOTFS_EXT4}/lib/systemd/system/local-fs.target.requires/${mountname}.mount
            else
                ln -sf ${systemd_unitdir}/system/${mountname}.mount ${IMAGE_ROOTFS_EXT4}/lib/systemd/system/local-fs.target.requires/${mountname}.mount
            fi
        fi
    done
}

create_rootfs_ext4[cleandirs] = "${IMAGE_ROOTFS_EXT4}"
python create_rootfs_ext4 () {
    src_dir = d.getVar("IMAGE_ROOTFS")
    dest_dir = d.getVar("IMAGE_ROOTFS_EXT4")
    if os.path.isdir(src_dir):
        oe.path.copyhardlinktree(src_dir, dest_dir)
    else:
        bb.error("rootfs is not generated")
}

do_makesystem[prefuncs] += "create_rootfs_ext4"
do_makesystem[prefuncs] += "create_symlink_systemd_ext4_mount_rootfs"
do_makesystem() {
    cp ${MACHINE_FSCONFIG_CONF_FULL_PATH} ${WORKDIR}/rootfs-fsconfig.conf
    # An ugly hack to mitigate a bug in libsparse were random
    # asserts are observed during unsparsing if image size is large.
    # Unsparsing is needed for appending verity metadata to image.
    # Only known workaround is to recreate image if unsparsing fails.
    for count in {1..10}
    do
        make_ext4fs -C ${WORKDIR}/rootfs-fsconfig.conf \
                -B ${IMGDEPLOYDIR}/${IMAGE_BASENAME}/${SYSTEMIMAGE_MAP_TARGET} \
                -a / -b 4096 ${SPARSE_SYSTEMIMAGE_FLAG} \
                -l ${SYSTEM_SIZE_EXT4} \
                ${IMAGE_EXT4_SELINUX_OPTIONS} \
                ${IMGDEPLOYDIR}/${IMAGE_BASENAME}/${SYSTEMIMAGE_TARGET} ${IMAGE_ROOTFS_EXT4}

        simg2img ${IMGDEPLOYDIR}/${IMAGE_BASENAME}/${SYSTEMIMAGE_TARGET} /dev/null || invalid_image=1

        if [ ${invalid_image:-0} -eq 1 ]; then
            echo "Unsparse image failed.. Recreating image"
            continue
        else
            echo "Sparse image is good to use..."
            break
        fi
    done

}
addtask do_makesystem after do_rootfs before do_image_complete

### Generate userdata.img ###
do_makeuserdata[dirs] = "${IMGDEPLOYDIR}/${IMAGE_BASENAME}"

do_makeuserdata() {
    make_ext4fs -B ${IMGDEPLOYDIR}/${IMAGE_BASENAME}/${USERDATAIMAGE_MAP_TARGET} \
                -a /data ${IMAGE_EXT4_SELINUX_OPTIONS} \
                ${SPARSE_SYSTEMIMAGE_FLAG} -b 4096 -l ${USERDATA_SIZE_EXT4} \
                ${IMGDEPLOYDIR}/${IMAGE_BASENAME}/${USERDATAIMAGE_TARGET} \
                ${IMAGE_ROOTFS}/${USERDATA_DIR}
}

addtask do_makeuserdata after do_rootfs before do_build

################################################
############ Generate persist image ############
################################################
PERSIST_IMAGE_ROOTFS_SIZE ?= "6536668"
do_makepersist[dirs] = "${IMGDEPLOYDIR}/${IMAGE_BASENAME}"

do_makepersist() {
    make_ext4fs ${PERSISTFS_CONFIG} ${MAKEEXT4_MOUNT_OPT} \
                -B ${IMGDEPLOYDIR}/${IMAGE_BASENAME}/${PERSISTIMAGE_MAP_TARGET} \
                -s -l ${PERSIST_IMAGE_ROOTFS_SIZE} \
                ${IMGDEPLOYDIR}/${IMAGE_BASENAME}/${PERSISTIMAGE_TARGET} \
                ${IMAGE_ROOTFS}/persist

    # Empty the /persist folder so that it doesn't end up
    # in system image as well
    rm -rf ${IMAGE_ROOTFS}/persist/*
}
# It must be before do_makesystem to remove /persist
addtask do_makepersist after do_rootfs before do_makesystem

################################################
############ Generate cache image ############
################################################
CACHE_IMAGE_ROOTFS_SIZE ?= "8388608"
do_makecache[dirs] = "${IMGDEPLOYDIR}/${IMAGE_BASENAME}"

do_makecache() {
    make_ext4fs  -s -l ${CACHE_IMAGE_ROOTFS_SIZE} \
                ${IMGDEPLOYDIR}/${IMAGE_BASENAME}/${CACHEIMAGE_TARGET}
}

addtask do_makecache after do_rootfs before do_makesystem

################################################
############ Generate systemrw image ############
################################################
SYSTEMRW_IMAGE_ROOTFS_SIZE ?= "8388608"
do_makesystemrw[dirs] = "${IMGDEPLOYDIR}/${IMAGE_BASENAME}"

do_makesystemrw() {
    make_ext4fs  -a /systemrw ${IMAGE_EXT4_SELINUX_OPTIONS} \
                 -s -b 4096 -l ${SYSTEMRW_IMAGE_ROOTFS_SIZE} \
                 ${IMGDEPLOYDIR}/${IMAGE_BASENAME}/${SYSTEMRWIMAGE_TARGET}
}

addtask do_makesystemrw after do_rootfs before do_makesystem
