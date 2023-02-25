inherit autotools systemd useradd

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI   = "file://${BASEMACHINE}/system.prop"
SRC_URI  += "file://persist-prop.sh"
SRC_URI  += "file://persist-prop.service"

DESCRIPTION = "Script to populate system properties"

LICENSE = "BSD"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=3775480a712fc46a69647678acb234cb"

PERSIST_PROP_SUPPORT ?= 'True'
PERSIST_PROP_SUPPORT_qti-distro-tele = 'False'

SYSTEMD_PACKAGES = "${@bb.utils.contains('DISTRO_FEATURES','systemd','${PN}','',d)}"
PERSIST_SERVICE = '${@oe.utils.conditional('PERSIST_PROP_SUPPORT','True','persist-prop.service','',d)}'
SYSTEMD_SERVICE_${PN} = "${@bb.utils.contains('DISTRO_FEATURES','systemd','${PERSIST_SERVICE}','',d)}"

do_compile() {
    # Remove empty lines and lines starting with '#'
    sed -e 's/#.*$//' -e '/^$/d' ${WORKDIR}/${BASEMACHINE}/system.prop >> ${S}/build.prop
}

do_install() {
    install -d ${D}
    install -m 0644 ${S}/build.prop ${D}/build.prop
    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        if ${@bb.utils.contains('PERSIST_PROP_SUPPORT','True', 'true','false', d)}; then
           install -m 0755 ${WORKDIR}/persist-prop.sh -D ${D}${base_sbindir}/persist-prop.sh
           install -d ${D}${systemd_unitdir}/system
           install -d ${D}${systemd_unitdir}/system/multi-user.target.wants/
           install -m 644 ${WORKDIR}/persist-prop.service ${D}/${systemd_unitdir}/system
           ln -sf ${systemd_unitdir}/system/persist-prop.service ${D}${systemd_unitdir}/system/multi-user.target.wants/persist-prop.service
        fi
    fi
}

PACKAGES = "${PN}"
FILES_${PN} += "${base_sbindir}/"
FILES_${PN} += "/build.prop"
FILES_${PN} += "${systemd_unitdir}/"
