inherit core-image

inherit mdm-ota-target-image-ext4

CORE_IMAGE_EXTRA_INSTALL += "${@bb.utils.contains('COMBINED_FEATURES', 'qti-ab-boot', ' recovery-ab', '', d)}"

# Only when verity feature is enabled, start including related tasks.
VERITY_PROVIDER ?= "${@bb.utils.contains('DISTRO_FEATURES', 'dm-verity', 'dm-verity', '', d)}"
inherit ${VERITY_PROVIDER}

# The work directory for image recipes is retained as the 'rootfs' directory
# can be used as sysroot during remote gdb debgging
RM_WORK_EXCLUDE += "${PN}"

# generate a companion debug archive containing symbols from the -dbg packages
IMAGE_GEN_DEBUGFS = "1"
IMAGE_FSTYPES_DEBUGFS = "tar.bz2"

do_image_ext4[noexec] = "1"

### Don't append timestamp to image name
IMAGE_VERSION_SUFFIX = ""

# Default Image names
BOOTIMAGE_TARGET ?= "boot.img"
SYSTEMIMAGE_TARGET ?= "system.img"
SYSTEMIMAGE_MAP_TARGET ?= "system.map"
USERDATAIMAGE_TARGET ?= "userdata.img"
USERDATAIMAGE_MAP_TARGET ?= "userdata.map"
PERSISTIMAGE_TARGET ?= "persist.img"
PERSISTIMAGE_MAP_TARGET ?= "persist.map"

#Set appropriate partion:Image map
NONAB_BOOT_PARTITION_IMAGE_MAP = "boot='${BOOTIMAGE_TARGET}',system='${SYSTEMIMAGE_TARGET}',userdata='${USERDATAIMAGE_TARGET}',persist='${PERSISTIMAGE_TARGET}'"
AB_BOOT_PARTITION_IMAGE_MAP = "boot_a='${BOOTIMAGE_TARGET}',boot_b='${BOOTIMAGE_TARGET}',system_a='${SYSTEMIMAGE_TARGET}',system_b='${SYSTEMIMAGE_TARGET}',userdata='${USERDATAIMAGE_TARGET}',persist='${PERSISTIMAGE_TARGET}'"

def set_partition_image_map(d):
    if "qti-ab-boot" in d.getVar('COMBINED_FEATURES', True):
        return d.getVar('AB_BOOT_PARTITION_IMAGE_MAP', True)
    else:
        return d.getVar('NONAB_BOOT_PARTITION_IMAGE_MAP', True)

PARTITION_IMAGE_MAP = "${@set_partition_image_map(d)}"



IMAGE_EXT4_SELINUX_OPTIONS = "${@bb.utils.contains('DISTRO_FEATURES', 'selinux', '-S ${SELINUX_FILE_CONTEXTS}', '', d)}"
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

addtask do_gen_partition_bin after do_rootfs before do_image


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

ROOTFS_POSTPROCESS_COMMAND += "gen_buildprop;do_fsconfig;"
ROOTFS_POSTPROCESS_COMMAND += "gen_overlayfs;"

gen_buildprop() {
   mkdir -p ${IMAGE_ROOTFS}/cache
   echo ro.build.version.release=`cat ${IMAGE_ROOTFS}/etc/version ` >> ${IMAGE_ROOTFS}/build.prop
   echo ro.product.name=${BASEMACHINE}-${DISTRO} >> ${IMAGE_ROOTFS}/build.prop
   echo ${MACHINE} >> ${IMAGE_ROOTFS}/target
}

gen_overlayfs() {
    mkdir -p ${IMAGE_ROOTFS}/overlay
    mkdir -p ${IMAGE_ROOTFS}/overlay/etc
    mkdir -p ${IMAGE_ROOTFS}/overlay/.etc-work
    mkdir -p ${IMAGE_ROOTFS}/overlay/data
    mkdir -p ${IMAGE_ROOTFS}/overlay/.data-work
    mkdir -p ${IMAGE_ROOTFS}/overlay/cache
    mkdir -p ${IMAGE_ROOTFS}/overlay/.cache-work
}

do_fsconfig() {
 chmod go-r ${IMAGE_ROOTFS}/etc/passwd || :
 chmod -R o-rwx ${IMAGE_ROOTFS}/etc/init.d/ || :
}

do_fsconfig_append_qti-distro-user() {
 rm ${IMAGE_ROOTFS}/lib/systemd/system/sys-kernel-debug.mount
}

################################################
### Generate system.img #####
################################################
# Alter system image size if varity is enabled.
do_makesystem[prefuncs]  += " ${@bb.utils.contains('DISTRO_FEATURES', 'dm-verity', 'adjust_system_size_for_verity', '', d)}"
do_makesystem[postfuncs] += " ${@bb.utils.contains('DISTRO_FEATURES', 'dm-verity', 'make_verity_enabled_system_image', '', d)}"
do_makesystem[dirs]       = "${IMGDEPLOYDIR}"
SPARSE_SYSTEMIMAGE_FLAG = "${@bb.utils.contains('IMAGE_FEATURES', 'vm', '', '-s', d)}"

