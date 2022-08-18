inherit kernel

DESCRIPTION = "CAF Linux Kernel"
LICENSE = "GPLv2.0-with-linux-syscall-note"

COMPATIBLE_MACHINE = "cinder"

FILESPATH =+ "${WORKSPACE}:"

SRC_URI   =  "file://kernel-${PV}/kernel_platform/msm-kernel \
             ${@oe.utils.conditional('KERNEL_USE_PREBUILTS', 'True', '', 'file://kernel-${PV}/kernel_platform/msm-kernel/arch/${ARCH}/configs/${KERNEL_CONFIG}',d)} \
             "

S = "${WORKDIR}/kernel-${PV}/kernel_platform/msm-kernel"
PR = "r0"

DEPENDS += "kernel-toolchain-native dtc-android-build-native rsync-native"

LDFLAGS_aarch64 = "-O1 --hash-style=gnu --as-needed"
TARGET_CXXFLAGS += "-Wno-format"
KERNEL_CC = "${STAGING_BINDIR_NATIVE}/clang/bin/clang -target ${TARGET_ARCH}${TARGET_VENDOR}-${TARGET_OS}"

LIC_FILES_CHKSUM = "file://COPYING;md5=6bc538ed5bd9a7fc9398086aedcd7e46"

KERNEL_USE_PREBUILTS = "${@d.getVar('MACHINE_USES_KERNEL_PREBUILTS') or "False"}"

#dts path is changed to vendor/qcom
DTBO_SRC_PATH = "${STAGING_KERNEL_BUILDDIR}/arch/${ARCH}/boot/dts/vendor/qcom/"
KERNEL_CONFIG_COMMAND ?= "oe_runmake_call -C ${S} CC="${KERNEL_CC}" LD="${KERNEL_LD}" O=${B} || oe_runmake -C ${S} O=${B} CC="${KERNEL_CC}" LD="${KERNEL_LD}""
get_cc_option () {
:
}

DEPENDS += " virtual/mkbootimg-native openssl-native mod-signing-keys"
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

# Don't set any version extention on debug build
LINUX_VERSION_EXTENSION ?= "-perf"
LINUX_VERSION_EXTENSION_qti-distro-debug = ""

# returns all the elements from the src uri that are config fragments
def find_sccs(d):
    sources=src_patches(d, True)
    sources_list=[]
    for s in sources:
        base, ext = os.path.splitext(os.path.basename(s))
        if ext and ext in [".config"]:
            sources_list.append(s)

    return sources_list

# dm-verity: Patch the cert file from which kernel add key to keyring
do_patch_veritycert() {
   cp -f ${WORKDIR}/verity.x509.pem ${S}/certs/verity.x509.pem
}

do_patch[postfuncs] += " ${@bb.utils.contains('DISTRO_FEATURES', 'dm-verity', bb.utils.contains('MACHINE_FEATURES', 'dm-verity-bootloader', 'do_patch_veritycert', '', d), '', d)}"

do_configure_prepend() {
    if [ ! -f "${WORKDIR}/kernel-${PV}/kernel_platform/msm-kernel/arch/${ARCH}/configs/${KERNEL_CONFIG}" ]; then
        bbfatal "KERNEL_CONFIG '${KERNEL_CONFIG}' was specified, but not present in the source tree"
    fi

    sccs_from_src_uri="${@" ".join(find_sccs(d))}"
    ${S}/scripts/kconfig/merge_config.sh -m -r -y -O ${B} ${WORKDIR}/kernel-${PV}/kernel_platform/msm-kernel/arch/${ARCH}/configs/${KERNEL_CONFIG} ${sccs_from_src_uri} 1>&2

    echo "# Global settings from linux recipe" >> ${B}/.config
    echo "CONFIG_LOCALVERSION="\"${LINUX_VERSION_EXTENSION}\" >> ${B}/.config
    echo "CONFIG_MODULE_SIG_KEY="\"${STAGING_DIR_TARGET}/kernel-certs/signing_key.pem\" >> ${B}/.config
    if ${@bb.utils.contains('DISTRO_FEATURES', 'dm-verity', bb.utils.contains('MACHINE_FEATURES', 'dm-verity-initramfs', 'true', 'false', d), 'false', d)}; then
        echo "CONFIG_SYSTEM_TRUSTED_KEYS="\"${STAGING_DIR_TARGET}/kernel-certs/verity_cert.pem\" >> ${B}/.config
    fi
}

