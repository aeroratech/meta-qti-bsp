# This class provides utilities to generate and append verity metadata
# into images as required by device-mapper-verity feature.

DEPENDS += " verity-utils-native"

CONFLICT_MACHINE_FEATURES += " dm-verity-none dm-verity-initramfs"

FIXED_SALT = "aee087a5be3b982978c923f566a94613496b417f2af592639bc80d141e34dfe7"
BLOCK_SIZE = "4096"
BLOCK_DEVICE_SYSTEM = "/dev/block/bootdevice/by-name/system"
ORG_SYSTEM_SIZE = "0"
VERITY_SIZE = "0"
ROOT_HASH = ""
HASH_ALGO = "sha256"
MAPPER_DEVICE = "verity"
UPSTREAM_VERITY_VERSION = "1"
DATA_BLOCK_START = "0"
DM_KEY_PREFIX = '"'
DATA_BLOCKS_NUMBER ?= ""
SIZE_IN_SECTORS = ""
FEC_OFFSET = "0"
FEC_SIZE = "0"
METADATA_TREE_SIZE = "0"
NAND_IGNORE = "1"
NAND_IGNORE_qti-distro-base-user = "0"
FEC_SUPPORT = "1"
DEPENDS += " ${@bb.utils.contains('FEC_SUPPORT', '1', 'fec-native', '', d)}"
SQSH_FS = "${@bb.utils.contains('IMAGE_FSTYPES', 'squashfs', '1', '0', d)}"

VERITY_IMAGES        ?= "${SYSTEMIMAGE_TARGET}"
VERITY_SYSTEM_DIR    = "${IMGDEPLOYDIR}/${IMAGE_BASENAME}"
VERITY_IMAGE_EXT4_DIR = "${VERITY_SYSTEM_DIR}/verity"
VERITY_IMAGE_SQSH_DIR = "${VERITY_SYSTEM_DIR}/${FS_TYPE_SQSH}/verity_sqsh"
VERITY_IMG           = "verity.img"
VERITY_METADATA_IMG  = "verity-metadata.img"
VERITY_FEC_IMG       = "verity-fec.img"
VERITY_CMDLINE       = "cmdline"

