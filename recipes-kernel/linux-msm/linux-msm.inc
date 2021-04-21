inherit kernel

DESCRIPTION = "CAF Linux Kernel"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://COPYING;md5=d7810fab7487fb0aad327b76f1be7cd7"

DEPENDS += " mkbootimg-native openssl-native mod-signing-keys mkdtimg-native"
RDEPENDS_${KERNEL_PACKAGE_NAME}-base = ""

LDFLAGS_aarch64 = "-O1 --hash-style=gnu --as-needed"

DEPENDS_append_aarch64 = " libgcc"
KERNEL_CC_append_aarch64 = " ${TOOLCHAIN_OPTIONS}"
KERNEL_LD_append_aarch64 = " ${TOOLCHAIN_OPTIONS}"

KERNEL_PRIORITY           = "9001"
# Add V=1 to KERNEL_EXTRA_ARGS for verbose
KERNEL_EXTRA_ARGS        += "O=${B}"

# Additional configs needed for supporting DTBO partition.
DTBO_MACHINE = "${@d.getVar('MACHINE_SUPPORTS_DTBO') or "False"}"

FILESPATH =+ "${WORKSPACE}:"
SRC_URI   =  "file://kernel \
              file://overlayfs.cfg \
	      ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'file://systemd.cfg', '', d)} \
              ${@bb.utils.contains('DISTRO_FEATURES', 'virtualization', 'file://virtualization.cfg', '', d)} \
              ${@bb.utils.contains('DISTRO_FEATURES', 'nand-squashfs', 'file://squashfs.cfg', '', d)} \
              ${@bb.utils.contains('DISTRO_FEATURES', 'selinux', 'file://selinux.cfg', '', d)} \
              ${@bb.utils.contains('DISTRO_FEATURES', 'dm-verity', bb.utils.contains('MACHINE_FEATURES', 'dm-verity-bootloader', 'file://verity.x509.pem', '', d), '', d)} \
              ${@oe.utils.conditional('DTBO_MACHINE', 'True', 'file://dt_overlay.cfg', '',d)} \
              ${@bb.utils.contains('DISTRO_FEATURES', 'dm-verity', 'file://verity.cfg', '', d)} \
              ${@bb.utils.contains('COMBINED_FEATURES', 'qti-audio', 'file://audio_common.cfg', '', d)} \
	      "
SRC_URI_append_qcs610 += "${@bb.utils.contains('COMBINED_FEATURES', 'qti-audio', 'file://audio_targets.cfg', '', d)}"
SRC_URI_append_sdxlemur += "${@bb.utils.contains('MACHINE_FEATURES', 'qti-audio', 'file://0001-ALSA-uapi-add-check-to-avoid-duplicate-include-of-ti.patch', '', d)}"
SRC_URI_append_qrb5165 += "${@bb.utils.contains('DISTRO_FEATURES', 'virtualization', 'file://virtualization_robomaker.cfg', '', d)}"

# Don't set any version extention on debug build
LINUX_VERSION_EXTENSION ?= "-perf"
LINUX_VERSION_EXTENSION_qti-distro-debug = ""

# returns all the elements from the src uri that are config fragments
def find_sccs(d):
    sources=src_patches(d, True)
    sources_list=[]
    for s in sources:
        base, ext = os.path.splitext(os.path.basename(s))
        if ext and ext in [".scc", ".cfg"]:
            sources_list.append(s)

    return sources_list

# dm-verity: Patch the cert file from which kernel add key to keyring
do_patch_veritycert() {
   cp -f ${WORKDIR}/verity.x509.pem ${S}/certs/verity.x509.pem
}

do_patch[postfuncs] += " ${@bb.utils.contains('DISTRO_FEATURES', 'dm-verity', bb.utils.contains('MACHINE_FEATURES', 'dm-verity-bootloader', 'do_patch_veritycert', '', d), '', d)}"

