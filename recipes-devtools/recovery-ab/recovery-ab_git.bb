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

S = "${WORKDIR}/OTA/recovery/"

EXTRA_OECONF = "--with-glib --with-sanitized-headers=${STAGING_KERNEL_BUILDDIR}/usr/include \
                --with-core-headers=${STAGING_INCDIR}"
EXTRA_OECONF_append = "${@bb.utils.contains('MACHINE_FEATURES', 'ota-package-verification', 'TARGET_SUPPORTS_OTA_VERIFICATION=true', '', d)}"
CFLAGS += "-lsparse -llog"
PARALLEL_MAKE = ""

EXTRA_OECONF_append = " ${@bb.utils.contains('DISTRO_FEATURES', 'qti-ab-boot', 'TARGET_SUPPORTS_AB=true', '', d)}"

FILES_${PN}  = "${bindir} ${libdir} ${includedir} /res /cache"

RM_WORK_EXCLUDE += "${PN}"

generate_public_key() {
    openssl pkcs8 -inform DER -nocrypt -in ${WORKSPACE}/OTA/build/target/product/security/testkey.pk8 -out ${TMPDIR}/deploy/images/sxr2130-mtp/ota-scripts/private.pem
    openssl rsa -in ${TMPDIR}/deploy/images/sxr2130-mtp/ota-scripts/private.pem -outform PEM -pubout > ${WORKDIR}/public.pem
}

do_install[prefuncs] += "${@bb.utils.contains('MACHINE_FEATURES', 'ota-package-verification', 'generate_public_key', '', d)}"

do_install_append() {
        install -d ${D}/res/
        install -d ${D}/cache/recovery
        install -m 0755 ${WORKDIR}/fstab_AB -D ${D}/res/recovery_volume_config
        if ${@bb.utils.contains('MACHINE_FEATURES', 'ota-package-verification', 'true', 'false', d)}; then
            install -m 0755 ${WORKDIR}/public.pem -D ${D}/res/public.pem
        fi
}
