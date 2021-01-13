inherit autotools-brokensep pkgconfig

DESCRIPTION = "Build Android libdmabufheap for LE"
HOMEPAGE = "http://developer.android.com/"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=89aea4e17d99a7cacdbeed46a0096b10"

PR = "r1"

FILESPATH =+ "${WORKSPACE}/system/memory/:"
SRC_URI   = "file://libdmabufheap"

S = "${WORKDIR}/libdmabufheap"
DEPENDS += "virtual/kernel libbase libion"

# To get kernel headers for compilation
do_configure[depends] += "virtual/kernel:do_shared_workdir"

EXTRA_OECONF_append = " \
    --disable-static \
    --with-sanitized-headers=${STAGING_KERNEL_BUILDDIR}/usr/include \
"

PACKAGES +="${PN}-test-bin"

FILES_${PN}     = "${libdir}/pkgconfig/* ${libdir}/* ${sysconfdir}/*"
FILES_${PN}-test-bin = "${base_bindir}/*"

PACKAGE_ARCH = "${MACHINE_ARCH}"
