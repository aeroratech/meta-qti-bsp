# Rootfs creation.

DEPENDS += "lk"

IMAGE_INSTALL += "packagegroup-core-boot"

IMAGE_INSTALL += "${CORE_IMAGE_EXTRA_INSTALL}"

# The MSM Linux minimal boot image files.


IMAGE_INSTALL += "base-files"
IMAGE_INSTALL += "base-passwd"
#IMAGE_INSTALL += "bluez5"

IMAGE_INSTALL += "binder"

#Install coreutils for non-user builds.
IMAGE_INSTALL += "${@bb.utils.contains('VARIANT','user','','coreutils',d)}"

IMAGE_INSTALL += "glib-2.0"

IMAGE_INSTALL += "libnl"
IMAGE_INSTALL += "libcutils"
IMAGE_INSTALL += "liblog"

IMAGE_INSTALL += "libxml2"

IMAGE_INSTALL += "start-scripts-firmware-links"
IMAGE_INSTALL += "system-core-adbd"
IMAGE_INSTALL += "system-core-logd"
IMAGE_INSTALL += "system-core-leprop"
IMAGE_INSTALL += "system-core-usb"
IMAGE_INSTALL += "system-core-post-boot"
IMAGE_INSTALL += "system-prop"
IMAGE_INSTALL += "systemd-machine-units"


# Don't install GDB and related pacakges in production builds.
DEPENDS += "${@oe.utils.conditional('USER_BUILD', '1', '', 'gdb-cross-arm', d)}"
IMAGE_INSTALL += "${@oe.utils.conditional('USER_BUILD', '1', '', 'gdb', d)}"
IMAGE_INSTALL += "${@oe.utils.conditional('USER_BUILD', '1', '', 'gdbserver', d)}"

# Below is to generate sparse ext4 system image (OE by default supports raw ext4 images)
do_makesystem() {
    cp ${THISDIR}/${BASEMACHINE}/apq8009-fsconfig.conf ${WORKDIR}/rootfs-fsconfig.conf
    make_ext4fs -C ${WORKDIR}/rootfs-fsconfig.conf -B ${DEPLOY_DIR_IMAGE}/system.map -s ${IMAGE_EXT4_SELINUX_OPTIONS} -b 4096 -l ${SYSTEM_SIZE_EXT4} ${DEPLOY_DIR_IMAGE}/${SYSTEMIMAGE_TARGET} ${IMAGE_ROOTFS}
}
