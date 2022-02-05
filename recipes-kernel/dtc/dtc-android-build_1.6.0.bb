DESCRIPTION = "Android DTC required to compile QTI kernel"
LICENSE = "GPL-2.0"

LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=801f80980d171dd6425610833a22dbe6"

BBCLASSEXTEND = "native"

PROVIDES = "virtual/dtc-native"

FILESPATH =+ "${KERNEL_PREBUILT_PATH}/../host/:"
SRC_URI    = "file://bin"
SRC_URI   += "file://include"

S = "${WORKDIR}"

INHIBIT_SYSROOT_STRIP = "1"
do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
    # Install fdt headers
    install -d ${D}/${includedir}/
    cp -rf ${S}/include/fdt.h ${D}/${includedir}/
    cp -rf ${S}/include/libfdt_env.h  ${D}/${includedir}/
    cp -rf ${S}/include/libfdt.h ${D}/${includedir}/

    # Install dtc bin
    install -d ${D}/${bindir}/dtc/bin/
    cp -rf ${S}/bin/dtc ${D}/${bindir}/dtc/bin/
}
