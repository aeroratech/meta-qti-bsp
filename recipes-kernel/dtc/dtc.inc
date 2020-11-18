SUMMARY = "Device Tree Compiler"
HOMEPAGE = "https://devicetree.org/"
DESCRIPTION = "The Device Tree Compiler is a tool used to manipulate the Open-Firmware-like device tree used by PowerPC kernels."
SECTION = "bootloader"
LICENSE = "GPLv2 | BSD"
DEPENDS = "flex-native bison-native"

SRC_URI[md5sum] = "cdccae512205bf0303684cbe8a2a2449"
SRC_URI[sha256sum] = "3082ff8c7010efd44cf02cd6ac4ade25a59ee1a02d6bef94d943fac848d92459"

SRC_URI = " \
git://source.codeaurora.org/quic/la/platform/external/dtc.git;protocol=https;branch=aosp-new/android10-release \
file://0001-dtc_compile.patch \
"

EXTRA_OEMAKE='NO_PYTHON=1 PREFIX="${prefix}" LIBDIR="${libdir}" DESTDIR="${D}"'

S = "${WORKDIR}/git"

do_install () {
    oe_runmake install
}

PACKAGES =+ "${PN}-misc"
FILES_${PN}-misc = "${bindir}/convert-dtsv0 ${bindir}/ftdump ${bindir}/dtdiff"

RDEPENDS_${PN}-misc += "bash"
