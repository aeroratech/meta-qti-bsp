LICENSE = "BSD-3-Clause-Clear"

DEPENDS += "ext4-utils-native"

# Add list of VMs to pack together
VM_IMAGES = "televm"

# Update the combined EXT4 size for each VM here
VM_COMBINED_SIZE_EXT4 = "270000000"

VM = ""
VMBOOTSYS_DEPLOY_DIR="${DEPLOY_DIR_IMAGE}/../${BASEMACHINE}-vmbootsys"

do_setup_deploy_dir() {
    mkdir -p ${VMBOOTSYS_DEPLOY_DIR}/vm-images
    cp -R ${DEPLOY_DIR_IMAGE}/vmimage.fc ${VMBOOTSYS_DEPLOY_DIR}/
}
do_setup_deploy_dir[cleandirs] = "${VMBOOTSYS_DEPLOY_DIR}"

do_copy_vmimages() {
    echo ${VM}
    cp -R ${DEPLOY_DIR_IMAGE}/../${BASEMACHINE}-${VM}/vm-images/* ${VMBOOTSYS_DEPLOY_DIR}/vm-images/
}

python do_setup_package() {
    bb.build.exec_func("do_setup_deploy_dir", d)

    for i in bb.utils.explode_deps(d.getVar('VM_IMAGES') or ""):
        d.setVar("VM", i)
        bb.build.exec_func("do_copy_vmimages", d)
}

do_package[prefuncs] = 'do_setup_package'
do_package[nostamp] = "1"
do_package() {
    make_ext4fs -s -a / -b 4096 -l ${VM_COMBINED_SIZE_EXT4} \
               -S ${VMBOOTSYS_DEPLOY_DIR}/vmimage.fc \
               ${VMBOOTSYS_DEPLOY_DIR}/${VMIMAGE_TARGET} \
               ${VMBOOTSYS_DEPLOY_DIR}/vm-images/
}
