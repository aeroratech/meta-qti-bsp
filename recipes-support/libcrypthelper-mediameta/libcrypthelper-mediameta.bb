inherit autotools pkgconfig

DESCRIPTION = "Build crypthelper-mediameta, a helper library\
               to provide mapping between encryption meta and\
               encryptable block devices"

LICENSE = "BSD"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=3775480a712fc46a69647678acb234cb"

EXTRA_OECONF_append = " --with-basemachine=${BASEMACHINE}"

FILESEXTRAPATHS_prepend := "${WORKSPACE}/system/extras/libcrypthelper-mediameta/:"
SRC_URI   = "file://crypthelper-mediameta"
SRC_URI  += "file://sdmsteppe/"
SRC_URI  += "file://neo/"
SRC_URI  += "file://cinder/"
SRC_URI  += "file://qrb5165/"
SRC_URI  += "file://qcs6490/"

S = "${WORKDIR}/crypthelper-mediameta"

PACKAGE_ARCH = "${MACHINE_ARCH}"

PACKAGES =+ "${PN}-lib"
FILES_${PN}-lib   =  "${sysconfdir}/conf/*"
FILES_${PN}-lib  +=  "${libdir}/libcrypthelper_mediameta.so.*  ${libdir}/pkgconfig/*"
