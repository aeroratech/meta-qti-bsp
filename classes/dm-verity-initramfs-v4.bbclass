# Copyright (c) 2023 Qualcomm Innovation Center, Inc. All rights reserved.
# SPDX-License-Identifier: BSD-3-Clause-Clear

# This file "dm-verity-initramfs-v4.bbclasss" will:
# 1, Generate boot.img with initramfs.
# 2, Enable dm-verity feature with avb for NAND. (This feature will be added in the later commit)

CONFLICT_MACHINE_FEATURES += " dm-verity-bootloader dm-verity-initramfs dm-verity-none"

BOOTIMGDEPLOYDIR = "${WORKDIR}/deploy-${PN}-bootimage-complete"
KERNEL_CMD_PARAMS += "root=/dev/ram rootfstype=ramfs init=/sbin/init"

INITRAMFS_IMAGE ?= ''
RAMDISK ?= "${IMGDEPLOYDIR}/${PN}-initrd.gz"
def get_ramdisk_path(d):
    if os.path.exists(d.getVar('RAMDISK')):
        return '%s' %(d.getVar('RAMDISK'))
    return '/dev/null'

RAMDISK_PATH = "${@get_ramdisk_path(d)}"

MKBOOTUTIL = '${@oe.utils.conditional("PREFERRED_PROVIDER_virtual/mkbootimg-native", "mkbootimg-gki-native", "scripts/mkbootimg.py", "mkbootimg", d)}'

python do_makeboot () {
    import subprocess

    xtra_parms=""
    if bb.utils.contains('MACHINE_FEATURES', 'nand-boot', True, False, d):
        xtra_parms = " --tags-addr" + " " + d.getVar('KERNEL_TAGS_OFFSET')
        if oe.utils.conditional("PREFERRED_PROVIDER_virtual/mkbootimg-native", "mkbootimg-gki-native", True, False, d):
            xtra_parms = xtra_parms.replace("--tags-addr", "--tags_offset")

    if (d.getVar("BOOT_HEADER_VERSION") or "0") != "0":
        xtra_parms += " --header_version " + d.getVar('BOOT_HEADER_VERSION')
        # header version setting expects dtb to be passed seprately but not appended to kernel
        xtra_parms += " --dtb " + d.getVar('DEPLOY_DIR_IMAGE', True) + "/" + d.getVar('KERNEL_DTB_NAMES').strip()

    mkboot_bin_path = d.getVar('STAGING_BINDIR_NATIVE', True) + "/" + d.getVar('MKBOOTUTIL')
    ramdisk_path    = d.getVar('RAMDISK_PATH')
    zimg_path       = d.getVar('DEPLOY_DIR_IMAGE', True) + "/" + d.getVar('KERNEL_IMAGETYPE', True)
    cmdline         = "\"" + d.getVar('KERNEL_CMD_PARAMS', True) + "\""
    pagesize        = d.getVar('PAGE_SIZE', True)
    base            = d.getVar('KERNEL_BASE', True)
    output          = d.getVar('BOOTIMAGE_TARGET', True)

    # cmd to make boot.img
    cmd =  mkboot_bin_path + " --kernel %s --cmdline %s --pagesize %s --base %s --ramdisk %s --ramdisk_offset 0x0 %s --output %s" \
           % (zimg_path, cmdline, pagesize, base, ramdisk_path, xtra_parms, output )
    bb.debug(1, "dm-verity-initramfs-v4 do_makeboot cmd: %s" % (cmd))
    try:
        ret = subprocess.check_output(cmd, shell=True)
    except RuntimeError as e:
        bb.error("dm-verity-initramfs-v4 cmd: %s failed with error %s" % (cmd, str(e)))
}
do_makeboot[dirs]      = "${BOOTIMGDEPLOYDIR}/${IMAGE_BASENAME}"

# Make sure native tools and vmlinux ready to create boot.img
do_makeboot[depends] += "virtual/kernel:do_deploy virtual/mkbootimg-native:do_populate_sysroot"
do_makeboot[depends] += "${PN}:do_ramdisk_create"
SSTATETASKS += "do_makeboot"
SSTATE_SKIP_CREATION_task-makeboot = '1'
do_makeboot[sstate-inputdirs] = "${BOOTIMGDEPLOYDIR}"
do_makeboot[sstate-outputdirs] = "${DEPLOY_DIR_IMAGE}"
do_makeboot[stamp-extra-info] = "${MACHINE_ARCH}"

addtask do_makeboot before do_image_complete
