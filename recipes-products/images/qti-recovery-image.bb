inherit core-image

# This class creates recoveryfs
DEPENDS += "virtual/kernel"
DEPENDS += "pkgconfig-native gtk-doc-native gettext-native mkbootimg-native"
DEPENDS += "bzip2 fsconfig-native applypatch-native bsdiff-native ext4-utils-native mtd-utils-native"

# Use busybox as login manager
IMAGE_LOGIN_MANAGER = "busybox-static"

# Include minimum init and init scripts
IMAGE_DEV_MANAGER = "udev"
IMAGE_INIT_MANAGER = "systemd"
IMAGE_INITSCRIPTS ?= ""

IMAGE_LINGUAS = ""

do_rootfs[nostamp] = "1"
do_build[nostamp]  = "1"

do_image_ext4[noexec] = "1"
do_image_ubi[noexec] = "1"
do_image_ubifs[noexec] = "1"
do_image_multiubi[noexec] = "1"


CORE_IMAGE_EXTRA_INSTALL += "\
            packagegroup-qti-recoveryfs \
"

RM_WORK_EXCLUDE += "${PN}"

# Configs for generating recovery.ubi
RECOVERY_MKUBIFS_ARGS = "-m 4096 -e 253952 -c 200 -F"
RECOVERY_UBINIZE_CFG = "ubinize-recoveryfs.cfg"
RECOVOERY_UBIFS_IMAGE = "recoveryfs.ubifs"
RECOVOERY_UBI_IMAGE = "recoveryfs.ubi"
RECOVERY_SYSTEMRW_VOLUME_SIZE ?= "4MiB"

#configs for ext4
RECOVERYFS_SIZE_EXT4 ?= "100000000"
RECOVOERY_EXT4_IMAGE = "recoveryfs.img"

RECOVERY_UBI_SELINUX_OPTIONS = "${@bb.utils.contains('DISTRO_FEATURES', 'selinux', '--selinux=${SELINUX_FILE_CONTEXTS}', '', d)}"
RECOVERY_EXT4_SELINUX_OPTIONS = "${@bb.utils.contains('DISTRO_FEATURES', 'selinux', '-S ${SELINUX_FILE_CONTEXTS}', '', d)}"

# Update usb composition in recovery mode
RECOVERY_USBCOMPOSITION ?= "901D"
update_usb_composition() {
    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        if [ -e ${IMAGE_ROOTFS}/etc/usb/boot_hsusb_comp ]; then
            echo ${RECOVERY_USBCOMPOSITION} > ${IMAGE_ROOTFS}/etc/usb/boot_hsusb_comp
        fi
    fi
}

generate_public_key() {
    if ${@bb.utils.contains('DISTRO_FEATURES','ota-package-verification', 'true', 'false', d)}; then
        openssl pkcs8 -inform DER -nocrypt -in ${WORKSPACE}/OTA/build/target/product/security/testkey.pk8 -out ${TMPDIR}/work/x86_64-linux/releasetools-native/1.0-r0/releasetools/private.pem
        openssl rsa -in ${TMPDIR}/work/x86_64-linux/releasetools-native/1.0-r0/releasetools/private.pem -outform PEM -pubout > ${IMAGE_ROOTFS}/res/public.pem
    fi
}

# Need to copy ubinize.cfg file in the deploy directory
create_ubinize_config[dirs] = "${IMGDEPLOYDIR}"
create_ubinize_config() {
    echo \[recoveryfs_volume\] > "${RECOVERY_UBINIZE_CFG}"
    echo mode=ubi >> "${RECOVERY_UBINIZE_CFG}"
    echo image="${RECOVOERY_UBIFS_IMAGE}" >> "${RECOVERY_UBINIZE_CFG}"
    echo vol_id=0 >> "${RECOVERY_UBINIZE_CFG}"
    echo vol_type=dynamic >> "${RECOVERY_UBINIZE_CFG}"
    echo vol_name=rootfs >> "${RECOVERY_UBINIZE_CFG}"
    echo vol_flags = autoresize >> "${RECOVERY_UBINIZE_CFG}"

    if ${@bb.utils.contains('MACHINE_FEATURES','qti-sdx', 'true', 'false', d)}; then
        echo \[systemrw_volume\] >> "${RECOVERY_UBINIZE_CFG}"
        echo mode=ubi >> "${RECOVERY_UBINIZE_CFG}"
        echo vol_id=1 >> "${RECOVERY_UBINIZE_CFG}"
        echo vol_type=dynamic >> "${RECOVERY_UBINIZE_CFG}"
        echo vol_name=systemrw >> "${RECOVERY_UBINIZE_CFG}"
        echo vol_size="${RECOVERY_SYSTEMRW_VOLUME_SIZE}" >> "${RECOVERY_UBINIZE_CFG}"
    fi
}

fakeroot do_create_recoveryfs_ubi() {
    mkfs.ubifs -r ${IMAGE_ROOTFS} ${RECOVERY_UBI_SELINUX_OPTIONS} -o ${RECOVOERY_UBIFS_IMAGE} ${RECOVERY_MKUBIFS_ARGS}
    ubinize -o ${RECOVOERY_UBI_IMAGE} ${UBINIZE_ARGS} ${RECOVERY_UBINIZE_CFG}
    chmod 644 ${RECOVOERY_UBI_IMAGE}
}

do_fsconfig() {
    chmod go-r ${IMAGE_ROOTFS}/etc/passwd
}

create_system_dir() {
    if [ ! -e ${IMAGE_ROOTFS}/system ]; then
        mkdir -p ${IMAGE_ROOTFS}/system
    fi
}

# Below is to generate sparse ext4 recovery image (OE by default supports raw ext4 images)
do_create_recoveryfs_ext4() {
    if ${@bb.utils.contains('COMBINED_FEATURES', 'qti-ab-boot', 'false', 'true', d)}; then
        make_ext4fs -l ${RECOVERYFS_SIZE_EXT4} ${RECOVOERY_EXT4_IMAGE} ${IMAGE_ROOTFS}
        # Create an unsparse image as well to be included as part of ota target-files
        #simg2img ${RECOVOERY_EXT4_IMAGE} recovery-unsparsed.ext4
    fi
}

do_create_recoveryfs_ubi[prefuncs] += "update_usb_composition"
do_create_recoveryfs_ubi[prefuncs] += "generate_public_key"
do_create_recoveryfs_ubi[prefuncs] += "create_system_dir"
do_create_recoveryfs_ubi[prefuncs] += "create_ubinize_config"
do_create_recoveryfs_ubi[dirs] = "${IMGDEPLOYDIR}"

do_create_recoveryfs_ext4[prefuncs] = "do_fsconfig"
do_create_recoveryfs_ext4[dirs] = "${IMGDEPLOYDIR}"

python () {
    if bb.utils.contains('IMAGE_FSTYPES', 'ubi', True, False, d):
        bb.build.addtask('do_create_recoveryfs_ubi', 'do_image_complete', 'do_image', d)
    if bb.utils.contains('IMAGE_FSTYPES', 'ext4', True, False, d):
        bb.build.addtask('do_create_recoveryfs_ext4', 'do_image_complete', 'do_image', d)
}
