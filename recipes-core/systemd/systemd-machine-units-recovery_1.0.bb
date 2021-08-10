SUMMARY = "Machine specific systemd units for recovery"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"
PR = "r1"
FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI = "file://*"
S = "${WORKDIR}"

do_install_append () {
    install -d ${D}${systemd_unitdir}/system
    install -d ${D}${systemd_unitdir}/system/systemrw.mount.d
    install -d 0644 ${D}${systemd_unitdir}/system/local-fs.target.wants

    if ${@bb.utils.contains('IMAGE_FSTYPES', 'ubi', 'true', 'false', d)}; then
        install -m 0644 ${S}/systemrw-ubi.mount ${D}${systemd_unitdir}/system/systemrw.mount
        ln -sf ${systemd_unitdir}/system/systemrw-ubi.mount ${D}${systemd_unitdir}/system/local-fs.target.wants/systemrw.mount
        # Install systemrw.conf
        install -m 0744 ${S}/systemrw.conf ${D}${systemd_unitdir}/system/systemrw.mount.d/systemrw.conf
    fi
}

MNT_POINTS = "/systemrw"
def get_mnt_services(d):
    services = []
    slist = d.getVar("MNT_POINTS").split()
    for s in slist:
        svc = s.replace("/", "")
        if os.path.exists(oe.path.join(d.getVar("D"), d.getVar("systemd_unitdir"), "system", svc + ".mount")):
            services.append("%s.mount" % svc)
        elif os.path.exists(oe.path.join(d.getVar("D"), d.getVar("sysconfdir"), "systemd", "system", svc + ".mount")):
            services.append("%s.mount" % svc)
        else:
            services.append("%s-mount.service" % svc)
    return " ".join(services)

SYSTEMD_SERVICE_${PN} += "${@get_mnt_services(d)}"

FILES_${PN} += " ${systemd_unitdir}/*"
