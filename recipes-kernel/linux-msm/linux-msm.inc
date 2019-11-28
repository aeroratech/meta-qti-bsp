inherit kernel

DESCRIPTION = "CAF Linux Kernel"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://COPYING;md5=d7810fab7487fb0aad327b76f1be7cd7"

DEPENDS += " mkbootimg-native openssl-native mod-signing-keys"
RDEPENDS_${KERNEL_PACKAGE_NAME}-base = ""

LDFLAGS_aarch64 = "-O1 --hash-style=gnu --as-needed"

DEPENDS_append_aarch64 = " libgcc"
KERNEL_CC_append_aarch64 = " ${TOOLCHAIN_OPTIONS}"
KERNEL_LD_append_aarch64 = " ${TOOLCHAIN_OPTIONS}"

KERNEL_PRIORITY           = "9001"
# Add V=1 to KERNEL_EXTRA_ARGS for verbose
KERNEL_EXTRA_ARGS        += "O=${B}"

FILESPATH =+ "${WORKSPACE}:"
SRC_URI   =  "file://kernel \
              file://overlayfs.cfg \
	      ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'file://systemd.cfg', '', d)} \
              ${@bb.utils.contains('DISTRO_FEATURES', 'virtualization', 'file://virtualization.cfg', '', d)} \
              ${@bb.utils.contains('DISTRO_FEATURES', 'nand-squashfs', 'file://squashfs.cfg', '', d)} \
              ${@bb.utils.contains('DISTRO_FEATURES', 'selinux', 'file://selinux.cfg', '', d)} \
              ${@bb.utils.contains('COMBINED_FEATURES', 'fbdev', 'file://graphics_fb.cfg', '', d)} \
              ${@bb.utils.contains_any('COMBINED_FEATURES', 'qti-camera qti-video mm-camera', 'file://multimedia.cfg', '', d)} \
	     "
SRC_URI_append_sdm845 += "${@bb.utils.contains('DISTRO_FEATURES', 'virtualization', 'file://virtualization_robomaker.cfg', '', d)}"

LINUX_VERSION_EXTENSION_qperf = "-perf"

# returns all the elements from the src uri that are config fragments
def find_sccs(d):
    sources=src_patches(d, True)
    sources_list=[]
    for s in sources:
        base, ext = os.path.splitext(os.path.basename(s))
        if ext and ext in [".scc", ".cfg"]:
            sources_list.append(s)

    return sources_list


do_configure_prepend() {

    if [ ! -f "${S}/arch/${ARCH}/configs/${KERNEL_CONFIG}" ]; then
        bbfatal "KERNEL_CONFIG '${KERNEL_CONFIG}' was specified, but not present in the source tree"
    fi

    sccs_from_src_uri="${@" ".join(find_sccs(d))}"
    ${S}/scripts/kconfig/merge_config.sh -m -r -O ${B} ${S}/arch/${ARCH}/configs/${KERNEL_CONFIG} ${sccs_from_src_uri} 1>&2

    echo "# Global settings from linux recipe" >> ${B}/.config
    echo "CONFIG_LOCALVERSION="\"${LINUX_VERSION_EXTENSION}\" >> ${B}/.config
    echo "CONFIG_MODULE_SIG_KEY="\"${STAGING_DIR_TARGET}/kernel-certs/signing_key.pem\" >> ${B}/.config
}

# append DTB
# msm kernel trees have a special treatment for DTS, and both arm and
# arm64 DTS are located in arch/arm64/boot/dts/qcom folder, which
# confuses kernel-devicetree class, so we can't use it. Instead let's
# make sure that we generate all DTBs using the kernel 'dtbs' target,
# then we can append the DTBs that we need for $MACHINE.
KERNEL_EXTRA_ARGS += "dtbs"

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
        mkdir -p $kerneldir/certs
        cp certs/signing_key.x509 $kerneldir/certs/
}

do_deploy() {
    if [ -f ${D}/${KERNEL_IMAGEDEST}/-${KERNEL_VERSION} ]; then
        mv ${D}/${KERNEL_IMAGEDEST}/-${KERNEL_VERSION} ${D}/${KERNEL_IMAGEDEST}/${KERNEL_IMAGETYPE}-${KERNEL_VERSION}
    fi
}

# Put the zImage in the kernel-dev pkg
FILES_${KERNEL_PACKAGE_NAME}-dev += "/${KERNEL_IMAGEDEST}/${KERNEL_IMAGETYPE}-${KERNEL_VERSION}"
