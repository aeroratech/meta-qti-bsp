inherit autotools-brokensep pkgconfig

DESCRIPTION = "Build Android libion"
HOMEPAGE = "http://developer.android.com/"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=89aea4e17d99a7cacdbeed46a0096b10"

PR = "r1"

FILESPATH =+ "${WORKSPACE}/system/core/:"
SRC_URI   = "file://libion"

S = "${WORKDIR}/libion"
DEPENDS += "virtual/kernel liblog"

LEGACYION = "${@d.getVar('LEGACY_ION_USAGE') or "False"}"

EXTRA_OECONF_append = " \
    --disable-static \
    --with-sanitized-headers=${STAGING_KERNEL_BUILDDIR}/usr/include \
    ${@oe.utils.conditional('LEGACYION', 'True', ' --enable-legacyion', '', d)} \
"

PACKAGES +="${PN}-test-bin"

FILES_${PN}     = "${libdir}/pkgconfig/* ${libdir}/* ${sysconfdir}/*"
FILES_${PN}-test-bin = "${base_bindir}/*"

PACKAGE_ARCH = "${MACHINE_ARCH}"
