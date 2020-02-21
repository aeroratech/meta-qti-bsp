inherit autotools-brokensep pkgconfig systemd
PR = "r0"

DESCRIPTION = "Recovery bootloader"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=89aea4e17d99a7cacdbeed46a0096b10"
HOMEPAGE = "https://www.codeaurora.org/gitweb/quic/la?p=platform/bootable/recovery.git"

DEPENDS = "glib-2.0 virtual/kernel libmincrypt libcutils libbase adbd system-core-headers ext4-utils oem-recovery libsparse liblog bison-native bzip2"
DEPENDS += " ${@bb.utils.contains('COMBINED_FEATURES', 'qti-ab-boot', 'abctl', '', d)}"
RDEPENDS_${PN} += " ${@bb.utils.contains('COMBINED_FEATURES', 'qti-ab-boot', 'abctl', '', d)}"
RDEPENDS_${PN} += "zlib"

FILESPATH =+ "${WORKSPACE}:"

SRC_URI = "file://OTA/recovery/"
SRC_URI += "file://fstab_AB"

S = "${WORKDIR}/OTA/recovery/"

EXTRA_OECONF = "--with-glib --with-sanitized-headers=${STAGING_KERNEL_BUILDDIR}/usr/include \
                --with-core-headers=${STAGING_INCDIR}"
CFLAGS += "-lsparse -llog"
PARALLEL_MAKE = ""

EXTRA_OECONF_append = " ${@bb.utils.contains('DISTRO_FEATURES', 'qti-ab-boot', 'TARGET_SUPPORTS_AB=true', '', d)}"

FILES_${PN}  = "${bindir} ${libdir} ${includedir} /res /data"

RM_WORK_EXCLUDE += "${PN}"

do_install_append() {
        install -d ${D}/res/
        install -d ${D}/data/recovery
        install -m 0755 ${WORKDIR}/fstab_AB -D ${D}/res/recovery_volume_config
}
