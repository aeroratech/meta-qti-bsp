DEPENDS += "cryptsetup-native openssl-native"

CONFLICT_MACHINE_FEATURES += " dm-verity-bootloader dm-verity-none"

CORE_IMAGE_EXTRA_INSTALL += "cryptsetup"

VERITY_SALT = "aee087a5be3b982978c923f566a94613496b417f2af592639bc80d141e34dfe7"
BLOCK_SIZE = "4096"
FEC_ROOTS = "2"

VERITY_HASH_DEVICE = "${WORKDIR}/${IMAGE_NAME}.verityhash"
VERITY_FEC_DEVICE = "${WORKDIR}/${IMAGE_NAME}.verityfec"
UNSPARSED_SYSTEMIMAGE = "${IMGDEPLOYDIR}/${IMAGE_BASENAME}/${SYSTEMIMAGE_TARGET}"

python adjust_system_size_for_verity () {
    system_size = int(d.getVar('SYSTEM_SIZE_EXT4'))
    block_size = int(d.getVar('BLOCK_SIZE'))
    data_blocks = int(system_size / block_size)
    d.setVar('DATA_BLOCKS', str(data_blocks))
    if system_size % block_size != 0:
        bb.warn("aligning system size to {} bytes".format(block_size))
        d.setVar('SYSTEM_SIZE_EXT4', str(data_blocks * block_size))
}
do_makesystem[prefuncs] += "adjust_system_size_for_verity"

append_verity_metadata_to_system_image () {
    # Reformat the system image with verity support
    veritysetup format ${UNSPARSED_SYSTEMIMAGE} \
                ${VERITY_HASH_DEVICE} \
                --data-blocks ${DATA_BLOCKS} \
                --fec-device ${VERITY_FEC_DEVICE} \
                --fec-roots ${FEC_ROOTS} \
                --salt ${VERITY_SALT} > ${WORKDIR}/verity_metadata.txt

    # Append hash and fec data to the end of the system image after calculating offsets
    hash_offset=${SYSTEM_SIZE_EXT4}
    hash_size=`wc -c ${VERITY_HASH_DEVICE} | awk '{print $1}'`
    fec_offset=`expr ${hash_offset} + ${hash_size}`
    cat ${VERITY_HASH_DEVICE} >> ${UNSPARSED_SYSTEMIMAGE}
    cat ${VERITY_FEC_DEVICE} >> ${UNSPARSED_SYSTEMIMAGE}

    # Generate environment variables for veritysetup on target system
    root_hash=`awk -F ':' '{ if ($1 == "Root hash") print $2 }' ${WORKDIR}/verity_metadata.txt | sed "s/^[ \t]*//"`
    cat <<-EOF > ${WORKDIR}/verity.env
	VERITY_DATA_BLOCKS=${DATA_BLOCKS}
	VERITY_HASH_OFFSET=${hash_offset}
	VERITY_FEC_OFFSET=${fec_offset}
	VERITY_FEC_ROOTS=${FEC_ROOTS}
	VERITY_SALT=${VERITY_SALT}
	VERITY_ROOT_HASH=${root_hash}
	EOF

    # Sign the root hash
    echo -n "${root_hash}" > ${WORKDIR}/roothash.txt
    openssl smime -sign -nocerts -noattr -binary -in ${WORKDIR}/roothash.txt -inkey ${STAGING_KERNEL_BUILDDIR}/certs/verity_key.pem -signer ${STAGING_KERNEL_BUILDDIR}/certs/verity_cert.pem -outform der -out ${WORKDIR}/verity_sig.txt

    # Clean up large files that are no longer needed
    rm ${VERITY_HASH_DEVICE}
    rm ${VERITY_FEC_DEVICE}
}
do_makesystem[postfuncs] += "append_verity_metadata_to_system_image"

# ramdisk creation now requires the verity artifacts
do_ramdisk_create[depends] += "${PN}:do_makesystem"

##### Generate boot.img ######
BOOTIMGDEPLOYDIR = "${WORKDIR}/deploy-${PN}-bootimage-complete"

INITRAMFS_IMAGE ?= ''
RAMDISK = "${DEPLOY_DIR_IMAGE}/${INITRAMFS_IMAGE}-${MACHINE}.${INITRAMFS_FSTYPES}"
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
