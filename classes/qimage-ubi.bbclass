# if A/B support is supported, generate OTA pkg by default.
GENERATE_AB_OTA_PACKAGE ?= "${@bb.utils.contains('COMBINED_FEATURES', 'qti-ab-boot', '1', '', d)}"

QIMGUBICLASSES  = ""
# To be implemented
# QIMGUBICLASSES += "${@bb.utils.contains('GENERATE_AB_OTA_PACKAGE', '1', 'ab-ota-ext4', '', d)}"

inherit ${QIMGUBICLASSES}

IMAGE_FEATURES[validitems] += "persist-volume"

SYSTEMIMAGE_UBI_TARGET ?= "sysfs.ubi"
SYSTEMIMAGE_UBIFS_TARGET ?= "sysfs.ubifs"
USERIMAGE_UBIFS_TARGET ?= "userfs.ubifs"
USERIMAGE_ROOTFS ?= "${WORKDIR}/usrfs"

UBINIZE_CFG ?= "ubinize_system.cfg"

IMAGE_UBIFS_SELINUX_OPTIONS = "${@bb.utils.contains('DISTRO_FEATURES', 'selinux', '--selinux=${SELINUX_FILE_CONTEXTS}', '', d)}"

do_image_ubi[noexec] = "1"
do_image_ubifs[noexec] = "1"
do_image_multiubi[noexec] = "1"

################################################
### Generate sysfs.ubi #####
################################################

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
vol_size="${SYSTEM_VOLUME_SIZE}"
[usrfs_volume]
mode=ubi
image="${USERIMAGE_UBIFS_TARGET}"
vol_id=1
vol_type=dynamic
vol_name=usrfs
vol_size="${CACHE_VOLUME_SIZE}"
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

do_makesystem_ubi[cleandirs] += "${USERIMAGE_ROOTFS}"
do_makesystem_ubi[prefuncs] += "do_create_ubinize_config"
do_makesystem_ubi[dirs] = "${IMGDEPLOYDIR}/${IMAGE_BASENAME}"

do_makesystem_ubi() {
    mkfs.ubifs -r ${IMAGE_ROOTFS} ${IMAGE_UBIFS_SELINUX_OPTIONS} -o ${SYSTEMIMAGE_UBIFS_TARGET} ${MKUBIFS_ARGS}
    mkfs.ubifs -r ${USERIMAGE_ROOTFS} -o ${USERIMAGE_UBIFS_TARGET} ${MKUBIFS_ARGS}
    ubinize -o ${SYSTEMIMAGE_UBI_TARGET} ${UBINIZE_ARGS} ${UBINIZE_CFG}
}

addtask do_makesystem_ubi after do_rootfs before do_image_complete
