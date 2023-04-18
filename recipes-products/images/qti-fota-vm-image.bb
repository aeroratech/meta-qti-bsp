inherit qimage qramdisk qimage-vm

DEPENDS += "virtual/kernel"

ENABLE_SECUREMSM = "${@d.getVar('MACHINE_SUPPORTS_SECUREMSM') or "True"}"

CORE_IMAGE_EXTRA_INSTALL += " \
    e2fsprogs-mke2fs \
    packagegroup-android-utils \
    ${@bb.utils.contains('DISTRO_FEATURES', 'selinux', 'packagegroup-selinux-minimal', '', d)} \
    ${@oe.utils.conditional('ENABLE_SECUREMSM', 'True', 'packagegroup-qti-securemsm', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'qti-telux', 'packagegroup-qti-telsdk', '', d)} \
    post-boot \
    systemd-machine-units \
    packagegroup-qti-telematics \
"

# Exclude packages
PACKAGE_EXCLUDE += "readline"

ROOTFS_POSTPROCESS_COMMAND_remove = " do_fsconfig;"
USE_DEPMOD = "0"

# Remove build time dependency on squashfs-tools-native.
# To Do: Clean up and remove based on IMAGE_FSTYPES check in qimage.bbclass
DEPENDS_remove = "squashfs-tools-native"
