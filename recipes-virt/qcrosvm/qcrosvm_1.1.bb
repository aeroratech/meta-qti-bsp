inherit ${@bb.utils.contains("BBFILE_COLLECTIONS", "rust-layer", "cargo", "", d)} systemd

SUMMARY  = "QCrosVM Support"
HOMEPAGE = "https://www.codelinaro.org/"
LICENSE  = "BSD-3-Clause-Clear"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta-qti-bsp/files/common-licenses/\
${LICENSE};md5=3771d4920bd6cdb8cbdf1e8344489ee0"

PR = "R1"

DEPENDS += "cargo-native libcap rust-native rust-llvm-native"

FILESPATH =+ "${WORKSPACE}:"
SRC_URI = "\
        file://telematics/apps/open-source/qcrosvm/ \
        file://external/crosvm/ \
        file://external/rust/crates/ \
        file://external/minijail/ \
"

S = "${WORKDIR}/telematics/apps/open-source/qcrosvm"

CARGO_DISABLE_BITBAKE_VENDORING = "1"
