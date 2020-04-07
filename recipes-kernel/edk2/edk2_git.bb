inherit deploy
DESCRIPTION = "UEFI bootloader"
LICENSE = "BSD"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=3775480a712fc46a69647678acb234cb"

BUILD_OS = "linux"

PACKAGE_ARCH = "${MACHINE_ARCH}"
FILESPATH =+ "${WORKSPACE}/bootable/bootloader/:"

SRC_URI = "file://edk2"
S         =  "${WORKDIR}/edk2"

INSANE_SKIP_${PN} = "arch"

VBLE = "${@bb.utils.contains('DISTRO_FEATURES', 'vble','1', '0', d)}"

VERITY_ENABLED = "${@bb.utils.contains('DISTRO_FEATURES', 'dm-verity','1', '0', d)}"

EARLY_ETH = "${@bb.utils.contains('DISTRO_FEATURES', 'early-eth', '1', '0', d)}"

SYSTEMD_BOOTSLOT_ENABLED = "${@bb.utils.contains('COMBINED_FEATURES', 'qti-ab-boot','1', '0', d)}"

EXTRA_OEMAKE = " \
    'TARGET_ARCHITECTURE=${TARGET_ARCH}' \
    'BUILDDIR=${B}' \
    'BOOTLOADER_OUT=${B}/out' \
    'ENABLE_LE_VARIANT=true' \
    'ENABLE_SYSTEMD_BOOTSLOT=${SYSTEMD_BOOTSLOT_ENABLED}'\
    'VERIFIED_BOOT_LE=${VBLE}' \
    'VERITY_LE=${VERITY_ENABLED}' \
    'INIT_BIN_LE=\"/sbin/init\"' \
    'EDK_TOOLS_PATH=${S}/BaseTools' \
    'EARLY_ETH_ENABLED=${EARLY_ETH}' \
"
EXTRA_OEMAKE_append_qcs40x = " 'DISABLE_PARALLEL_DOWNLOAD_FLASH=1'"
NAND_SQUASHFS_SUPPORT = "${@bb.utils.contains('DISTRO_FEATURES', 'nand-squashfs', '1', '0', d)}"
EXTRA_OEMAKE_append = " 'NAND_SQUASHFS_SUPPORT=${NAND_SQUASHFS_SUPPORT}'"

do_compile () {
    export CC=${BUILD_CC}
    export CXX=${BUILD_CXX}
    export LD=${BUILD_LD}
    export AR=${BUILD_AR}
    oe_runmake -f makefile all
}

do_install[noexec]="1"
do_configure[noexec]="1"

do_deploy() {
    install -m 644 ${WORKDIR}/abl.elf ${DEPLOYDIR}
}

do_deploy[dirs] = "${S} ${DEPLOYDIR}"
addtask deploy before do_build after do_install

PACKAGE_STRIP = "no"
