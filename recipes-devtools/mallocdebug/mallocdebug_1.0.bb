# inherit autotools pkgconfig

DESCRIPTION = "malloc debug utility for memory analysis"
HOMEPAGE = "www.codelinaro.org"
LICENSE = "BSD-3-Clause-Clear"
LIC_FILES_CHKSUM += "file://${COREBASE}/meta-qti-bsp/files/common-licenses/\
BSD-3-Clause-Clear;md5=3771d4920bd6cdb8cbdf1e8344489ee0"

SRC_URI   = "file://mallocdebug.cpp"

S = "${WORKDIR}/"

do_compile() {
   ${CXX} -g -O0 ${WORKDIR}/mallocdebug.cpp -ldl --shared -fPIC -o libmallocdebug.so
}  

do_install_class-target() {
    install -d ${D}${libdir}
    install -m 0755 ${B}/libmallocdebug.so  ${D}${libdir}/
    #lnr  ${D}${libdir}/libmallocdebug.so.0  ${D}${libdir}/libmallocdebug.so
}

PACKAGE_ARCH = "${MACHINE_ARCH}"
PACKAGES = "${PN} ${PN}-dbg ${PN}-dev"
FILES_${PN} += "${libdir}/* ${bindir}/libmallocdebug.so"
FILES_${PN}-dbg += "${libdir}/.debug/libmallocdebug.so"
FILES_${PN}-dev += "${libdir}/libmallocdebug.so"
