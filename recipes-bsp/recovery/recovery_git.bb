inherit autotools-brokensep pkgconfig
PR = "r7"

DESCRIPTION = "Recovery bootloader"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=89aea4e17d99a7cacdbeed46a0096b10"
HOMEPAGE = "https://www.codeaurora.org/gitweb/quic/la?p=platform/bootable/recovery.git"

DEPENDS += "glib-2.0 mtd-utils oem-recovery adbd libbase libsparse libmincrypt bzip2 bison-native openssl"
RDEPENDS_${PN} = "zlib"

FILESPATH =+ "${WORKSPACE}:"
SRC_URI = "file://OTA/recovery/"
SRC_URI += "file://recovery.service"
S = "${WORKDIR}/OTA/recovery/"

EXTRA_OECONF = "--with-glib --with-sanitized-headers=${STAGING_KERNEL_BUILDDIR}/usr/include \
                --with-core-headers=${STAGING_INCDIR}"
EXTRA_OECONF += "${@bb.utils.contains('DISTRO_FEATURES', 'ota-package-verification', 'TARGET_SUPPORTS_OTA_VERIFICATION=true', '', d)}"
EXTRA_OECONF_append = " ${@bb.utils.contains('DISTRO_FEATURES', 'dm-verity', 'TARGET_SUPPORTS_NAND_DM_VERITY=true', '', d)}"

CFLAGS += "-lsparse -llog"

PARALLEL_MAKE = ""

FILES_${PN}  = "${bindir} ${libdir} ${includedir} ${systemd_unitdir} /res /cache /data"

RM_WORK_EXCLUDE += "${PN}"

do_install_append() {
    install -d ${D}${systemd_unitdir}/system/
    install -d ${D}${systemd_unitdir}/system/multi-user.target.wants/
    install -m 0644 ${WORKDIR}/recovery.service -D ${D}${systemd_unitdir}/system/recovery.service
    ln -sf ${systemd_unitdir}/system/recovery.service ${D}${systemd_unitdir}/system/multi-user.target.wants/recovery.service
}