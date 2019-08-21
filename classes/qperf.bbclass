#
# This class copies unsigned external kernel modules into DEPLOY_DIR_IMAGE
# for convenience.
#

python __anonymous() {
    # While building kernel module recipes add a task to
    # copy build artifacts into DEPLOY_DIR for ease of access
    if (bb.data.inherits_class("module", d)):
        bb.build.addtask('do_copy_kernel_module', 'do_module_signing', 'do_install', d)
}

# Copy kernel modules into image specific deploy directory.
do_copy_kernel_module[dirs] = "${DEPLOY_DIR_IMAGE}/kernel_modules/${PN}"
do_copy_kernel_module() {
    cd ${S}
    for mod in *.ko; do
        if [ -f $mod ]; then
            install -m 0644 $mod ${DEPLOY_DIR_IMAGE}/kernel_modules/${PN}
        fi
    done
}
