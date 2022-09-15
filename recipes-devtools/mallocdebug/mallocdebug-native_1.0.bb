inherit autotools pkgconfig

DESCRIPTION = "malloc debug utility offline memory analysis tool"
HOMEPAGE = "www.codelinaro.org"
LICENSE = "BSD-3-Clause-Clear"
LIC_FILES_CHKSUM += "file://${COREBASE}/meta-qti-bsp/files/common-licenses/\
BSD-3-Clause-Clear;md5=3771d4920bd6cdb8cbdf1e8344489ee0"

SRC_URI   = "file://alloc-backtrace-parser.py"
SRC_URI   += "file://alloc-filter-mismatch.py"
SRC_URI   += "file://README.txt"

S = "${WORKDIR}/"

do_compile[noexec] = "1"
do_configure[noexec] = "1"

BBCLASSEXTEND = "native"
inherit native

do_install:class-native () {
    install -d ${D}/${bindir}/scripts/
    cp ${S}/alloc-backtrace-parser.py ${D}/${bindir}/scripts/
    cp ${S}/alloc-filter-mismatch.py ${D}/${bindir}/scripts/
    cp ${S}/README.txt ${D}/${bindir}/scripts/
}