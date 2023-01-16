# Convert human readable partition sizes into bytes
CACHE_IMAGE_ROOTFS_SIZE    = "${@get_size_in_bytes(d.getVar('CACHE_SIZE_EXT4') or '8000KiB')}"
SYSTEM_IMAGE_ROOTFS_SIZE   = "${@get_size_in_bytes(d.getVar('SYSTEM_SIZE_EXT4') or '256MB')}"
SYSTEMRW_IMAGE_ROOTFS_SIZE = "${@get_size_in_bytes(d.getVar('SYSTEMRW_SIZE_EXT4') or '8000KiB')}"
PERSIST_IMAGE_ROOTFS_SIZE  = "${@get_size_in_bytes(d.getVar('PERSIST_SIZE_EXT4') or '6MiB')}"
USERDATA_IMAGE_ROOTFS_SIZE = "${@get_size_in_bytes(d.getVar('USERDATA_SIZE_EXT4') or '1GB')}"

# if A/B support is supported, generate OTA pkg by default.
GENERATE_AB_OTA_PACKAGE ?= "${@bb.utils.contains('COMBINED_FEATURES', 'qti-ab-boot', '1', '', d)}"

QIMGEXT4CLASSES  = ""
QIMGEXT4CLASSES += "${@bb.utils.contains('GENERATE_AB_OTA_PACKAGE', '1', 'ab-ota-ext4', '', d)}"
QIMGEXT4CLASSES += "${@bb.utils.contains('MACHINE_FEATURES', 'qti-recovery', 'ota-ext4', '', d)}"

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

# Ensure SELinux file context variable is defined
SELINUX_FILE_CONTEXTS ?= ""
SELINUX_IMG_S = "${@['-S ${SELINUX_FILE_CONTEXTS}', ''][d.getVar('SELINUX_FILE_CONTEXTS') == '']}"
IMAGE_EXT4_SELINUX_OPTIONS = "${@bb.utils.contains('DISTRO_FEATURES', 'selinux', '${SELINUX_IMG_S}', '', d)}"

ROOTFS_POSTPROCESS_COMMAND += "do_fsconfig;"
ROOTFS_POSTPROCESS_COMMAND += "${@bb.utils.contains('MACHINE_MNT_POINTS', 'overlay', 'gen_overlayfs;', '', d)}"

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
            elif [[ "$mountname" == "overlay" ]] ; then
                if ${@bb.utils.contains('DISTRO_FEATURES', 'full-disk-encryption', 'false', 'true', d)} ; then
                   ln -sf ${systemd_unitdir}/system/${mountname}.mount ${IMAGE_ROOTFS_EXT4}/lib/systemd/system/local-fs.target.requires/${mountname}.mount
                fi
            else
                ln -sf ${systemd_unitdir}/system/${mountname}.mount ${IMAGE_ROOTFS_EXT4}/lib/systemd/system/local-fs.target.requires/${mountname}.mount
            fi
        fi
    done
   # Remove generator binaries and ensure that we don't rely on generators for mount or service files.
   rm -rf ${IMAGE_ROOTFS_EXT4}/lib/systemd/system-generators/systemd-debug-generator
   rm -rf ${IMAGE_ROOTFS_EXT4}/lib/systemd/system-generators/systemd-fstab-generator
   rm -rf ${IMAGE_ROOTFS_EXT4}/lib/systemd/system-generators/systemd-gpt-auto-generator
   rm -rf ${IMAGE_ROOTFS_EXT4}/lib/systemd/system-generators/systemd-hibernate-resume-generator
   rm -rf ${IMAGE_ROOTFS_EXT4}/lib/systemd/system-generators/systemd-rc-local-generator
   rm -rf ${IMAGE_ROOTFS_EXT4}/lib/systemd/system-generators/systemd-system-update-generator
   rm -rf ${IMAGE_ROOTFS_EXT4}/lib/systemd/system-generators/systemd-sysv-generator
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
# The system image size update that happens in do_make_verity_enabled_system_image
#  step is not persistent outside that task scope. Update it again within this
#  task's scope.
do_makesystem[prefuncs] += "${@bb.utils.contains('DISTRO_FEATURES', 'dm-verity', bb.utils.contains('MACHINE_FEATURES', 'dm-verity-bootloader', 'adjust_system_size_for_verity', '', d), '', d)}"

