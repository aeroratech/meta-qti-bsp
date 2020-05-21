QIMGCLASSES = "core-image"
QIMGCLASSES += "${@bb.utils.contains('DISTRO_FEATURES', 'dm-verity', 'dm-verity', '', d)}"
QIMGCLASSES += "${@bb.utils.contains('IMAGE_FSTYPES', 'ext4', 'qimage-ext4', '', d)}"
QIMGCLASSES += "${@bb.utils.contains('IMAGE_FSTYPES', 'ubi', 'qimage-ubi', '', d)}"

inherit ${QIMGCLASSES}

# The work directory for image recipes is retained as the 'rootfs' directory
# can be used as sysroot during remote gdb debgging
RM_WORK_EXCLUDE += "${PN}"

# generate a companion debug archive containing symbols from the -dbg packages
IMAGE_GEN_DEBUGFS = "1"
IMAGE_FSTYPES_DEBUGFS = "tar.bz2"

### Don't append timestamp to image name
IMAGE_VERSION_SUFFIX = ""

# Default Image names
BOOTIMAGE_TARGET ?= "boot.img"

#Set appropriate partion:Image map
NONAB_BOOT_PARTITION_IMAGE_MAP = "boot='${BOOTIMAGE_TARGET}',system='${SYSTEMIMAGE_TARGET}',userdata='${USERDATAIMAGE_TARGET}',persist='${PERSISTIMAGE_TARGET}'"
AB_BOOT_PARTITION_IMAGE_MAP = "boot_a='${BOOTIMAGE_TARGET}',boot_b='${BOOTIMAGE_TARGET}',system_a='${SYSTEMIMAGE_TARGET}',system_b='${SYSTEMIMAGE_TARGET}',userdata='${USERDATAIMAGE_TARGET}',persist='${PERSISTIMAGE_TARGET}'"

# Conf with partition entries should be provided to generate partitions artifacts
MACHINE_PARTITION_CONF ??= ""

def set_partition_image_map(d):
    if "qti-ab-boot" in d.getVar('COMBINED_FEATURES', True):
        return d.getVar('AB_BOOT_PARTITION_IMAGE_MAP', True)
    else:
        return d.getVar('NONAB_BOOT_PARTITION_IMAGE_MAP', True)

PARTITION_IMAGE_MAP = "${@set_partition_image_map(d)}"

#  Function to get most suitable .inc file with list of packages
#  to be installed into root filesystem from layer it is called.
#  Following is the order of priority.
#  P1: <basemachine>/<basemachine>-<distro>-<layerkey>-image.inc
#  P2: <basemachine>/<basemachine>-<layerkey>-image.inc
#  P3: common/common-<layerkey>-image.inc
def get_bblayer_img_inc(layerkey, d):
    distro      = d.getVar('DISTRO', True)
    basemachine = d.getVar('BASEMACHINE', True)

    lkey = ''
    if layerkey != '':
        lkey = layerkey + "-"

    common_inc  = "common-"+ lkey + "image.inc"
    machine_inc = basemachine + "-" + lkey + "image.inc"
    distro_inc  = machine_inc
    if distro != 'base' or '':
        distro_inc = basemachine + "-" + distro +"-" + lkey + "image.inc"

    distro_inc_path  = os.path.join(d.getVar('THISDIR'), basemachine, distro_inc)
    machine_inc_path = os.path.join(d.getVar('THISDIR'), basemachine, machine_inc)
    common_inc_path  = os.path.join(d.getVar('THISDIR'), "common", common_inc)

    if os.path.exists(distro_inc_path):
        img_inc_path = distro_inc_path
    elif os.path.exists(machine_inc_path):
        img_inc_path = machine_inc_path
    else:
        img_inc_path = common_inc_path
    bb.note(" Incuding packages from %s" % (img_inc_path))
    return img_inc_path

IMAGE_INSTALL_ATTEMPTONLY ?= ""
IMAGE_INSTALL_ATTEMPTONLY[type] = "list"

# Original definition is in image.bbclass. Overloading it with internal list of packages
# to ensure dependencies are not messed up in case package is absent.
PACKAGE_INSTALL_ATTEMPTONLY = "${IMAGE_INSTALL_ATTEMPTONLY} ${FEATURE_INSTALL_OPTIONAL}"

IMAGE_LINGUAS = ""

#Exclude packages
PACKAGE_EXCLUDE += "readline"

# Use busybox as login manager
IMAGE_LOGIN_MANAGER = "busybox-static"

DEPENDS += "\
             ext4-utils-native \
             gen-partitions-tool-native \
             mkbootimg-native \
             mtd-utils-native \
             openssl-native \
             pkgconfig-native \
             ptool-native \
             qdl-native \
"

# generate partitions artifact in an image-specific folder since they include
# image specific data such as file name and parition size
do_gen_partition_bin[dirs] = "${IMGDEPLOYDIR}/${IMAGE_BASENAME}"