# Set up hosttools for techpack module compilation
do_setup_module_compilation() {
    cd ${WORKSPACE}/kernel-${PREFERRED_VERSION_linux-msm}/kernel_platform  && \
          BUILD_CONFIG=${KERNEL_BUILD_CONFIG} \
          OUT_DIR=${KERNEL_OUT_PATH}/ \
          KERNEL_UAPI_HEADERS_DIR=${STAGING_KERNEL_BUILDDIR} \
          INSTALL_MODULE_HEADERS=1 \
          ./build/build_module.sh
}

do_prebuilt_configure[nostamp] = "1"
do_prebuilt_configure() {
    cd ${KERNEL_PREBUILT_PATH}

    install -d ${B}/include/config
    install -d ${B}/include/generated
    install -d ${B}/scripts
    install -d ${B}/certs
    # Some of the artifacts needed for module compilation are present under
    # msm-kernel path, for now copy them for this path to avoid build failures.
    # Ask prebuilt providers to make these available in KERNEL_PREBUILT_PATH.
    install -m 0644 ../msm-kernel/.config ${B}
    install -m 0644 ../msm-kernel/Module.symvers ${B}
    install -m 0644 ../msm-kernel/include/config/kernel.release ${B}/include/config/kernel.release
    install -m 0644 ../msm-kernel/scripts/module.lds ${B}/scripts/module.lds
    install -m 0755 ../msm-kernel/scripts/sign-file ${B}/scripts/sign-file
    install -m 0755 ../msm-kernel/certs/signing_key.x509 ${B}/certs/signing_key.x509
    install -m 0755 ../msm-kernel/certs/signing_key.pem ${B}/certs/signing_key.pem
    install -m 0644 ../msm-kernel/include/generated/utsrelease.h ${B}/include/generated

    install -d ${B}/${KERNEL_OUTPUT_DIR}
    for typeformake in ${KERNEL_IMAGETYPE_FOR_MAKE} ; do
        install -m 0644 ${typeformake} ${B}/${KERNEL_OUTPUT_DIR}
    done
    install -m 0644 vmlinux ${B}
    install -m 0644 System.map ${B}
    # copy initramfs scripts
    install -d ${B}/usr
    cp -R ../msm-kernel/usr/gen_init_cpio ${B}/usr
    cp -R ../msm-kernel/usr/initramfs_data.cpio ${B}/usr
    cp -R ../msm-kernel/usr/initramfs_inc_data ${B}/usr
    # gen_initramfs.sh is present in kernel source
    cp -R ../../../kernel_platform/msm-kernel/usr/gen_initramfs.sh ${B}/usr
}

do_prebuilt_shared_workdir[nostamp] = "1"
do_prebuilt_shared_workdir[cleandirs] += " ${STAGING_KERNEL_BUILDDIR}"
do_prebuilt_shared_workdir() {
    cd ${B}

    kerneldir=${STAGING_KERNEL_BUILDDIR}
    install -d $kerneldir

    #
    # Store the kernel version in sysroots for module-base.bbclass
    #

    echo "${KERNEL_VERSION}" > $kerneldir/${KERNEL_PACKAGE_NAME}-abiversion

    # Copy files required for module builds
    install -m 0644 System.map $kerneldir/System.map-${KERNEL_VERSION}
    [ -e Module.symvers ] && install -m 0644 Module.symvers $kerneldir/
    install -m 0644 .config $kerneldir/
    mkdir -p $kerneldir/include/config
    mkdir -p $kerneldir/scripts
    mkdir -p $kerneldir/certs
    install -m 0755 ${B}/scripts/sign-file ${STAGING_KERNEL_BUILDDIR}/scripts/sign-file
    install -m 0755 ${B}/certs/signing_key.x509 ${STAGING_KERNEL_BUILDDIR}/certs/signing_key.x509
    install -m 0755 ${B}/certs/signing_key.pem ${STAGING_KERNEL_BUILDDIR}/certs/signing_key.pem
    install -m 0644 include/config/kernel.release $kerneldir/include/config/kernel.release
    if [ -e "${B}/scripts/module.lds" ]; then
        install -m 0644 ${B}/scripts/module.lds ${STAGING_KERNEL_BUILDDIR}/scripts/module.lds
    fi
}