do_configure_prepend() {

    if [ ! -f "${S}/arch/${ARCH}/configs/${KERNEL_CONFIG}" ]; then
        bbfatal "KERNEL_CONFIG '${KERNEL_CONFIG}' was specified, but not present in the source tree"
    fi

    sccs_from_src_uri="${@" ".join(find_sccs(d))}"
    ${S}/scripts/kconfig/merge_config.sh -m -r -O ${B} ${S}/arch/${ARCH}/configs/${KERNEL_CONFIG} ${sccs_from_src_uri} 1>&2

    echo "# Global settings from linux recipe" >> ${B}/.config
    echo "CONFIG_LOCALVERSION="\"${LINUX_VERSION_EXTENSION}\" >> ${B}/.config
    echo "CONFIG_MODULE_SIG_KEY="\"${STAGING_DIR_TARGET}/kernel-certs/signing_key.pem\" >> ${B}/.config
    if ${@bb.utils.contains('DISTRO_FEATURES', 'dm-verity', bb.utils.contains('MACHINE_FEATURES', 'dm-verity-initramfs', 'true', 'false', d), 'false', d)}; then
        echo "CONFIG_SYSTEM_TRUSTED_KEYS="\"${STAGING_DIR_TARGET}/kernel-certs/verity_cert.pem\" >> ${B}/.config
    fi
}

# append DTB
# msm kernel trees have a special treatment for DTS, and both arm and
# arm64 DTS are located in arch/arm64/boot/dts/qcom folder, which
# confuses kernel-devicetree class, so we can't use it. Instead let's
# make sure that we generate all DTBs using the kernel 'dtbs' target,
# then we can append the DTBs that we need for $MACHINE.
KERNEL_EXTRA_ARGS += "dtbs"
KERNEL_EXTRA_ARGS += "DTC_EXT=${STAGING_DIR_NATIVE}/usr/bin/dtc"

do_compile_append() {
    for dtbf in ${KERNEL_DTB_NAMES}; do
        dtbs="$dtbs arch/${ARCH}/boot/dts/$dtbf"
    done
    cp arch/${ARCH}/boot/${KERNEL_IMAGETYPE} arch/${ARCH}/boot/${KERNEL_IMAGETYPE}.backup
    cat arch/${ARCH}/boot/${KERNEL_IMAGETYPE}.backup $dtbs > arch/${ARCH}/boot/${KERNEL_IMAGETYPE}
    rm -f arch/${ARCH}/boot/${KERNEL_IMAGETYPE}.backup
}

# when using our own module signing key kernel.bbclass will fail to copy the public part of the key
# since it checks if the .pem file exists which is not the case, so we need to explicitely copy
# the x509 (public key) file
do_shared_workdir_append () {
    if [ -e certs/signing_key.x509 ]; then
        mkdir -p $kerneldir/certs
        cp certs/signing_key.x509 $kerneldir/certs/
    fi
}
# Path for dtbo generation is kernel version dependent.
DTBO_SRC_PATH ?= "${STAGING_KERNEL_BUILDDIR}/arch/${ARCH}/boot/dts/qcom/"

do_deploy() {
    if [ -f ${D}/${KERNEL_IMAGEDEST}/-${KERNEL_VERSION} ]; then
        mv ${D}/${KERNEL_IMAGEDEST}/-${KERNEL_VERSION} ${D}/${KERNEL_IMAGEDEST}/${KERNEL_IMAGETYPE}-${KERNEL_VERSION}
    fi

    # Copy vmlinux and zImage into deplydir for boot.img creation
    install -d ${DEPLOYDIR}
    install -m 0644 ${KERNEL_OUTPUT_DIR}/${KERNEL_IMAGETYPE} ${DEPLOYDIR}/${KERNEL_IMAGETYPE}
    install -m 0644 vmlinux ${DEPLOYDIR}
    install -m 0644 System.map ${DEPLOYDIR}

    # copy dtbo files into deplydir and create dtbo.img if DTBO support enable
    if [  "${DTBO_MACHINE}" == "True" ]; then
        install -m 0644 ${DTBO_SRC_PATH}/*.dtbo ${DEPLOYDIR}
        mkdtimg create ${DEPLOYDIR}/dtbo.img \
             --page_size=${PAGE_SIZE} \
             ${DEPLOYDIR}/*.dtbo

    fi
}

# Put the zImage in the kernel-dev pkg
FILES_${KERNEL_PACKAGE_NAME}-dev += "/${KERNEL_IMAGEDEST}/${KERNEL_IMAGETYPE}-${KERNEL_VERSION}"
