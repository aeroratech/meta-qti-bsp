SUMMARY = "Generates Linux kernel signing keys"
LICENSE = "GPLv2.0-with-linux-syscall-note"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"

# Ensure PACKAGE_ARCH is set to all even when multilib is enabled.
PACKAGE_ARCH = "all"

inherit allarch nopackages

FILESPATH =+ "${WORKSPACE}:"

SRC_URI   =  "file://kernel-${PV}/kernel_platform/msm-kernel"

S  =  "${WORKDIR}/kernel-${PV}/kernel_platform/msm-kernel"

do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_copy_cert_files() {
    cp -a ${KERNEL_PREBUILT_PATH}/../msm-kernel/certs/signing_key.pem ${B}/signing_key.pem
    cp -a ${KERNEL_PREBUILT_PATH}/../msm-kernel/certs/verity_key.pem ${B}/verity_key.pem
    cp -a ${KERNEL_PREBUILT_PATH}/../msm-kernel/certs/verity_cert.pem ${B}/verity_cert.pem

}

addtask do_copy_cert_files after do_compile before do_install

do_install() {
 # Copy kernel certs
 install -d ${D}/kernel-certs
 if "${@bb.utils.contains('DISTRO_FEATURES', 'dm-verity', bb.utils.contains('MACHINE_FEATURES', 'dm-verity-initramfs-v3', 'true', 'false', d), 'false', d)}"; then
    install -m 0644 ${B}/signing_key.pem ${D}/kernel-certs/
    install -m 0644 ${B}/verity_key.pem ${D}/kernel-certs/
    install -m 0644 ${B}/verity_cert.pem ${D}/kernel-certs/
 fi
}

SYSROOT_DIRS += "/kernel-certs"
