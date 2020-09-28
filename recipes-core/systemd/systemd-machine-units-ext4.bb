DESCRIPTION = "Systemd machine units for ext4 image"
include qti-systemd-machine-units.inc

IMAGETYPE = "ext4"

do_install[prefuncs] += " ${@bb.utils.contains('DISTRO_FEATURES', 'selinux', '', 'fix_sepolicies', d)}"

do_install_append () {

    if ${@bb.utils.contains('MACHINE_MNT_POINTS', '$userfsdatadir', 'true', 'false', d)}; then
        # Run fsck at boot
        install -d 0644 ${D}${systemd_unitdir}/system/local-fs-pre.target.requires
        ln -sf ${systemd_unitdir}/system/systemd-fsck@.service \
            ${D}${systemd_unitdir}/system/local-fs-pre.target.requires/systemd-fsck@dev-disk-by\\x2dpartlabel-userdata.service
    fi

    if ${@bb.utils.contains('COMBINED_FEATURES', 'qti-ab-boot', 'true', 'false', d)}; then
        install -m 0644 ${S}/set-slotsuffix.service ${D}${systemd_unitdir}/system
    fi
}

SYSTEMD_SERVICE_${PN} += "${@bb.utils.contains('COMBINED_FEATURES','qti-ab-boot',' set-slotsuffix.service','',d)}"
