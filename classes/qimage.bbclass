QIMGCLASSES = "core-image qimage-utils python3native"
QIMGCLASSES += "${@bb.utils.contains('DISTRO_FEATURES', 'dm-verity', bb.utils.filter('MACHINE_FEATURES', 'dm-verity-bootloader dm-verity-initramfs', d), '', d)}"
QIMGCLASSES += "${@bb.utils.contains('IMAGE_FSTYPES', 'ext4', 'qimage-ext4', '', d)}"
QIMGCLASSES += "${@bb.utils.contains('IMAGE_FSTYPES', 'ubi', 'qimage-ubi', '', d)}"

# Use the following to extend qimage with custom functions like signing
QIMGEXTENSION ?= ""

inherit ${QIMGCLASSES} ${QIMGEXTENSION}

# Sanity check to ensure dm-verity related configurations are valid
python () {
    set_partition_size_in_bytes(d)

    if 'dm-verity' not in d.getVar('DISTRO_FEATURES'):
        return
    machine_features = set(d.getVar('MACHINE_FEATURES').split(' '))
    verity_features = machine_features & set(['dm-verity-none', 'dm-verity-bootloader', 'dm-verity-initramfs'])
    if len(verity_features) == 0:
        bb.fatal("dm-verity in DISTRO_FEATURES but no MACHINE_FEATURES present. Add dm-verity-bootloader or dm-verity-none to MACHINE_FEATURES")
    if len(verity_features) > 1:
        bb.fatal("dm-verity in DISTRO_FEATURES and multiple dm-verity related MACHINE_FEATURES present. Only one may be present")
}

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
DTBOIMAGE_TARGET ?= "dtbo.img"

#Set appropriate partion:Image map
NONAB_BOOT_PARTITION_IMAGE_MAP = "boot='${BOOTIMAGE_TARGET}',system='${SYSTEMIMAGE_TARGET}',userdata='${USERDATAIMAGE_TARGET}',persist='${PERSISTIMAGE_TARGET}',dtbo='${DTBOIMAGE_TARGET}'"
AB_BOOT_PARTITION_IMAGE_MAP = "boot_a='${BOOTIMAGE_TARGET}',boot_b='${BOOTIMAGE_TARGET}',system_a='${SYSTEMIMAGE_TARGET}',system_b='${SYSTEMIMAGE_TARGET}',dtbo_a='${DTBOIMAGE_TARGET}',dtbo_b='${DTBOIMAGE_TARGET}',userdata='${USERDATAIMAGE_TARGET}',persist='${PERSISTIMAGE_TARGET}'"

# Conf with partition entries should be provided to generate partitions artifacts
MACHINE_PARTITION_CONF ??= ""

def set_partition_image_map(d):
    if "qti-ab-boot" in d.getVar('COMBINED_FEATURES', True):
        return d.getVar('AB_BOOT_PARTITION_IMAGE_MAP', True)
    else:
        return d.getVar('NONAB_BOOT_PARTITION_IMAGE_MAP', True)

PARTITION_IMAGE_MAP = "${@set_partition_image_map(d)}"

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
             mtd-utils-native \
             openssl-native \
             pkgconfig-native \
             ptool-native \
             qdl-native \
"

MACHINE_PARTITION_CONF_SEARCH_PATH ?= "${@':'.join('%s/conf/machine/partition' % p for p in '${BBPATH}'.split(':'))}}"
MACHINE_PARTITION_CONF_FULL_PATH = "${@machine_search(d.getVar('MACHINE_PARTITION_CONF'), d.getVar('MACHINE_PARTITION_CONF_SEARCH_PATH')) or ''}"

# generate partitions artifact in an image-specific folder since they include
# image specific data such as file name and parition size
do_gen_partition_bin[dirs] = "${IMGDEPLOYDIR}/${IMAGE_BASENAME}"

do_gen_partition_bin () {
    # Generate partition.xml using gen_partition utility
    $(PYTHON) ${STAGING_BINDIR_NATIVE}/gen_partition.py \
        -i ${MACHINE_PARTITION_CONF_FULL_PATH} \
        -o ${WORKDIR}/partition.xml \
        -m ${PARTITION_IMAGE_MAP}

    install -m 0644 ${WORKDIR}/partition.xml .

    # Call ptool to generate partition bins
    $(PYTHON) ${STAGING_BINDIR_NATIVE}/ptool.py -x partition.xml
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

    # Copy ipa_fws.elf
    if [ -f ${DEPLOY_DIR_IMAGE}/ipa-fws/ipa_fws.elf ]; then
       install -m 0644 ${DEPLOY_DIR_IMAGE}/ipa-fws/ipa_fws.elf .
    fi

    # Copy recovery images
    if [ -f ${DEPLOY_DIR_IMAGE}/recoveryfs.img ]; then
       install -m 0644 ${DEPLOY_DIR_IMAGE}/recoveryfs.img .
    fi
    if [ -f ${DEPLOY_DIR_IMAGE}/recoveryfs.ubi ]; then
       install -m 0644 ${DEPLOY_DIR_IMAGE}/recoveryfs.ubi .
    fi

}
addtask do_deploy_fixup after do_rootfs before do_image

