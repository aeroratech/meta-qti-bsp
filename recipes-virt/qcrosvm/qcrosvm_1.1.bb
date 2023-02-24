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
        file://qvirtmgr.service \
        file://Cargo.toml \
        file://devices-Cargo.toml \
"

S = "${WORKDIR}/telematics/apps/open-source/qcrosvm"

do_patch_cargo () {
  mv -f ${WORKDIR}/Cargo.toml ${WORKDIR}/external/crosvm/Cargo.toml
  mv -f ${WORKDIR}/devices-Cargo.toml ${WORKDIR}/external/crosvm/devices/Cargo.toml
}

do_patch[postfuncs] += "do_patch_cargo"

SYSTEMD_SERVICE_${PN} = "qvirtmgr.service"

do_install_append() {
    if ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'true', 'false', d)}; then
        install -m 0644 ${WORKDIR}/qvirtmgr.service -D ${D}${systemd_unitdir}/system/qvirtmgr.service
    fi
}

CARGO_DISABLE_BITBAKE_VENDORING = "1"
