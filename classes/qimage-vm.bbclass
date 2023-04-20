# Copyright (c) 2023 Qualcomm Innovation Center, Inc. All rights reserved.
# SPDX-License-Identifier: BSD-3-Clause-Clear

IMAGE_FEATURES[validitems] += "vm"
IMAGE_FEATURES += "vm"

do_gen_partition_bin[noexec] = "1"
do_compose_vmimage[recrdeptask] = "do_ramdisk_create"

DEPENDS += "ext4-utils-native mtd-utils-native"

# Add list of VMs to pack together
VM_IMAGES ?= "televm fotavm"

VMBOOTSYS_DEPLOY_DIR ?= "${DEPLOY_DIR}/images/${BASEMACHINE}-vmbootsys"
VMPACKIMAGE_UBI_TARGET ?= "${VMBOOTSYS_DEPLOY_DIR}/vm-bootsys.ubi"
VMPACKIMAGE_UBIFS_TARGET ?= "${VMBOOTSYS_DEPLOY_DIR}/vm-bootsys.ubifs"
VMPACKIMAGE_ROOTFS ?= "${VMBOOTSYS_DEPLOY_DIR}/vm-images/"
UBINIZE_VMPACK_CFG ?= "${VMBOOTSYS_DEPLOY_DIR}/ubinize_vm.cfg"

# Size of the combined EXT4 image
VM_COMBINED_SIZE_EXT4 ?= "314572800"

do_copy_vmimages[dirs] = "${VMBOOTSYS_DEPLOY_DIR} ${VMBOOTSYS_DEPLOY_DIR}/vm-images/"
do_copy_vmimages() {
     if [ -d "${DEPLOY_DIR}/images/${BASEMACHINE}-${VM}/vm-images/" ]; then
        cp -R ${DEPLOY_DIR}/images/${BASEMACHINE}-${VM}/vm-images/* ${VMBOOTSYS_DEPLOY_DIR}/vm-images/
     else
        echo "${DEPLOY_DIR}/images/${BASEMACHINE}-${VM} does not exist."
     fi
}

do_setup_package[cleandirs] = "${VMBOOTSYS_DEPLOY_DIR}"
python do_setup_package() {
    for vm in bb.utils.explode_deps(d.getVar('VM_IMAGES') or ""):
        d.setVar("VM", vm)
        bb.build.exec_func("do_copy_vmimages", d)
}

do_create_ubinize_vmpack_config[dirs] = "${VMBOOTSYS_DEPLOY_DIR}"
do_create_ubinize_vmpack_config() {
    cat << EOF > ${UBINIZE_VMPACK_CFG}
[vm_volume]
mode=ubi
image="${VMPACKIMAGE_UBIFS_TARGET}"
vol_id=0
vol_type=dynamic
vol_name=vm
vol_flags=autoresize
EOF
}

do_pack_vm_images[nostamp] = "1"
do_pack_vm_images[prefuncs] += 'do_setup_package'
do_pack_vm_images[prefuncs] += "${@bb.utils.contains('IMAGE_FSTYPES', 'ubi', 'do_create_ubinize_vmpack_config', '', d)}"
do_pack_vm_images[postfuncs] += "${@bb.utils.contains('INHERIT', 'uninative', 'do_patch_ubitools', '', d)}"
do_verity_ubinize[depends] += "${PN}:do_make_vmbootsys_ubi"

do_pack_vm_images() {
    # copy file_contexts file to deploy dir
    cp -R ${DEPLOY_DIR_IMAGE}/vmimage.fc ${VMBOOTSYS_DEPLOY_DIR}/

    if ${@bb.utils.contains('IMAGE_FSTYPES','ext4', 'true', 'false', d)}; then
        make_ext4fs -s -a / -b 4096 -l ${VM_COMBINED_SIZE_EXT4} \
                   -S ${VMBOOTSYS_DEPLOY_DIR}/vmimage.fc \
                   ${VMBOOTSYS_DEPLOY_DIR}/${VMIMAGE_TARGET} \
                   ${VMBOOTSYS_DEPLOY_DIR}/vm-images/
    fi

    if ${@bb.utils.contains('IMAGE_FSTYPES','ubi', 'true', 'false', d)}; then
        mkfs.ubifs -r ${VMPACKIMAGE_ROOTFS} ${IMAGE_UBIFS_SELINUX_OPTIONS} \
                   -o ${VMPACKIMAGE_UBIFS_TARGET} ${MKUBIFS_ARGS}
        ubinize -o ${VMPACKIMAGE_UBI_TARGET} ${UBINIZE_ARGS} ${UBINIZE_VMPACK_CFG}
    fi
}

addtask do_pack_vm_images after do_makeandsign_vmimage before do_image_complete
