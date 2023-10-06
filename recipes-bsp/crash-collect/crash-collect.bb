inherit autotools pkgconfig useradd

LICENSE          = "BSD-3-Clause-Clear"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta-qti-bsp/files/common-licenses/\
${LICENSE};md5=3771d4920bd6cdb8cbdf1e8344489ee0"

DESCRIPTION = "crash collect library and utility."

FILESEXTRAPATHS_prepend := "${WORKSPACE}/QPlatformUtils:"
SRC_URI = "file://${PN}"

S = "${WORKDIR}/${PN}"

PACKAGECONFIG ??= " \
    glib \
"
PACKAGECONFIG[glib] = "--with-glib, --without-glib, glib-2.0"

do_install_append() {
      install -d ${D}${systemd_unitdir}/system/
      install -m 0644 ${S}/crash-collect.service -D ${D}${systemd_unitdir}/system/crash-collect.service
}

SYSTEMD_SERVICE_${PN} = "crash-collect.service"

FILES_${PN} += "${systemd_unitdir}/system/*"