def adjust_system_size_for_verity_image(d, size, sqsh):
    partition_size = size
    block_size = int(d.getVar("BLOCK_SIZE",True))
    fec_support = d.getVar("FEC_SUPPORT",True)
    squash_support = sqsh
    hi = partition_size
    if hi % block_size != 0:
        hi = (hi // block_size) * block_size
    verity_size = get_verity_size(d, hi, fec_support)
    if squash_support is "1" :
        partition_size = partition_size + verity_size
    lo = partition_size - verity_size
    result = lo
    while lo < hi:
        i = ((lo + hi) // (2 * block_size)) * block_size
        v = get_verity_size(d, i, fec_support)
        if i + v <= partition_size:
            if result < i:
                result = i
                verity_size = v
            lo = i + block_size
        else:
            hi = i
    data_blocks_number = (result // block_size)
    fec_size = int(d.getVar("FEC_SIZE",True))
    size_in_sectors = data_blocks_number * 8
    if fec_size !=0:
        fec_off = (partition_size - fec_size) // block_size
    else:
        fec_off = 0

    d.setVar('SIZE_IN_SECTORS', str(size_in_sectors))
    d.setVar('DATA_BLOCKS_NUMBER', str(data_blocks_number))
    d.setVar('SYSTEM_IMAGE_ROOTFS_SIZE', str(result))
    d.setVar('VERITY_SIZE', str(verity_size))
    d.setVar('ORG_SYSTEM_SIZE', str(partition_size))
    d.setVar('FEC_OFFSET', str(fec_off))

    bb.debug(1, "Data Blocks Number: %s" % d.getVar('DATA_BLOCKS_NUMBER', True))
    bb.debug(1, "FEC Offset: %s" % d.getVar("FEC_OFFSET",True))
    bb.debug(1, "system image size without verity: %s" % d.getVar("ORG_SYSTEM_SIZE"))
    bb.debug(1, "verity size: %s" % d.getVar("VERITY_SIZE",True))
    bb.debug(1, "system image size with verity: %s" % d.getVar("SYSTEM_IMAGE_ROOTFS_SIZE"))
    bb.note("System image size is adjusted with verity")

def adjust_system_size_for_squashfs_verity(d, img, sqsh):
    import subprocess
    sparse_img = img
    system_image_size = int(subprocess.check_output("du -bs %s | awk '{print $1}'" % (sparse_img),shell=True))
    adjust_system_size_for_verity_image(d, system_image_size, sqsh)

python adjust_system_size_for_verity () {

    partition_size = int(d.getVar("SYSTEM_IMAGE_ROOTFS_SIZE", True))
    adjust_system_size_for_verity_image(d, partition_size, '0')
}

def get_verity_size(d, partition_size, fec_support):
    import subprocess
    # Get verity tree size
    bvt_bin_path = d.getVar('STAGING_BINDIR_NATIVE', True) + '/build_verity_tree'
    cmd = bvt_bin_path + " -s %s " % partition_size
    try:
        verity_tree_size =  int(subprocess.check_output(cmd, stderr=subprocess.STDOUT, shell=True).strip())
    except subprocess.CalledProcessError as e:
        bb.debug(1, "cmd: %s" % (cmd))
        bb.fatal("Error in calculating verity tree size: %s\n%s" % (e.returncode, e.output.decode("utf-8")))

    d.setVar('METADATA_TREE_SIZE', str(verity_tree_size))

    # Get verity metadata size
    bvmd_script_path = d.getVar('STAGING_BINDIR_NATIVE', True) + '/build_verity_metadata.py'
    cmd = bvmd_script_path + " size %s " % partition_size
    try:
        verity_metadata_size = int(subprocess.check_output(cmd, stderr=subprocess.STDOUT, shell=True).strip())
    except subprocess.CalledProcessError as e:
        bb.debug(1, "cmd: %s" % (cmd))
        bb.fatal("Error in calculating verity metadata size: %s\n%s" % (e.returncode, e.output.decode("utf-8")))

    verity_size = verity_tree_size + verity_metadata_size

    # Get fec size
    if fec_support is "1":
        fec_bin_path = d.getVar('STAGING_BINDIR_NATIVE', True) + '/fec'
        cmd = fec_bin_path + " -s %s " % (partition_size + verity_size)
        try:
            fec_size =  int(subprocess.check_output(cmd, stderr=subprocess.STDOUT, shell=True).strip())
        except subprocess.CalledProcessError as e:
            bb.debug(1, "cmd: %s" % (cmd))
            bb.fatal("Error in calculating fec size: %s\n%s" % (e.returncode, e.output.decode("utf-8")))
        d.setVar('FEC_SIZE', str(fec_size))
        return verity_size + fec_size
    return verity_size

make_verity_enabled_system_image[cleandirs] += " ${VERITY_IMAGE_EXT4_DIR}"
make_verity_enabled_system_image[cleandirs] += " ${VERITY_IMAGE_SQSH_DIR}"

def make_one_verity_enabled_system_image(d, img, sqsh):
    import subprocess
    import shutil

    squash_support =  sqsh
    if squash_support is '1':
        original_sparse = os.path.join(d.getVar('VERITY_SYSTEM_DIR', True), d.getVar('FS_TYPE_SQSH', True), img)
        sparse_img =  os.path.join(d.getVar('VERITY_IMAGE_SQSH_DIR', True), img, img)
        verity_img = os.path.join(d.getVar('VERITY_IMAGE_SQSH_DIR', True), img, d.getVar('VERITY_IMG', True))
        verity_md_img = os.path.join(d.getVar('VERITY_IMAGE_SQSH_DIR', True), img, d.getVar('VERITY_METADATA_IMG', True))
        adjust_system_size_for_squashfs_verity(d, original_sparse, sqsh)
    else:
        original_sparse = os.path.join(d.getVar('VERITY_SYSTEM_DIR', True), img)
        sparse_img = os.path.join(d.getVar('VERITY_IMAGE_EXT4_DIR', True), img, img)
        verity_img = os.path.join(d.getVar('VERITY_IMAGE_EXT4_DIR', True), img, d.getVar('VERITY_IMG', True))
        verity_md_img = os.path.join(d.getVar('VERITY_IMAGE_EXT4_DIR', True), img, d.getVar('VERITY_METADATA_IMG', True))
    signer_path = d.getVar('STAGING_BINDIR_NATIVE',True) + "/verity_signer"
    signer_key  = d.getVar('STAGING_BINDIR_NATIVE',True) + "/verity.pk8"
    is_legacy_dm_verity_driver = d.getVar('LEGACY_DM_ANDROID_VERITY_DRIVER',True)

    # Copy the built system image into the verity subdirectory for this image
    if squash_support is '1':
        os.makedirs(os.path.join(d.getVar('VERITY_IMAGE_SQSH_DIR', True), img))
        shutil.copy(original_sparse, sparse_img)
    else:
        os.makedirs(os.path.join(d.getVar('VERITY_IMAGE_EXT4_DIR', True), img))
        shutil.copy(original_sparse, sparse_img)
    # Build verity tree
    bvt_bin_path = d.getVar('STAGING_BINDIR_NATIVE', True) + '/build_verity_tree'
    cmd = bvt_bin_path + " -A %s %s %s " % (d.getVar("FIXED_SALT",True), sparse_img, verity_img)
    try:
        [root_hash, salt] = (subprocess.check_output(cmd, stderr=subprocess.STDOUT, shell=True)).split()
    except subprocess.CalledProcessError as e:
        bb.debug(1, "cmd %s" % (cmd))
        bb.fatal("Error in building verity tree : %s\n%s" % (e.returncode, e.output.decode("utf-8")))
    d.setVar('ROOT_HASH', root_hash.decode('UTF-8'))
    d.setVar('FIXED_SALT_STR', salt.decode('UTF-8'))
    bb.debug(1, "Value of root hash is %s" % root_hash)
    bb.debug(1, "Value of salt is %s" % salt)

    # Build verity metadata
    blk_dev = d.getVar("BLOCK_DEVICE_SYSTEM", True)
    image_size = int(d.getVar('SYSTEM_IMAGE_ROOTFS_SIZE'))
    bvmd_script_path = d.getVar('STAGING_BINDIR_NATIVE', True) + '/build_verity_metadata.py'
    cmd = bvmd_script_path + " build %s %s %s %s %s %s %s " % (image_size, verity_md_img, str(d.getVar('ROOT_HASH', True)), str(d.getVar('FIXED_SALT_STR', True)), blk_dev, signer_path, signer_key)
    ret = subprocess.call(cmd, shell=True)
    if ret != 0:
        bb.error("Running: %s failed." % cmd)

    # Append verity metadata to verity image.
    if is_legacy_dm_verity_driver is "1":
        bb.debug(1, "appending verity_md_img to verity_img .... ")
        with open(verity_img, "ab") as out_file:
            with open(verity_md_img, "rb") as input_file:
                for line in input_file:
                    out_file.write(line)
    else:
        bb.debug(1, "appending verity_img to verity_md_img .... ")
        with open(verity_md_img, "ab") as out_file:
            with open(verity_img, "rb") as input_file:
                for line in input_file:
                    out_file.write(line)

    # Calculate padding.
    partition_size = int(d.getVar("ORG_SYSTEM_SIZE",True))
    img_size = int(d.getVar('SYSTEM_IMAGE_ROOTFS_SIZE'))
    verity_size = int(d.getVar("VERITY_SIZE",True))
    padding_size = partition_size - img_size - verity_size
    bb.debug(1, "padding_size(%s) = %s - %s - %s" %(padding_size, partition_size, img_size, verity_size))
    assert padding_size >= 0

    fec_supported=d.getVar("FEC_SUPPORT",True)
    if fec_supported is "1":
        fec_bin_path = d.getVar('STAGING_BINDIR_NATIVE', True) + '/fec'
        if squash_support is '1':
            fec_img_path = os.path.join(d.getVar('VERITY_IMAGE_SQSH_DIR', True), img, d.getVar('VERITY_FEC_IMG', True))
        else:
            fec_img_path = os.path.join(d.getVar('VERITY_IMAGE_EXT4_DIR', True), img, d.getVar('VERITY_FEC_IMG', True))
        if is_legacy_dm_verity_driver is "1":
            cmd = fec_bin_path + " -e -p %s %s %s %s" % (padding_size, sparse_img, verity_img, fec_img_path)
            ret = subprocess.call(cmd, shell=True)
            if ret != 0:
                bb.error("Running: %s failed." % cmd)

            bb.debug(1, "appending fec_img_path to verity_img.... ")
            with open(verity_img, "ab") as out_file:
                with open(fec_img_path, "rb") as input_file:
                    for line in input_file:
                        out_file.write(line)
        else:
            cmd = fec_bin_path + " -e -p %s %s %s %s" % (padding_size, sparse_img, verity_md_img, fec_img_path)
            ret = subprocess.call(cmd, shell=True)
            if ret != 0:
                bb.error("Running: %s failed." % cmd)

            bb.debug(1, "appending fec_img_path to verity_md_img.... ")
            with open(verity_md_img, "ab") as out_file:
                with open(fec_img_path, "rb") as input_file:
                    for line in input_file:
                        out_file.write(line)

    # Almost done. Append verity img to system img.
    if(os.path.basename(img) != d.getVar('SYSTEMIMAGE_GLUEBI_TARGET', True)) and ((squash_support is "0")):
        #append2simg_path = d.getVar('STAGING_BINDIR_NATIVE', True) + '/squashfs2sparse'
        append2simg_path = d.getVar('STAGING_BINDIR_NATIVE', True) + '/append2simg'
        if is_legacy_dm_verity_driver is "1":
            cmd = append2simg_path + " %s %s " % (sparse_img, verity_img)
        else:
            cmd = append2simg_path + " %s %s " % (sparse_img, verity_md_img)
        ret = subprocess.call(cmd, shell=True)
        if ret != 0:
            bb.error("Running: %s failed." % cmd)
    else:
        # Append to non-sparse system image
        bb.debug(1,"NonSparse image")
        with open(verity_md_img, "rb") as input_file:
            with open(sparse_img, "ab") as out_file:
                for line in input_file:
                    out_file.write(line)

    #system image is ready. Update verity cmdline.
    if is_legacy_dm_verity_driver is "1":
        #cmdline = d.getVar('KERNEL_CMD_PARAMS', True)
        cmdline = " androidboot.veritymode=enforcing veritykeyid=id:"
        verity_x509_pem  = d.getVar('STAGING_BINDIR_NATIVE',True) + "/verity.x509.pem"
        bb.debug(1, "verity_x509_pem is %s " % (verity_x509_pem))
        # add "buildvariant=userdebug" for non-user builds.
        # cmdline += " ${@["buildvariant=userdebug", ""][(d.getVar('VARIANT', True) == 'user')]}"
        # generate and add verity key id.
        keycmd = "openssl x509 -in " + verity_x509_pem + " -text \
            | grep keyid | sed 's/://g' | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]' | sed 's/keyid//g'"
        keyid = subprocess.check_output(keycmd, shell=True).strip()
        # cmdline += " veritykeyid=id:" + keyid
        cmdline += keyid.decode()
        cmdline += " veritymd=" + d.getVar('METADATA_TREE_SIZE', True) + "e"
    else:
        dm_prefix = d.getVar('DM_KEY_PREFIX', True)
        dm_key_args_list = []
        dm_key_args_list.append( d.getVar('SIZE_IN_SECTORS', True))
        dm_key_args_list.append( d.getVar('DATA_BLOCKS_NUMBER', True))
        dm_key_args_list.append( str(d.getVar('ROOT_HASH', True)))
        dm_key_args_list.append( d.getVar('FEC_OFFSET', True))
        dm_key_args_list.append( d.getVar('NAND_IGNORE', True))
        dm_key =  dm_prefix + " ".join(dm_key_args_list)+ " " +'\\"'
        cmdline = "verity=\\" + dm_key

    bb.debug(1, "Verity Command line is set to %s " % (cmdline))

    # Write cmdline to a tmp file
    if squash_support is '1':
        verity_cmd = os.path.join(d.getVar('VERITY_IMAGE_SQSH_DIR', True), img, d.getVar('VERITY_CMDLINE', True))
    else:
        verity_cmd = os.path.join(d.getVar('VERITY_IMAGE_EXT4_DIR', True), img, d.getVar('VERITY_CMDLINE', True))
    bb.debug(1, str(subprocess.check_output("echo '%s' > %s" % (cmdline, verity_cmd), stderr=subprocess.STDOUT, shell=True)))

python do_make_verity_enabled_system_image () {
    import shutil
    squash_support= d.getVar("SQSH_FS", True)

    images_ext4 = d.getVar('VERITY_IMAGES', True).split()
    for img in images_ext4:
        img_path = os.path.join(d.getVar('VERITY_SYSTEM_DIR', True), img)
        if os.path.exists(img_path):
            make_one_verity_enabled_system_image(d, img,'0')
            # Copy default system image to original location
            if img == d.getVar('SYSTEMIMAGE_TARGET', True):
                shutil.copy(os.path.join(d.getVar('VERITY_IMAGE_EXT4_DIR', True), img, img), img_path)
        else:
            bb.warn(img_path + ' does not exist')

    if squash_support is "1":
        images_sq = d.getVar('VERITY_IMAGES', True).split()
        for img in images_sq:
            img_path = os.path.join(d.getVar('VERITY_SYSTEM_DIR', True), d.getVar('FS_TYPE_SQSH', True), img)
            if os.path.exists(img_path):
                make_one_verity_enabled_system_image(d, img, '1')
                # Copy default system image to original location
                if img == d.getVar('SYSTEMIMAGE_TARGET', True):
                    shutil.copy(os.path.join(d.getVar('VERITY_SYSTEM_DIR', True), d.getVar('FS_TYPE_SQSH', True), d.getVar('VERITY_IMAGE_SQSH_DIR', True), img, img), img_path)
            else:
                bb.warn(img_path + ' does not exist')
}

do_make_verity_enabled_system_image[prefuncs] += "adjust_system_size_for_verity"
do_make_verity_enabled_system_image[depends] += "${@bb.utils.contains('IMAGE_FSTYPES', 'squashfs', '${PN}:do_makesystem_sqsh', '', d)}"
do_make_verity_enabled_system_image[depends] += "${@bb.utils.contains('IMAGE_FSTYPES', 'ext4', '${PN}:do_makesystem', '', d)}"
do_make_verity_enabled_system_image[depends]  += "${@bb.utils.contains('IMAGE_FEATURES', 'gluebi', '${PN}:do_makesystem_gluebi', '', d)}"
do_make_verity_enabled_system_image[dirs]     = "${IMGDEPLOYDIR}/${IMAGE_BASENAME}"
do_make_verity_enabled_system_image[dirs]     = "${@bb.utils.contains('IMAGE_FSTYPES', 'squashfs', '${IMGDEPLOYDIR}/${IMAGE_BASENAME}/${FS_TYPE_SQSH}', '', d)}"
do_make_verity_enabled_system_image[depends] += "virtual/kernel:do_deploy"
addtask make_verity_enabled_system_image before do_image_complete after do_image

def get_verity_cmdline(d, img, sqsh):
    import subprocess
    squash_support= sqsh
    # Get verity cmdline from tmp file
    if squash_support is '1':
        verity_cmd = os.path.join(d.getVar('VERITY_IMAGE_SQSH_DIR', True), img, d.getVar('VERITY_CMDLINE', True))
    else:
        verity_cmd = os.path.join(d.getVar('VERITY_IMAGE_EXT4_DIR', True), img, d.getVar('VERITY_CMDLINE', True))
    output = subprocess.check_output("grep -m 1 verity %s" % (verity_cmd), shell=True)
    return output.decode('UTF-8')

# With dm-verity, kernel cmdline has to be updated with correct hash value of
# system image. This means final boot image can be created only after system image.
# do_makeboot task from this class builds boot.img with verity after system image is
# generated. do_makeboot in dm-verity-none.bbclass can build boot.img without verity
# Include appropraite dm-verity bbclass.
BOOTIMGDEPLOYDIR = "${WORKDIR}/deploy-${PN}-bootimage-complete"

def do_make_one_veritybootimg(d, img, sqsh):
    import subprocess
    squash_support= sqsh

    xtra_parms=""
    if bb.utils.contains('MACHINE_FEATURES', 'nand-boot', True, False, d):
        xtra_parms = " --tags-addr" + " " + d.getVar('KERNEL_TAGS_OFFSET')

    verity_cmdline = ""
    verity_cmdline = get_verity_cmdline(d, img, sqsh).strip()

    mkboot_bin_path = d.getVar('STAGING_BINDIR_NATIVE', True) + '/mkbootimg'
    zimg_path       = d.getVar('DEPLOY_DIR_IMAGE', True) + "/" + d.getVar('KERNEL_IMAGETYPE', True)
    cmdline         = "\"" + d.getVar('KERNEL_CMD_PARAMS', True) + " " + verity_cmdline + "\""
    pagesize        = d.getVar('PAGE_SIZE', True)
    base            = d.getVar('KERNEL_BASE', True)
    if squash_support is "1":
        output          = os.path.join(d.getVar('VERITY_IMAGE_SQSH_DIR', True), img, d.getVar('BOOTIMAGE_TARGET'))
    else:
        output          = os.path.join(d.getVar('VERITY_IMAGE_EXT4_DIR', True), img, d.getVar('BOOTIMAGE_TARGET'))
    # cmd to make boot.img
    cmd =  mkboot_bin_path + " --kernel %s --cmdline %s --pagesize %s --base %s %s --ramdisk /dev/null --ramdisk_offset 0x0 --output %s" \
           % (zimg_path, cmdline, pagesize, base, xtra_parms, output )

    bb.debug(1, "dm-verity-bootloader do_makeboot cmd: %s" % (cmd))
    try:
        ret = subprocess.check_output(cmd, shell=True)
    except RuntimeError as e:
        bb.error("dm-verity-bootloader cmd: %s failed with error %s" % (cmd, str(e)))

python do_makeboot () {
    import shutil
    squash_support= d.getVar("SQSH_FS",True)

    images_ext4 = d.getVar('VERITY_IMAGES', True).split()
    for img in images_ext4:
        img_path = os.path.join(d.getVar('VERITY_SYSTEM_DIR', True), img)
        if os.path.exists(img_path):
            verity_path = os.path.join(d.getVar('VERITY_IMAGE_EXT4_DIR', True), img, d.getVar('BOOTIMAGE_TARGET'))
            shutil.copy(img_path, verity_path)
            do_make_one_veritybootimg(d, img,'0')
            # Copy boot image for default system image to original location
            if img == d.getVar('SYSTEMIMAGE_TARGET', d):
                shutil.copy(verity_path, os.path.join(d.getVar('BOOTIMGDEPLOYDIR'), d.getVar('IMAGE_BASENAME'), d.getVar('BOOTIMAGE_TARGET')))
        else:
            bb.warn(img_path + " does not exist")

    if squash_support is "1":
        images_sq = d.getVar('VERITY_IMAGES', True).split()
        for img in images_sq:
            img_path = os.path.join(d.getVar('VERITY_SYSTEM_DIR', True), d.getVar('FS_TYPE_SQSH', True),  img)
            if os.path.exists(img_path):
                verity_path = os.path.join(d.getVar('VERITY_SYSTEM_DIR', True),  d.getVar('FS_TYPE_SQSH', True), d.getVar('VERITY_IMAGE_SQSH_DIR', True), img, d.getVar('BOOTIMAGE_TARGET'))
                shutil.copy(img_path, verity_path)
                do_make_one_veritybootimg(d, img, '1')

                # Copy boot image for default system image to original location
                if img == d.getVar('SYSTEMIMAGE_TARGET', d):
                    img_path = os.path.join(d.getVar('VERITY_SYSTEM_DIR', True),  d.getVar('FS_TYPE_SQSH', True), d.getVar('BOOTIMAGE_TARGET'))
                    shutil.copy(verity_path, img_path)
            else:
                bb.warn(img_path + " does not exist")
}
do_makeboot[dirs]      = "${BOOTIMGDEPLOYDIR}/${IMAGE_BASENAME}"
# Make sure native tools and vmlinux ready to create boot.img
do_makeboot[depends] += "virtual/kernel:do_deploy mkbootimg-native:do_populate_sysroot"
do_makeboot[depends]  += "${PN}:do_make_verity_enabled_system_image"
do_makeboot[depends]  += "${PN}:do_makeuserdata"
SSTATETASKS += "do_makeboot"
SSTATE_SKIP_CREATION_task-make-veritybootimg = '1'
do_makeboot[sstate-inputdirs] = "${BOOTIMGDEPLOYDIR}"
do_makeboot[sstate-outputdirs] = "${DEPLOY_DIR_IMAGE}"
do_makeboot[stamp-extra-info] = "${MACHINE_ARCH}"

python do_makeboot_setscene () {
    sstate_setscene(d)
}
addtask do_makeboot_setscene

addtask do_makeboot before do_image_complete
