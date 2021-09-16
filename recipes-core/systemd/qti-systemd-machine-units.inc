#Add qti specific changes only when QTI Disro is enabled.
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://*"
S = "${WORKDIR}"

IMAGETYPE ??= ""
OVERLAY_MNT_POINTS ??= "etc data cache"
OVERLAY_MNT_POINTS_qrb5165 = "etc data cache usr-share"

do_install_append () {
    install -d 0644 ${D}${sysconfdir}/initscripts
    install -d 0644 ${D}${systemd_unitdir}/system
    install -d 0644 ${D}${systemd_unitdir}/system/local-fs.target.requires
    install -d 0644 ${D}${systemd_unitdir}/system/local-fs.target.wants
    install -d 0644 ${D}${systemd_unitdir}/system/sysinit.target.wants
    install -d 0644 ${D}${systemd_unitdir}/system/multi-user.target.wants

    add_mount_files
}

add_mount_files () {
    # If the AB boot feature or nand-boot is enabled, then instead of <partition>.mount,
    # a <partition-mount>.service invokes mounting the A/B|NAND partition  as detected at the time of boot.

    for entry in ${MACHINE_MNT_POINTS}; do
        mountname="${entry:1}"
        if [[ "$mountname" == "firmware" || "$mountname" == "bt_firmware" || "$mountname" == "dsp" ]] && \
           [[ "${IMAGETYPE}" == "ubi" || "${COMBINED_FEATURES}" =~ .*qti-ab-boot.* ]] ; then
            install -m 0644 ${S}/${mountname}-mount.service ${D}${systemd_unitdir}/system/${mountname}-mount-${IMAGETYPE}.service
        else
            install -m 0644 ${S}/${mountname}.mount ${D}${systemd_unitdir}/system/${mountname}-${IMAGETYPE}.mount
        fi
    done

    if ${@bb.utils.contains('MACHINE_MNT_POINTS', '/overlay', 'true', 'false', d)}; then
        add_overlay_mount_files
    fi
}

add_overlay_mount_files () {
    # TODO: when overlay mount is added on ubi, review this function again.
    for mountname in ${OVERLAY_MNT_POINTS}; do
        install -m 0644 ${S}/overlay-${mountname}.mount ${D}${systemd_unitdir}/system/${mountname}.mount
        ln -sf ${systemd_unitdir}/system/${mountname}.mount ${D}${systemd_unitdir}/system/local-fs.target.wants/${mountname}.mount
    done

    install -D -m 0755 ${S}/overlay-workdir.sh ${D}${base_sbindir}/create-overlay-workdirs
    install -D -m 0644 ${S}/overlay-workdir.service ${D}${systemd_unitdir}/system/overlay-workdir.service
    ln -sf ${systemd_unitdir}/system/overlay-workdir.service ${D}${systemd_unitdir}/system/local-fs.target.wants/overlay-workdir.service
}

# Various mount related files assume selinux support by default.
# Explicitly remove sepolicy entries when selinux is not present.
fix_sepolicies () {
    sed -i "s#,context=system_u:object_r:firmware_t:s0##g" ${WORKDIR}/firmware.mount
    sed -i "s#,context=system_u:object_r:firmware_t:s0##g" ${WORKDIR}/firmware-mount.service
    sed -i "s#,context=system_u:object_r:firmware_t:s0##g" ${WORKDIR}/bt_firmware.mount
    sed -i "s#,context=system_u:object_r:firmware_t:s0##g" ${WORKDIR}/bt_firmware-mount.service
    sed -i "s#,context=system_u:object_r:adsprpcd_t:s0##g" ${WORKDIR}/dsp-mount.service
    sed -i "s#,rootcontext=system_u:object_r:data_t:s0##g" ${WORKDIR}/data.mount
    sed -i "s#,rootcontext=system_u:object_r:persist_t:s0##g" ${WORKDIR}/persist.mount
    sed -i "s#,rootcontext=system_u:object_r:system_data_t:s0##g" ${WORKDIR}/systemrw.mount

    # TODO: figure out the selinux context for the overlays
    sed -i "s#,rootcontext=system_u:object_r:overlay_t:s0##g" ${WORKDIR}/overlay.mount
    sed -i "s#,rootcontext=system_u:object_r:etc_t:s0##g" ${WORKDIR}/overlay-etc.mount
    sed -i "s#,rootcontext=system_u:object_r:data_t:s0##g" ${WORKDIR}/overlay-data.mount
    sed -i "s#,rootcontext=system_u:object_r:cache_t:s0##g" ${WORKDIR}/overlay-cache.mount
}

def get_mnt_services(d):
    services = []
    img = d.getVar("IMAGETYPE")
    slist = d.getVar("MACHINE_MNT_POINTS").split()
    for s in slist:
        svc = s.replace("/", "")
        if os.path.exists(oe.path.join(d.getVar("D"), d.getVar("systemd_unitdir"), "system", svc + "-" + img + ".mount")):
            services.append("%s.mount" % svc)
        elif os.path.exists(oe.path.join(d.getVar("D"), d.getVar("sysconfdir"), "systemd", "system", svc + "-" + img + ".mount")):
            services.append("%s.mount" % svc)
        else:
            services.append("%s-mount.service" % svc)

    if "/overlay" in slist:
        services.append("overlay-workdir.service")

    return " ".join(services)

SYSTEMD_SERVICE_${PN} += "${@get_mnt_services(d)}"

FILES_${PN} += " ${systemd_unitdir}/*"