do_makesystem() {
    # Empty the /persist folder so that it doesn't end up
    # in system image as well
    rm -rf ${IMAGE_ROOTFS_EXT4}/persist/*
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
                -l ${SYSTEM_IMAGE_ROOTFS_SIZE} \
                ${IMAGE_EXT4_SELINUX_OPTIONS} \
                ${IMGDEPLOYDIR}/${IMAGE_BASENAME}/${SYSTEMIMAGE_TARGET} ${IMAGE_ROOTFS_EXT4}

        invalid_image=0
        simg2img ${IMGDEPLOYDIR}/${IMAGE_BASENAME}/${SYSTEMIMAGE_TARGET} /dev/null || invalid_image=1

        if [ ${invalid_image} -eq 1 ]; then
            echo "Unsparse image failed.. Recreating image"
            continue
        else
            echo "Sparse image is good to use..."
            break
        fi
    done

}
addtask do_makesystem after do_image before do_image_complete

################################################
### Generate userdata.img ###
################################################
USERDATA_DIR ??= "${@bb.utils.contains('MACHINE_MNT_POINTS', 'overlay', 'overlay', 'data', d)}"
do_makeuserdata[dirs] = "${IMGDEPLOYDIR}/${IMAGE_BASENAME}"

do_makeuserdata() {
    cp ${MACHINE_FSCONFIG_CONF_FULL_PATH} ${WORKDIR}/rootfs-fsconfig.conf
    make_ext4fs -C ${WORKDIR}/rootfs-fsconfig.conf \
                -B ${IMGDEPLOYDIR}/${IMAGE_BASENAME}/${USERDATAIMAGE_MAP_TARGET} \
                -a /data ${IMAGE_EXT4_SELINUX_OPTIONS} \
                ${SPARSE_SYSTEMIMAGE_FLAG} -b 4096 -l ${USERDATA_IMAGE_ROOTFS_SIZE} \
                ${IMGDEPLOYDIR}/${IMAGE_BASENAME}/${USERDATAIMAGE_TARGET} \
                ${IMAGE_ROOTFS}/${USERDATA_DIR}
}

addtask do_makeuserdata after do_image before do_build

################################################
############ Generate persist image ############
################################################
do_makepersist[dirs] = "${IMGDEPLOYDIR}/${IMAGE_BASENAME}"

do_makepersist() {
    make_ext4fs ${PERSISTFS_CONFIG} ${MAKEEXT4_MOUNT_OPT} \
                -B ${IMGDEPLOYDIR}/${IMAGE_BASENAME}/${PERSISTIMAGE_MAP_TARGET} \
                -s -l ${PERSIST_IMAGE_ROOTFS_SIZE} \
                ${IMGDEPLOYDIR}/${IMAGE_BASENAME}/${PERSISTIMAGE_TARGET} \
                ${IMAGE_ROOTFS}/persist
}
# It must be before do_makesystem to remove /persist
addtask do_makepersist after do_image before do_makesystem

CACHE_IMG_ENABLE = "${@bb.utils.contains('MACHINE_MNT_POINTS', '/cache', 'true', 'false', d)}"
SYSTEMRW_IMG_ENABLE = "${@bb.utils.contains('MACHINE_MNT_POINTS', '/systemrw', 'true', 'false', d)}"

################################################
############ Generate cache image ############
################################################
do_makecache[dirs] = "${IMGDEPLOYDIR}/${IMAGE_BASENAME}"

do_makecache() {
    make_ext4fs  -s -l ${CACHE_IMAGE_ROOTFS_SIZE} \
                ${IMGDEPLOYDIR}/${IMAGE_BASENAME}/${CACHEIMAGE_TARGET} \
                ${IMAGE_ROOTFS}/cache
}

################################################
############ Generate systemrw image ############
################################################
do_makesystemrw[dirs] = "${IMGDEPLOYDIR}/${IMAGE_BASENAME}"

do_makesystemrw() {
    make_ext4fs  -a /systemrw ${IMAGE_EXT4_SELINUX_OPTIONS} \
                 -s -b 4096 -l ${SYSTEMRW_IMAGE_ROOTFS_SIZE} \
                 ${IMGDEPLOYDIR}/${IMAGE_BASENAME}/${SYSTEMRWIMAGE_TARGET}
}

python() {
    systemrw_img = d.getVar("SYSTEMRW_IMG_ENABLE")
    cache_img = d.getVar("CACHE_IMG_ENABLE")
    if systemrw_img == "true":
       bb.build.addtask('do_makesystemrw', 'do_makesystem', 'do_image', d)
    if cache_img == "true":
       bb.build.addtask('do_makecache', 'do_makesystem', 'do_image', d)
}

#############################################################
############ Generate Unsparsed images if needed ############
#############################################################
UNSPARSE_IMAGE_SUPPORT_FLAG = "${@bb.utils.contains('IMAGE_FEATURES', 'csm', 'true', 'flase', d)}"
do_unsparse_images[dirs] = "${IMGDEPLOYDIR}/${IMAGE_BASENAME}"

do_unsparse_images() {
    simg2img ${IMGDEPLOYDIR}/${IMAGE_BASENAME}/${SYSTEMIMAGE_TARGET} ${IMGDEPLOYDIR}/${IMAGE_BASENAME}/${SYSTEMIMAGE_TARGET}.raw
    simg2img ${IMGDEPLOYDIR}/${IMAGE_BASENAME}/${USERDATAIMAGE_TARGET} ${IMGDEPLOYDIR}/${IMAGE_BASENAME}/${USERDATAIMAGE_TARGET}.raw
    simg2img ${IMGDEPLOYDIR}/${IMAGE_BASENAME}/${PERSISTIMAGE_TARGET} ${IMGDEPLOYDIR}/${IMAGE_BASENAME}/${PERSISTIMAGE_TARGET}.raw
    if [ ${CACHE_IMG_ENABLE} == "true" ]; then
        simg2img ${IMGDEPLOYDIR}/${IMAGE_BASENAME}/${CACHEIMAGE_TARGET} ${IMGDEPLOYDIR}/${IMAGE_BASENAME}/${CACHEIMAGE_TARGET}.raw
    fi
    if [ ${SYSTEMRW_IMG_ENABLE} == "true" ]; then
        simg2img ${IMGDEPLOYDIR}/${IMAGE_BASENAME}/${SYSTEMRWIMAGE_TARGET} ${IMGDEPLOYDIR}/${IMAGE_BASENAME}/${SYSTEMRWIMAGE_TARGET}.raw
    fi
}

python() {
    if (d.getVar("UNSPARSE_IMAGE_SUPPORT_FLAG") == "true"):
       bb.build.addtask('do_unsparse_images', 'do_image_complete', 'do_makesystem', d)
}