do_prebuilt_install[dirs] = "${B}"
fakeroot do_prebuilt_install() {
    #
    # Install various kernel output (zImage, map file, config, module support files)
    # From prebuilt paths
    #
    install -d ${D}/${KERNEL_IMAGEDEST}
    install -d ${D}/boot
    for imageType in ${KERNEL_IMAGETYPES} ; do
        install -m 0644 ${KERNEL_OUTPUT_DIR}/${imageType} ${D}/${KERNEL_IMAGEDEST}/${imageType}-${KERNEL_VERSION}
        if [ "${KERNEL_PACKAGE_NAME}" = "kernel" ]; then
            ln -sf ${imageType}-${KERNEL_VERSION} ${D}/${KERNEL_IMAGEDEST}/${imageType}
        fi
    done
    install -m 0644 System.map ${D}/boot/System.map-${KERNEL_VERSION}
    install -m 0644 .config ${D}/boot/config-${KERNEL_VERSION}
    install -m 0644 vmlinux ${D}/boot/vmlinux-${KERNEL_VERSION}
    [ -e Module.symvers ] && install -m 0644 Module.symvers ${D}/boot/Module.symvers-${KERNEL_VERSION}
    install -d ${D}${sysconfdir}/modules-load.d
    install -d ${D}${sysconfdir}/modprobe.d

    # Copied files may cause host contamination due to invalid UID. Change ownership to root.
    find ${D} -name '*' -exec chown -h root:root {} \;
}

# Must be ran no earlier than after do_kernel_checkout or else Makefile won't be in ${S}/Makefile
PREBUILT_DISCARDED_TASKS += "\
    do_configure \
    do_compile \
    do_kernel_link_images \
    do_compile_kernelmodules \
    do_shared_workdir \
    do_install \
"
python () {
    if d.getVar('KERNEL_USE_PREBUILTS') == 'True':
        for task in d.getVar('PREBUILT_DISCARDED_TASKS').split():
            d.setVarFlag(task, 'noexec', '1')
        bb.build.addtask('do_prebuilt_configure', 'do_configure', 'do_unpack', d)
        bb.build.addtask('do_setup_module_compilation', 'do_configure', 'do_unpack', d)
        bb.build.addtask('do_prebuilt_install', 'do_install', 'do_compile', d)
        bb.build.addtask('do_prebuilt_shared_workdir', 'do_compile_kernelmodules', 'do_compile', d)
}

# append DTB
# msm kernel trees have a special treatment for DTS, and both arm and
# arm64 DTS are located in arch/arm64/boot/dts/qcom folder, which
# confuses kernel-devicetree class, so we can't use it. Instead let's
# make sure that we generate all DTBs using the kernel 'dtbs' target,
# then we can append the DTBs that we need for $MACHINE.
KERNEL_EXTRA_ARGS += "dtbs"
KERNEL_EXTRA_ARGS += "DTC_EXT=${STAGING_DIR_NATIVE}/usr/bin/dtc/bin/dtc"

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

        cp Makefile $kerneldir/
        cp -fR usr $kerneldir/

        cp include/config/auto.conf $kerneldir/include/config/auto.conf

        if [ -d arch/${ARCH}/include ]; then
                mkdir -p $kerneldir/arch/${ARCH}/include/
                cp -fR arch/${ARCH}/include/* $kerneldir/arch/${ARCH}/include/
        fi

        if [ -d arch/${ARCH}/boot ]; then
                mkdir -p $kerneldir/arch/${ARCH}/boot/
                cp -fR arch/${ARCH}/boot/* $kerneldir/arch/${ARCH}/boot/
        fi

        # Generate kernel headers
        oe_runmake_call -C ${STAGING_KERNEL_DIR} ARCH=${ARCH} CC="${KERNEL_CC}" LD="${KERNEL_LD}" headers_install O=${STAGING_KERNEL_BUILDDIR}
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

    # copy initramfs scripts
     install -d ${DEPLOYDIR}/build-artifacts
     install -d ${DEPLOYDIR}/build-artifacts/kernel_scripts/scripts
     install -d ${DEPLOYDIR}/build-artifacts/kernel_scripts/usr/
     install -d ${DEPLOYDIR}/build-artifacts/dtb

     cp -a ${B}/usr/gen_initramfs.sh ${DEPLOYDIR}/build-artifacts/kernel_scripts/scripts
     cp -a ${B}/usr/gen_init_cpio ${DEPLOYDIR}/build-artifacts/kernel_scripts/usr/
     cp -a ${B}/usr/initramfs_data.cpio ${DEPLOYDIR}/build-artifacts/kernel_scripts/usr/
     cp -a ${B}/usr/initramfs_inc_data ${DEPLOYDIR}/build-artifacts/kernel_scripts/usr/
     cp -a ${KERNEL_PREBUILT_PATH}/*.dtb ${DEPLOYDIR}/build-artifacts/dtb
}

# Put the zImage in the kernel-dev pkg
FILES_${KERNEL_PACKAGE_NAME}-dev += "/${KERNEL_IMAGEDEST}/${KERNEL_IMAGETYPE}-${KERNEL_VERSION}"