# Make sure we build edk2/lk before do_rootfs
python(){
    def extraimage_getdepends(task):
        deps = ""
        for dep in (d.getVar('EXTRA_IMAGEDEPENDS') or "").split():
            if 'edk2' in dep:
                deps += " %s:%s" % (dep, task)
            elif 'lib64-edk2' in dep:
                deps += " %s:%s" % (dep, task)
            elif 'lk' in dep:
                deps += " %s:%s" % (dep, task)
            elif 'linux-host' in dep:
                deps += " %s:%s" % (dep, task)
        return deps

    d.appendVarFlag('do_rootfs', 'depends', extraimage_getdepends('do_populate_sysroot'))
}

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
BOOTIMGDEPLOYDIR = "${WORKDIR}/deploy-${PN}-bootimage-complete"

INITRAMFS_IMAGE ?= ''
RAMDISK = "${DEPLOY_DIR_IMAGE}/${INITRAMFS_IMAGE}-${MACHINE}.${INITRAMFS_FSTYPES}"
def get_ramdisk_path(d):
    if os.path.exists(d.getVar('RAMDISK')):
        return '%s' %(d.getVar('RAMDISK'))
    return '/dev/null'

RAMDISK_PATH = "${@get_ramdisk_path(d)}"

MKBOOTUTIL = '${@oe.utils.conditional("PREFERRED_PROVIDER_virtual/mkbootimg-native", "mkbootimg-gki-native", "scripts/mkbootimg.py", "mkbootimg", d)}'

python do_make_bootimg () {
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

    # cmd to make boot.img
    cmd =  mkboot_bin_path + " --kernel %s --cmdline %s --pagesize %s --base %s --ramdisk %s --ramdisk_offset 0x0 %s --output %s" \
           % (zimg_path, cmdline, pagesize, base, ramdisk_path, xtra_parms, output )

    bb.debug(1, "do_make_bootimg cmd: %s" % (cmd))

    ret = subprocess.call(cmd, shell=True)
    if ret != 0:
        bb.error("Running: %s failed." % cmd)

}
do_make_bootimg[dirs]      = "${BOOTIMGDEPLOYDIR}/${IMAGE_BASENAME}"
# Make sure native tools and vmlinux ready to create boot.img
do_make_bootimg[depends] += "virtual/kernel:do_deploy virtual/mkbootimg-native:do_populate_sysroot"
SSTATETASKS += "do_make_bootimg"
SSTATE_SKIP_CREATION_task-make-bootimg = '1'
do_make_bootimg[sstate-inputdirs] = "${BOOTIMGDEPLOYDIR}"
do_make_bootimg[sstate-outputdirs] = "${DEPLOY_DIR_IMAGE}"
do_make_bootimg[stamp-extra-info] = "${MACHINE_ARCH}"

python do_make_bootimg_setscene () {
    sstate_setscene(d)
}
addtask do_make_bootimg_setscene

addtask do_make_bootimg before do_image_complete
################################################
############# Generate dtbo.img ################
################################################

MKDTUTIL = '${@oe.utils.conditional("PREFERRED_PROVIDER_virtual/mkdtimg-native", "mkdtimg-gki-native", "mkdtboimg.py", "mkdtimg", d)}'
DTBODEPLOYDIR = "${WORKDIR}/deploy-${PN}-dtboimage-complete"

# Create dtbo.img if DTBO support is enabled
python do_make_dtboimg () {
    import subprocess

    mkdtimg_bin_path = d.getVar('STAGING_BINDIR_NATIVE', True) + "/" + d.getVar('MKDTUTIL')
    dtbodeploydir = d.getVar('DEPLOY_DIR_IMAGE', True) + "/" + "DTOverlays"
    pagesize = d.getVar("PAGE_SIZE")
    output          = d.getVar('DTBOIMAGE_TARGET', True)
    # cmd to make dtbo.img
    cmd = mkdtimg_bin_path + " create "+ output +" --page_size="+ pagesize +" "+ dtbodeploydir + "/*.dtbo"
    bb.debug(1, "do_make_dtboimg cmd: %s" % (cmd))
    ret = subprocess.call(cmd, shell=True)
}

do_make_dtboimg[dirs]      = "${DTBODEPLOYDIR}/${IMAGE_BASENAME}"
# Make sure dtb files ready to create dtbo.img
do_make_dtboimg[depends] += "virtual/kernel:do_deploy virtual/mkdtimg-native:do_populate_sysroot"
SSTATETASKS += "do_make_dtboimg"
SSTATE_SKIP_CREATION_task-make-dtboimg = '1'
do_make_dtboimg[sstate-inputdirs] = "${DTBODEPLOYDIR}"
do_make_dtboimg[sstate-outputdirs] = "${DEPLOY_DIR_IMAGE}"
do_make_dtboimg[stamp-extra-info] = "${MACHINE_ARCH}"

python do_make_dtboimg_setscene () {
    sstate_setscene(d)
}

python () {
    if d.getVar('MACHINE_SUPPORTS_DTBO'):
       bb.build.addtask('do_make_dtboimg', 'do_image', 'do_rootfs', d)
}
