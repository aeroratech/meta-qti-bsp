require recipes-kernel/edk2/edk2_git.bb

PROVIDES_remove = "virtual/bootloader"

NAND_SQUASHFS_SUPPORT = "${@bb.utils.contains('DISTRO_FEATURES', 'nand-squashfs', '1', '0', d)}"
EXTRA_OEMAKE_append = " 'NAND_SQUASHFS_SUPPORT=${NAND_SQUASHFS_SUPPORT}'"

do_deploy() {
        install ${D}/boot/abl.elf ${DEPLOYDIR}/abl-squashfs.elf
}
