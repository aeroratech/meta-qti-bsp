# Copyright (c) 2022 Qualcomm Innovation Center, Inc. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted (subject to the limitations in the
# disclaimer below) provided that the following conditions are met:
#
#    * Redistributions of source code must retain the above copyright
#      notice, this list of conditions and the following disclaimer.
#
#    * Redistributions in binary form must reproduce the above
#      copyright notice, this list of conditions and the following
#      disclaimer in the documentation and/or other materials provided
#       with the distribution.
#
#    * Neither the name of Qualcomm Innovation Center, Inc. nor the names of its
#      contributors may be used to endorse or promote products derived
#           from this software without specific prior written permission.
#
# NO EXPRESS OR IMPLIED LICENSES TO ANY PARTY'S PATENT RIGHTS ARE
# GRANTED BY THIS LICENSE. THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT
# HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
# GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
# IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
# IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Generates boot.img without verity

CONFLICT_MACHINE_FEATURES += " dm-verity-bootloader dm-verity-initramfs dm-verity-initramfs-v4"

BOOTIMGDEPLOYDIR = "${WORKDIR}/deploy-${PN}-bootimage-complete"

SQSH_FS = "${@bb.utils.contains('IMAGE_FSTYPES', 'squashfs', '1', '0', d)}"

INITRAMFS_IMAGE ?= ''
RAMDISK ?= "${DEPLOY_DIR_IMAGE}/${INITRAMFS_IMAGE}-${MACHINE}.${INITRAMFS_FSTYPES}"
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
    bb.debug(1, "dm-verity-none do_makeboot cmd: %s" % (cmd))
    try:
        ret = subprocess.check_output(cmd, shell=True)
    except RuntimeError as e:
        bb.error("dm-verity-none cmd: %s failed with error %s" % (cmd, str(e)))
}
do_makeboot[dirs]      = "${BOOTIMGDEPLOYDIR}/${IMAGE_BASENAME}"

# Make sure native tools and vmlinux ready to create boot.img
do_makeboot[depends] += "virtual/kernel:do_deploy virtual/mkbootimg-native:do_populate_sysroot"
SSTATETASKS += "do_makeboot"
SSTATE_SKIP_CREATION_task-makeboot = '1'
do_makeboot[sstate-inputdirs] = "${BOOTIMGDEPLOYDIR}"
do_makeboot[sstate-outputdirs] = "${DEPLOY_DIR_IMAGE}"
do_makeboot[stamp-extra-info] = "${MACHINE_ARCH}"

python do_makeboot_setscene () {
    sstate_setscene(d)
}
addtask do_makeboot_setscene

addtask do_makeboot before do_image_complete

python() {
    if d.getVar("SQSH_FS") == "1":
       bb.build.addtask('do_copy_squashfs_boot', 'do_image_complete', 'do_makeboot', d)
}

# copy boot.img from default build path to squashfs build path
python do_copy_squashfs_boot() {
    import os
    import shutil
    try:
        img_src_path = os.path.join(d.getVar('BOOTIMGDEPLOYDIR'), d.getVar('IMAGE_BASENAME'), d.getVar('BOOTIMAGE_TARGET'))
        img_dst_path = os.path.join(d.getVar('BOOTIMGDEPLOYDIR'), d.getVar('IMAGE_BASENAME'), d.getVar('FS_TYPE_SQSH', True), d.getVar('BOOTIMAGE_TARGET'))

        os.makedirs(os.path.join(d.getVar('BOOTIMGDEPLOYDIR'), d.getVar('IMAGE_BASENAME'), d.getVar('FS_TYPE_SQSH', True)), exist_ok=True)
        shutil.copy(img_src_path, img_dst_path)
    except Exception as e:
        bb.error("dm-verity-none boot.img copy for squashfs failed with error %s" % (str(e)))
}
do_copy_squashfs_boot[dirs]     = "${BOOTIMGDEPLOYDIR}/${IMAGE_BASENAME}/${FS_TYPE_SQSH}"
do_copy_squashfs_boot[depends] += "virtual/kernel:do_deploy virtual/mkbootimg-native:do_populate_sysroot"
SSTATETASKS += "do_copy_squashfs_boot"
SSTATE_SKIP_CREATION_task-copy-squashfs-boot = '1'
do_copy_squashfs_boot[sstate-inputdirs] = "${BOOTIMGDEPLOYDIR}/${IMAGE_BASENAME}/${FS_TYPE_SQSH}"
do_copy_squashfs_boot[sstate-outputdirs] = "${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}/${FS_TYPE_SQSH}"
do_copy_squashfs_boot[stamp-extra-info] = "${MACHINE_ARCH}"

python do_copy_squashfs_boot_setscene () {
    sstate_setscene(d)
}
addtask do_copy_squashfs_boot_setscene