do_gen_partition_bin () {
    # Generate partition.xml using gen_partition utility
    python ${STAGING_BINDIR_NATIVE}/gen_partition.py \
        -i ${THISDIR}/partition/${MACHINE_PARTITION_CONF} \
        -o ${WORKDIR}/partition.xml \
        -m ${PARTITION_IMAGE_MAP}

    install -m 0644 ${WORKDIR}/partition.xml .

    # Call ptool to generate partition bins
    python ${STAGING_BINDIR_NATIVE}/ptool.py -x partition.xml
}

python () {
    if d.getVar('MACHINE_PARTITION_CONF', True) != "":
        bb.build.addtask('do_gen_partition_bin', 'do_image', 'do_rootfs', d)
}

# all files needed to flash the device must be in DEPLOY_DIR_NAME/IMAGE_BASENAME
# so we need to copy files, which can't be directly installed into this path
# from actual recipes.

do_deploy_fixup[dirs] = "${IMGDEPLOYDIR}/${IMAGE_BASENAME}"
do_deploy_fixup () {
    # copy the bootloader ELF file
    for f in ${EXTRA_IMAGEDEPENDS}; do
        if [ "$f" = "edk2" ] || [ "$f" = "lib64-edk2" ]; then
            install -m 0644 ${DEPLOY_DIR_IMAGE}/abl.elf .
        elif [ "$f" = "lk" ]; then
            install -m 0644 ${DEPLOY_DIR_IMAGE}/*appsboot.mbn .
        fi
    done
    # copy vmlinux, zImage
    install -m 0644 ${DEPLOY_DIR_IMAGE}/vmlinux .
    install -m 0644 ${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGETYPE} .
    # Copy nHLOS bins
    if [ -f ${DEPLOY_DIR_IMAGE}/NHLOS_IMAGES.tar ]; then
       tar -xvf ${DEPLOY_DIR_IMAGE}/NHLOS_IMAGES.tar -C .
    fi
}

addtask do_deploy_fixup after do_rootfs before do_image

# Check and remove empty packages before rootfs creation
do_rootfs[prefuncs] += "rootfs_ignore_packages"
python rootfs_ignore_packages() {
    excl_pkgs = d.getVar("PACKAGE_EXCLUDE", True).split()
    atmt_only_pkgs = d.getVar("PACKAGE_INSTALL_ATTEMPTONLY", True).split()
    inst_atmt_pkgs = d.getVar("IMAGE_INSTALL_ATTEMPTONLY", True).split()

    empty_pkgs = "${TMPDIR}/prebuilt/${MACHINE}/empty_pkgs"
    if (os.path.isfile(empty_pkgs)):
        with open(empty_pkgs) as file:
            ignore_pkgs = file.read().splitlines()
    else:
        ignore_pkgs=""

    for pkg in inst_atmt_pkgs:
        if pkg in ignore_pkgs:
            excl_pkgs.append(pkg)
            atmt_only_pkgs.remove(pkg)
            bb.debug(1, "Adding empty package %s, in %s IMAGE_INSTALL_ATTEMPTONLY to exclude list. (%s) " % (pkg, d.getVar('PN', True), excl_pkgs))

    d.setVar("PACKAGE_EXCLUDE", ' '.join(excl_pkgs))
    d.setVar("PACKAGE_INSTALL_ATTEMPTONLY", ' '.join(atmt_only_pkgs))
}

################################################
############# Generate boot.img ################
################################################
python do_make_bootimg () {
    import subprocess

    xtra_parms=""
    if bb.utils.contains('DISTRO_FEATURES', 'nand-boot', True, False, d):
        xtra_parms = " --tags-addr" + " " + d.getVar('KERNEL_TAGS_OFFSET')

    mkboot_bin_path = d.getVar('STAGING_BINDIR_NATIVE', True) + '/mkbootimg'
    zimg_path       = d.getVar('DEPLOY_DIR_IMAGE', True) + "/" + d.getVar('KERNEL_IMAGETYPE', True)
    cmdline         = "\"" + d.getVar('KERNEL_CMD_PARAMS', True) + "\""
    pagesize        = d.getVar('PAGE_SIZE', True)
    base            = d.getVar('KERNEL_BASE', True)

    # When verity is enabled add '.noverity' suffix to default boot img.
    output          = d.getVar('BOOTIMAGE_TARGET', True)
    if bb.utils.contains('DISTRO_FEATURES', 'dm-verity', True, False, d):
            output += ".noverity"

    # cmd to make boot.img
    cmd =  mkboot_bin_path + " --kernel %s --cmdline %s --pagesize %s --base %s %s --ramdisk /dev/null --ramdisk_offset 0x0 --output %s" \
           % (zimg_path, cmdline, pagesize, base, xtra_parms, output )

    bb.debug(1, "do_make_bootimg cmd: %s" % (cmd))

    ret = subprocess.call(cmd, shell=True)
    if ret != 0:
        bb.error("Running: %s failed." % cmd)

}
do_make_bootimg[dirs]      = "${IMGDEPLOYDIR}/${IMAGE_BASENAME}"
# Make sure native tools and vmlinux ready to create boot.img
do_make_bootimg[depends] += "virtual/kernel:do_deploy"

addtask do_make_bootimg before do_image_complete after do_rootfs
