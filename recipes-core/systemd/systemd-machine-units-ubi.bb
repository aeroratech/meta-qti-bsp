DESCRIPTION = "Systemd machine units for ubi image"
include qti-systemd-machine-units.inc

IMAGETYPE = "ubi"

fix_sepolicies_ubi () {

    sed -i "s#,context=system_u:object_r:firmware_t:s0##g" ${WORKDIR}/firmware-mount.service
    sed -i "s#,context=system_u:object_r:firmware_t:s0##g" ${WORKDIR}/bt_firmware-mount.service
    sed -i "s#,context=system_u:object_r:adsprpcd_t:s0##g" ${WORKDIR}/dsp-mount.service
    sed -i "s#,rootcontext=system_u:object_r:data_t:s0##g" ${WORKDIR}/data.mount
    sed -i "s#,rootcontext=system_u:object_r:persist_t:s0##g" ${WORKDIR}/persist.mount
    sed -i "s#,rootcontext=system_u:object_r:system_data_t:s0##g" ${WORKDIR}/systemrw.mount
}

do_install[prefuncs] += " ${@bb.utils.contains('DISTRO_FEATURES', 'selinux', '', 'fix_sepolicies_ubi', d)}"

do_install_append () {

    add_ubi_scripts
    if ${@bb.utils.contains('DISTRO_FEATURES','nand-squashfs','true','false',d)}; then
        add_squashfs_scripts
    fi
    install -d 0644 ${D}${sysconfdir}/udev/rules.d
    install -m 0744 ${S}/mountpartitions.rules ${D}${sysconfdir}/udev/rules.d/mountpartitions
}

add_ubi_scripts () {
    for entry in ${MACHINE_MNT_POINTS}; do
        mountname="${entry:1}"
        if [ "$mountname" = "firmware" -o "$mountname" = "bt_firmware" -o "$mountname" = "dsp" -o "$mountname" = "vm-bootsys" ]; then
            install -m 0744 ${S}/${mountname}-ubi-mount.sh ${D}${sysconfdir}/initscripts/${mountname}-ubi-mount.sh
        fi

        if [ "$mountname" = "systemrw" ]; then
            install -m 0744 ${S}/systemrw.conf ${D}/lib/systemd/system/systemrw-ubi.conf
        fi
    done
}

add_squashfs_scripts () {
    if ${@bb.utils.contains('MACHINE_MNT_POINTS', '/firmware', 'true', 'false', d)}; then
        install -m 0744 ${S}/non-hlos-squash.sh ${D}${sysconfdir}/initscripts/firmware-ubi-mount.sh
    fi
}
