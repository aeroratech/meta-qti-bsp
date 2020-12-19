#
# This class copies unsigned external kernel modules into DEPLOYDIR
# for convenience.
#

inherit deploy

python __anonymous() {
    # While building kernel module recipes add a task to
    # copy build artifacts into DEPLOY_DIR for ease of access
    if (bb.data.inherits_class("module", d)):
        bb.build.addtask('do_deploy', 'do_module_signing', 'do_install', d)
}

# Copy kernel modules into image specific deploy directory.
do_copy_kernel_module[cleandirs] = "${DEPLOYDIR}/kernel_modules/${PN}"
do_copy_kernel_module() {
    install -d ${DEPLOYDIR}/kernel_modules/${PN}
    cd ${S}
    for mod in *.ko; do
        if [ -f $mod ]; then
            install -m 0644 $mod ${DEPLOYDIR}/kernel_modules/${PN}
        fi
    done
}

do_deploy() {
    do_copy_kernel_module
}
