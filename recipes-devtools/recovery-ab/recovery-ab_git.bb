inherit autotools-brokensep pkgconfig systemd
PR = "r0"

DESCRIPTION = "Recovery bootloader"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=89aea4e17d99a7cacdbeed46a0096b10"
HOMEPAGE = "https://www.codeaurora.org/gitweb/quic/la?p=platform/bootable/recovery.git"

DEPENDS += "glib-2.0 ext4-utils oem-recovery adbd libbase libsparse libmincrypt bzip2 bison-native openssl"
DEPENDS += " ${@bb.utils.contains('COMBINED_FEATURES', 'qti-ab-boot', 'abctl', '', d)}"

RDEPENDS_${PN} += "zlib"
RDEPENDS_${PN} += "${@bb.utils.contains('MACHINE_FEATURES', 'ota-package-verification', 'openssl', '', d)}"
RDEPENDS_${PN} += "${@bb.utils.contains('MACHINE_FEATURES', 'ota-package-verification', 'openssl-bin', '', d)}"

FILESPATH =+ "${WORKSPACE}:"

SRC_URI = "file://OTA/recovery/"
SRC_URI += "file://fstab_AB"
SRC_URI += "file://fstab_AB_cache_ext4"
SRC_URI += "file://fstab_AB_nad"
SRC_URI += "file://mirror_copy.service"

S = "${WORKDIR}/OTA/recovery/"

EXTRA_OECONF = "--with-glib --with-sanitized-headers=${STAGING_KERNEL_BUILDDIR}/usr/include \
                --with-core-headers=${STAGING_INCDIR}"
EXTRA_OECONF_append = "${@bb.utils.contains('MACHINE_FEATURES', 'ota-package-verification', 'TARGET_SUPPORTS_OTA_VERIFICATION=true', '', d)}"
CFLAGS += "-lsparse -llog"
PARALLEL_MAKE = ""

EXTRA_OECONF_append = " ${@bb.utils.contains('COMBINED_FEATURES', 'qti-ab-boot', 'TARGET_SUPPORTS_AB=true', '', d)}"
EXTRA_OECONF_append = " ${@bb.utils.contains('MACHINE_FEATURES', 'nand-boot', 'TARGET_NAND_BOOT=true', '', d)}"
EXTRA_OECONF_append = " ${@bb.utils.contains('COMBINED_FEATURES', 'qti-ab-boot', bb.utils.contains('MACHINE_FEATURES', 'qti-ab-mirror-sync', 'TARGET_SUPPORTS_MIRROR_AB_COPY=true', '', d), '', d)}"

FILES_${PN}  = "${bindir} ${libdir} ${systemd_unitdir} ${includedir} /res /cache"
SYSTEMD_SERVICE_${PN} = " ${@bb.utils.contains('COMBINED_FEATURES', 'qti-ab-boot', bb.utils.contains('MACHINE_FEATURES', 'qti-ab-mirror-sync', 'mirror_copy.service', '', d), '', d)}"
RM_WORK_EXCLUDE += "${PN}"
INITSCRIPT_NAME = "mirror_copy"
INITSCRIPT_PARAMS = "defaults"
generate_public_key() {
    openssl pkcs8 -inform DER -nocrypt -in ${WORKSPACE}/OTA/build/target/product/security/testkey.pk8 -out ${TMPDIR}/deploy/images/sxr2130-mtp/ota-scripts/private.pem
    openssl rsa -in ${TMPDIR}/deploy/images/sxr2130-mtp/ota-scripts/private.pem -outform PEM -pubout > ${WORKDIR}/public.pem
}

do_install[prefuncs] += "${@bb.utils.contains('MACHINE_FEATURES', 'ota-package-verification', 'generate_public_key', '', d)}"

do_install_append() {
        install -d ${D}/res/
        install -d ${D}/cache/recovery
        if ${@bb.utils.contains('IMAGE_FSTYPES', 'ext4', 'true', 'false', d)}; then
            if ${@bb.utils.contains_any('MACHINE_MNT_POINTS', '/overlay', 'true', 'false', d)}; then
                install -m 0755 ${WORKDIR}/fstab_AB -D ${D}/res/recovery_volume_config
            elif ${@bb.utils.contains_any('MACHINE_MNT_POINTS', '/cache', 'true', 'false', d)}; then
                install -m 0755 ${WORKDIR}/fstab_AB_cache_ext4 -D ${D}/res/recovery_volume_config
            fi
        fi

        if ${@bb.utils.contains('COMBINED_FEATURES', 'qti-nad-core', 'true', 'false', d)}; then
            install -m 0755 ${WORKDIR}/fstab_AB_nad -D ${D}/res/recovery_volume_config
        fi

        install -d ${D}${systemd_unitdir}/system/

        if ${@bb.utils.contains('COMBINED_FEATURES', 'qti-ab-boot', bb.utils.contains('MACHINE_FEATURES', 'qti-ab-mirror-sync', 'true', 'false', d), 'false', d)}; then
            install -m 0644 ${WORKDIR}/mirror_copy.service -D \
                     ${D}${systemd_unitdir}/system/mirror_copy.service
        fi

        if ${@bb.utils.contains('MACHINE_FEATURES', 'ota-package-verification', 'true', 'false', d)}; then
            install -m 0755 ${WORKDIR}/public.pem -D ${D}/res/public.pem
        fi
}
