inherit native

DESCRIPTION = "Tool used for creating boot image"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/${LICENSE};md5=89aea4e17d99a7cacdbeed46a0096b10"

PR = "r0"

FILESPATH =+ "${WORKSPACE}/kernel-5.10/kernel_platform/tools/mkbootimg/:"
SRC_URI = "file://mkbootimg.py"

S = "${WORKDIR}"
do_compile[noexec] = "1"
do_configure[noexec] = "1"

do_install() {
    install -d ${D}/${bindir}/scripts/
    cp ${S}/mkbootimg.py ${D}/${bindir}/scripts/
}
