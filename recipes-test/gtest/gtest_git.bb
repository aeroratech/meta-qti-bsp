DESCRIPTION = "Google's framework for writing C++ tests"
HOMEPAGE = "http://code.google.com/p/googletest/"
SECTION = "libs"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${WORKDIR}/git/LICENSE;md5=cbbd27594afd089daa160d3a16dd515a"

SRC_URI = "\
    ${CLO_LA_GIT}/platform/external/chromium_org/testing/gtest;protocol=https;branch=caf_migration/LA.AF.1.1.1 \
    file://0001-Add-install-command-for-libraries-and-headers.patch \
    file://0002-CMakeLists-gtest.pc.in-Add-pkg-config-support-to-gte.patch \
"
SRCREV = "93b4e4a7fb335fdccc24d18bfb284e0828d2596d"

S = "${WORKDIR}/git"

inherit lib_package cmake

EXTRA_OECMAKE = "-DBUILD_SHARED_LIBS=ON"

BBCLASSEXTEND = "native nativesdk"

FILES_SOLIBSDEV = ""
FILES_${PN} += "${libdir}/*.so"
