inherit native python3native

DESCRIPTION = "Prebuilt DTBO image creation tool from Android"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/${LICENSE};md5=89aea4e17d99a7cacdbeed46a0096b10"

PROVIDES = "virtual/mkdtimg-native"

FILESPATH =+ "${WORKSPACE}/kernel-5.15/kernel_platform/prebuilts/kernel-build-tools/linux-x86/:"
SRC_URI  = "file://bin"
SRC_URI += "file://include"
SRC_URI += "file://lib64"

S = "${WORKDIR}"
do_compile[noexec] = "1"
do_configure[noexec] = "1"

SYSROOT_PREPROCESS_FUNCS_remove = "relocatable_binaries_preprocess"
SYSROOT_PREPROCESS_FUNCS_remove = "relocatable_native_pcfiles"
INHIBIT_SYSROOT_STRIP = "1"

# uninative.bbclass by default gets inherited into all native recipes.
# This class provides uninative_changeinterp function which eliminates
# any host-dependencies from native bins. This alteration is breaking
# mkdtimg.py and to disable it, defined custom function to do nothing.
python uninative_changeinterp () {
    return
}

do_install() {
    # NOTE: mkdtboimg.py is not a python script but a precompiled binary.
    # It requires native libs like libc++.so to run. Copy these libs from
    # kernel prebuilt paths into a relative directory to link. This tool isn't
    # functional with yocto's elf utils either. So copy required elf headers
    # from kernel prebuilt paths.
    install -d ${D}${bindir}/mkdtboimg/bin
    for b in ${S}/bin/*; do
        install -m 0755 $b -D ${D}/${bindir}/mkdtboimg/bin/
    done

    install -d ${D}${bindir}/mkdtboimg/lib64
    for l in ${S}/lib64/*; do
        install -m 0644 $l -D ${D}${bindir}/mkdtboimg/lib64
    done

    install -d ${D}${bindir}/mkdtboimg/include/elfutils
    for i in ${S}/include/elfutils/*; do
        install -m 0644 $i -D ${D}${bindir}/mkdtboimg/include/elfutils
    done
    install -m 0644 ${S}/include/gelf.h -D ${D}${bindir}/mkdtboimg/include/
    install -m 0644 ${S}/include/libelf.h -D ${D}${bindir}/mkdtboimg/include/
    install -m 0644 ${S}/include/nlist.h -D ${D}${bindir}/mkdtboimg/include/
}
