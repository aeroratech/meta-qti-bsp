inherit native python3native utils

DESCRIPTION = "Prebuilt DTBO image creation tool from Android"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/${LICENSE};md5=89aea4e17d99a7cacdbeed46a0096b10"

PROVIDES = "virtual/mkdtimg-native"

FILESPATH =+ "${WORKSPACE}/kernel-5.10/kernel_platform/prebuilts/kernel-build-tools/linux-x86/:"
SRC_URI  = "file://bin/mkdtboimg.py"
SRC_URI += "file://lib64"

S = "${WORKDIR}"
do_compile[noexec] = "1"
do_configure[noexec] = "1"

do_install() {
    # NOTE: mkdtboimg.py is not a python script but a precompiled binary.
    # It requires native libs like libc++.so to run. Copy these libs from
    # kernel prebuilt paths and set LD_LIBRARY_PATH to link
    install -d ${D}/${bindir}/
    install -d ${D}/${libdir}/
    install -d ${D}/${libdir}/mkdtboimg
    cp ${S}/bin/mkdtboimg.py ${D}${bindir}/mkdtboimg.py
    cp ${S}/lib64/* ${D}${libdir}/mkdtboimg/

    create_wrapper ${D}${bindir}/mkdtboimg.py \
         LD_LIBRARY_PATH=${STAGING_LIBDIR_NATIVE}/mkdtboimg \
         PYTHONHOME=${STAGING_LIBDIR_NATIVE}/${PYTHON_DIR}
}
