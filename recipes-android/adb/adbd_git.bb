inherit autotools pkgconfig systemd

DESCRIPTION = "ADB daemon"
HOMEPAGE = "http://developer.android.com/"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=89aea4e17d99a7cacdbeed46a0096b10"

FILESEXTRAPATHS_prepend := "${WORKSPACE}/system/core/:"
SRC_URI = "file://adb \
           file://include"

S = "${WORKDIR}/adb"

DEPENDS += "ext4-utils glib-2.0 fsmgr libselinux libbase libcutils liblog"

EXTRA_OECONF = " \
                  --with-glib \
                  --with-core-includes=${WORKSPACE}/system/core/include \
"

ADB_OVER_PCIE = "${@d.getVar('MACHINE_SUPPORTS_ADB_OVER_PCIE') or "False"}"

do_install_append() {
    install -d ${D}${base_sbindir}
    install -d ${D}${sysconfdir}
    install -m 0755 ${S}/launch_adbd -D ${D}${base_sbindir}/launch_adbd
    install -b -m 0644 /dev/null ${D}${sysconfdir}/adb_devid

    install -d ${D}${systemd_unitdir}/system/
    install -m 0644 ${S}/adbd.service -D ${D}${systemd_unitdir}/system/adbd.service

    if ${@bb.utils.contains_any('MACHINE_FEATURES', 'qti-sdx qti-csm', 'true', 'false', d)}; then
        # Run adb as part of local-fs.target
        sed -i '/Requires=usb.service/s/$/ diag-router.service/' ${D}${systemd_unitdir}/system/adbd.service
        sed -i 's/default.target/local-fs.target/g' ${D}${systemd_unitdir}/system/adbd.service
    fi

    if ${@oe.utils.conditional('ADB_OVER_PCIE', 'True', 'true', 'false', d)}; then
        if ${@bb.utils.contains('MACHINE_FEATURES', 'qti-csm', 'true', 'false', d)}; then
             install -d ${D}${userfsdatadir}
             install -m 0755 ${S}/debug_transport.conf -D ${D}${userfsdatadir}/debug_transport.conf
        fi
        install -m 0755 ${S}/start_pcie -D ${D}${sysconfdir}/start_pcie
        install -m 0644 ${S}/pcie.service -D ${D}${systemd_unitdir}/system/pcie.service
        sed -i 's/default.target/local-fs.target/g' ${D}${systemd_unitdir}/system/pcie.service
    fi
}

SYSTEMD_SERVICE_${PN}  = " adbd.service "
SYSTEMD_SERVICE_${PN} += "${@oe.utils.conditional('ADB_OVER_PCIE','True', 'pcie.service', '',d)}"

FILES_${PN} += "${systemd_unitdir}/system/"
FILES_${PN} += "${userfsdatadir}/"