do_makesystem() {
    cp ${THISDIR}/fsconfig/${MACHINE_FSCONFIG_CONF} ${WORKDIR}/rootfs-fsconfig.conf
    # An ugly hack to mitigate a bug in libsparse were random
    # asserts are observed during unsparsing if image size is large.
    # Unsparsing is needed for appending verity metadata to image.
    # Only known workaround is to recreate image if unsparsing fails.
    for count in {1..10}
    do
        make_ext4fs -C ${WORKDIR}/rootfs-fsconfig.conf \
                -B ${IMGDEPLOYDIR}/${IMAGE_BASENAME}/${SYSTEMIMAGE_MAP_TARGET} \
                -a / -b 4096 ${SPARSE_SYSTEMIMAGE_FLAG} \
                -l ${SYSTEM_SIZE_EXT4} \
                ${IMAGE_EXT4_SELINUX_OPTIONS} \
                ${IMGDEPLOYDIR}/${IMAGE_BASENAME}/${SYSTEMIMAGE_TARGET} ${IMAGE_ROOTFS}

        simg2img ${IMGDEPLOYDIR}/${IMAGE_BASENAME}/${SYSTEMIMAGE_TARGET} /dev/null || invalid_image=1

        if [ ${invalid_image:-0} -eq 1 ]; then
            echo "Unsparse image failed.. Recreating image"
            continue
        else
            echo "Sparse image is good to use..."
            break
        fi
    done

}
addtask do_makesystem after do_rootfs before do_image_complete

### Generate userdata.img ###
do_makeuserdata[dirs] = "${IMGDEPLOYDIR}"

do_makeuserdata() {
    make_ext4fs -B ${IMGDEPLOYDIR}/${IMAGE_BASENAME}/${USERDATAIMAGE_MAP_TARGET} \
                -a /data ${IMAGE_EXT4_SELINUX_OPTIONS} \
                -s -b 4096 -l ${USERDATA_SIZE_EXT4} \
                ${IMGDEPLOYDIR}/${IMAGE_BASENAME}/${USERDATAIMAGE_TARGET} \
                ${IMAGE_ROOTFS}/overlay
}

addtask do_makeuserdata after do_rootfs before do_build

################################################
############ Generate persist image ############
################################################
PERSIST_IMAGE_ROOTFS_SIZE ?= "6536668"
do_makepersist[dirs] = "${IMGDEPLOYDIR}"

do_makepersist() {
    make_ext4fs ${PERSISTFS_CONFIG} ${MAKEEXT4_MOUNT_OPT} \
                -B ${IMGDEPLOYDIR}/${IMAGE_BASENAME}/${PERSISTIMAGE_MAP_TARGET} \
                -s -l ${PERSIST_IMAGE_ROOTFS_SIZE} \
                ${IMGDEPLOYDIR}/${IMAGE_BASENAME}/${PERSISTIMAGE_TARGET} \
                ${IMAGE_ROOTFS}/persist

    # Empty the /persist folder so that it doesn't end up
    # in system image as well
    rm -rf ${IMAGE_ROOTFS}/persist/*
}
# It must be before do_makesystem to remove /persist
addtask do_makepersist after do_rootfs before do_makesystem

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

# With dm-verity, kernel cmdline has to be updated with correct hash value of
# system image. This means final boot image can be created only after system image.
# But many a times when only kernel need to be built waiting for full image is
# time consuming. To over come this make_veritybootimg task is added to build boot
# img with verity. Normal do_make_bootimg continue to build boot.img without verity.
python do_make_veritybootimg () {
    import subprocess

    xtra_parms=""
    if bb.utils.contains('DISTRO_FEATURES', 'nand-boot', True, False, d):
        xtra_parms = " --tags-addr" + " " + d.getVar('KERNEL_TAGS_OFFSET')

    verity_cmdline = ""
    if bb.utils.contains('DISTRO_FEATURES', 'dm-verity', True, False, d):
        verity_cmdline = get_verity_cmdline(d).strip()

    mkboot_bin_path = d.getVar('STAGING_BINDIR_NATIVE', True) + '/mkbootimg'
    zimg_path       = d.getVar('DEPLOY_DIR_IMAGE', True) + "/" + d.getVar('KERNEL_IMAGETYPE', True)
    cmdline         = "\"" + d.getVar('KERNEL_CMD_PARAMS', True) + " " + verity_cmdline + "\""
    pagesize        = d.getVar('PAGE_SIZE', True)
    base            = d.getVar('KERNEL_BASE', True)
    output          = d.getVar('BOOTIMAGE_TARGET', True)

    # cmd to make boot.img
    cmd =  mkboot_bin_path + " --kernel %s --cmdline %s --pagesize %s --base %s %s --ramdisk /dev/null --ramdisk_offset 0x0 --output %s" \
           % (zimg_path, cmdline, pagesize, base, xtra_parms, output )

    bb.debug(1, "do_make_veritybootimg cmd: %s" % (cmd))

    ret = subprocess.call(cmd, shell=True)
    if ret != 0:
        bb.error("Running: %s failed." % cmd)
}
do_make_veritybootimg[depends]  += "${PN}:do_makesystem"
do_make_veritybootimg[depends]  += "${PN}:do_makeuserdata"
do_make_veritybootimg[dirs]      = "${IMGDEPLOYDIR}/${IMAGE_BASENAME}"
do_make_veritybootimg[depends] += "virtual/kernel:do_deploy"

python () {
    if bb.utils.contains('DISTRO_FEATURES', 'dm-verity', True, False, d):
        bb.build.addtask('do_make_veritybootimg', 'do_image_complete', 'do_rootfs', d)
}

