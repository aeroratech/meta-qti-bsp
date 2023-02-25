SUMMARY = "Generates Linux kernel signing keys"
LICENSE = "GPLv2.0-with-linux-syscall-note"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"

# Ensure PACKAGE_ARCH is set to all even when multilib is enabled.
PACKAGE_ARCH = "all"

inherit allarch nopackages

FILESPATH =+ "${KERNEL_PREBUILT_PATH}/../:"
SRC_URI   =  "file://msm-kernel/"
S = "${WORKDIR}"

do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
 # Copy kernel certs
 install -d ${D}/kernel-certs
 install -m 0644 ${S}/msm-kernel/certs/signing_key.pem ${D}/kernel-certs/
 install -m 0644 ${S}/msm-kernel/certs/verity_key.pem ${D}/kernel-certs/
 install -m 0644 ${S}/msm-kernel/certs/verity_cert.pem ${D}/kernel-certs/
}

SYSROOT_DIRS += "/kernel-certs"
