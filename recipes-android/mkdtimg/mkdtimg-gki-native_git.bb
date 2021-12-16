inherit native

DESCRIPTION = "Prebuilt DTBO image creation tool from Android"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/${LICENSE};md5=89aea4e17d99a7cacdbeed46a0096b10"

PROVIDES = "virtual/mkdtimg-native"

FILESPATH =+ "${WORKSPACE}/kernel-5.10/kernel_platform/build/build-tools/path/linux-x86/:"
SRC_URI = "file://mkdtboimg.py"

S = "${WORKDIR}"
do_compile[noexec] = "1"
do_configure[noexec] = "1"

do_install() {
    install -d ${D}/${bindir}/scripts/
    cp ${S}/mkdtboimg.py ${D}/${bindir}/scripts/
}
