FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append += " file://media-card.mount"
SRC_URI_append += " file://media-ram.mount"
SRC_URI_append += " file://var-volatile.mount"
SRC_URI_append += "${@bb.utils.contains('MACHINE_MNT_POINTS', '/systemrw', '', 'file://var-cache.mount', d)}"
SRC_URI_append += "${@bb.utils.contains('MACHINE_MNT_POINTS', '/systemrw', '', 'file://var-lib.mount', d)}"
SRC_URI_append += "${@bb.utils.contains('MACHINE_MNT_POINTS', '/systemrw', '', 'file://var-spool.mount', d)}"
SRC_URI_append += " file://proc-bus-usb.mount"
SRC_URI_append += " file://dash.mount"

SRC_URI_append_batcam += " file://pre_hibernate.sh"
SRC_URI_append_batcam += " file://post_hibernate.sh"

# Various mount related files assume selinux support by default.
# Explicitly remove sepolicy entries when selinux is not present.
fix_sepolicies () {
    sed -i "s#,rootcontext=system_u:object_r:var_t:s0##g"  ${WORKDIR}/var-volatile.mount
}
do_install[prefuncs] += " ${@bb.utils.contains('DISTRO_FEATURES', 'selinux', '', 'fix_sepolicies', d)}"

# Install var-volatile.mount for tmpfs
do_install_append () {
    install -d 0644 ${D}${systemd_unitdir}/system
    install -d 0644 ${D}${systemd_unitdir}/system/local-fs.target.wants
    install -m 0644 ${WORKDIR}/var-volatile.mount \
            ${D}${systemd_unitdir}/system/var-volatile.mount
    if ${@bb.utils.contains('MACHINE_MNT_POINTS', '/systemrw', 'false', 'true', d)}; then
        install -m 0644 ${WORKDIR}/var-cache.mount \
                ${D}${systemd_unitdir}/system/var-cache.mount
        install -m 0644 ${WORKDIR}/var-lib.mount \
                ${D}${systemd_unitdir}/system/var-lib.mount
        install -m 0644 ${WORKDIR}/var-spool.mount \
                ${D}${systemd_unitdir}/system/var-spool.mount
    fi

    ln -sf ${systemd_unitdir}/system/var-volatile.mount \
           ${D}${systemd_unitdir}/system/local-fs.target.wants/var-volatile.mount
    if ${@bb.utils.contains('MACHINE_MNT_POINTS', '/systemrw', 'false', 'true', d)}; then
        ln -sf ${systemd_unitdir}/system/var-cache.mount \
               ${D}${systemd_unitdir}/system/local-fs.target.wants/var-cache.mount
        ln -sf ${systemd_unitdir}/system/var-lib.mount \
               ${D}${systemd_unitdir}/system/local-fs.target.wants/var-lib.mount
        ln -sf ${systemd_unitdir}/system/var-spool.mount \
               ${D}${systemd_unitdir}/system/local-fs.target.wants/var-spool.mount
    fi
}

# Scripts for pre and post hibernate functions
do_install_append_batcam () {
   install -d ${D}${systemd_unitdir}/system-sleep/
   install -m 0755 ${WORKDIR}/pre_hibernate.sh -D ${D}${systemd_unitdir}/system-sleep/pre_hibernate.sh
   install -m 0755 ${WORKDIR}/post_hibernate.sh -D ${D}${systemd_unitdir}/system-sleep/post_hibernate.sh
}

FILES_${PN} += " ${systemd_unitdir}/*"
