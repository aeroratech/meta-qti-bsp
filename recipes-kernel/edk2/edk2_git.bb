inherit deploy ${@bb.utils.contains("BBFILE_COLLECTIONS", "meta-python2", "pythonnative", "", d)}
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

VBLE = "${@bb.utils.contains('DISTRO_FEATURES', 'qti-vble','1', '0', d)}"

VBLEIMA = "${@bb.utils.contains('COMBINED_FEATURES', 'vbleima','1', '0', d)}"
VBLEEVM = "${@bb.utils.contains('COMBINED_FEATURES', 'vbleevm','1', '0', d)}"

VERITY_ENABLED = "${@bb.utils.contains('DISTRO_FEATURES', 'dm-verity', bb.utils.contains('MACHINE_FEATURES', 'dm-verity-bootloader', '1', '0', d), '0', d)}"

EARLY_ETH = "${@bb.utils.contains('DISTRO_FEATURES', 'qti-early-eth', '1', '0', d)}"

SYSTEMD_BOOTSLOT_ENABLED = "${@bb.utils.contains('COMBINED_FEATURES', 'qti-ab-boot','1', '0', d)}"

DM_MOD_FOR_KERNEL5_4 = "${@d.getVar('DM_MOD_FOR_KERNEL') or "0"}"

EARLY_USB_INIT = "${@bb.utils.contains('DISTRO_FEATURES', 'qti-earlyusb', '1', '0', d)}"

TARGET_HIBERNATION_INSECURE_ENABLE = "${@bb.utils.contains('HIBERNATION_INSECURE_ENABLE', 'True', 'true', 'false', d)}"

ABL_SAFESTACK = "${@bb.utils.contains('ENABLE_ABL_SAFESTACK', 'True', 'true', 'false', d)}"

SAFESTACK_SUPPORTED_CLANG_VERSION = "${@bb.utils.contains('ENABLE_SAFESTACK_SUPPORTED_CLANG_VERSION', '6.0', '6.0', '0', d)}"

EXTRA_OEMAKE = " \
    'TARGET_ARCHITECTURE=${TARGET_ARCH}' \
    'BUILDDIR=${B}' \
    'BOOTLOADER_OUT=${B}/out' \
    'ENABLE_LE_VARIANT=true' \
    'ENABLE_SYSTEMD_BOOTSLOT=${SYSTEMD_BOOTSLOT_ENABLED}'\
    'ENABLE_DM_MOD_FOR_KERNEL5_4=${DM_MOD_FOR_KERNEL5_4}'\
    'VERIFIED_BOOT_LE=${VBLE}' \
    'INTEGRITY_LE_IMA=${VBLEIMA}' \
    'INTEGRITY_LE_EVM=${VBLEEVM}'\
    'VERITY_LE=${VERITY_ENABLED}' \
    'INIT_BIN_LE=\"/sbin/init\"' \
    'EDK_TOOLS_PATH=${S}/BaseTools' \
    'EARLY_ETH_ENABLED=${EARLY_ETH}' \
    'OVERRIDE_ABL_LOAD_ADDRESS=${ABL_LOAD_ADDRESS}' \
    'HIBERNATION_SUPPORT_INSECURE=${TARGET_HIBERNATION_INSECURE_ENABLE}' \
    'TARGET_SUPPORTS_EARLY_USB_INIT=${EARLY_USB_INIT}' \
    'ABL_SAFESTACK=${ABL_SAFESTACK}' \
    'SAFESTACK_SUPPORTED_CLANG_VERSION=${ENABLE_SAFESTACK_SUPPORTED_CLANG_VERSION}' \
"
EXTRA_OEMAKE_append_qcs40x = " 'DISABLE_PARALLEL_DOWNLOAD_FLASH=1'"
NAND_SQUASHFS_SUPPORT = "${@bb.utils.contains('DISTRO_FEATURES', 'nand-squashfs', '1', '0', d)}"
EXTRA_OEMAKE_append = " 'NAND_SQUASHFS_SUPPORT=${NAND_SQUASHFS_SUPPORT}'"
EXTRA_OEMAKE_append_qti-distro-base-user = " 'VERITY_LE_USE_EXT4_GLUEBI=1'"

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
