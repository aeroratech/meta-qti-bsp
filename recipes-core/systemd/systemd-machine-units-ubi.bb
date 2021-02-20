DESCRIPTION = "Systemd machine units for ubi image"
include qti-systemd-machine-units.inc

IMAGETYPE = "ubi"

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
        if [ "$mountname" = "firmware" -o "$mountname" = "bt_firmware" -o "$mountname" = "dsp" ]; then
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
