DESCRIPTION = "QTI Fastrpc Kernel drivers"
LICENSE = "GPL-2.0"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=801f80980d171dd6425610833a22dbe6"

SUMMARY = "adsprpc-kernel libraries"

inherit autotools linux-kernel-base deploy

PR = "r0"

DEPENDS = "rsync-native"
DEPENDS += "bc-native bison-native"

do_configure[depends] += "virtual/kernel:do_shared_workdir"

FILESPATH   =+ "${WORKSPACE}:"
SRC_URI     =  "file://vendor/qcom/opensource/dsp-kernel/"
SRC_URI     += "file://start_dsp_le"
SRC_URI     += "file://dsp.service"

S = "${WORKDIR}/vendor/qcom/opensource/dsp-kernel"

EXTRA_OEMAKE += "TARGET_SUPPORT=${BASEMACHINE}"

# Disable parallel make
PARALLEL_MAKE = ""

# Disable parallel make
PARALLEL_MAKE = "-j1"

do_configure() {
  cp -f ${WORKSPACE}/vendor/qcom/opensource/dsp-kernel/Makefile.am ${WORKSPACE}/vendor/qcom/opensource/dsp-kernel/Makefile
  cp -f ${WORKSPACE}/vendor/qcom/opensource/dsp-kernel/Kbuild.am ${WORKSPACE}/vendor/qcom/opensource/dsp-kernel/Kbuild
}

do_compile() {
  cd ${WORKSPACE}/kernel-${PREFERRED_VERSION_linux-msm}/kernel_platform  &&
  BUILD_CONFIG=msm-kernel/build.config.msm.${VM_TARGET}.tuivm \
  EXT_MODULES=../../vendor/qcom/opensource/dsp-kernel \
  ROOTDIR=${WORKSPACE}/ \
  MODULE_OUT=${WORKDIR}/vendor/qcom/opensource/dsp-kernel \
  OUT_DIR=temp_out_dir \
  KERNEL_KIT=${KERNEL_OUT_PATH}/ \
  KERNEL_UAPI_HEADERS_DIR=${STAGING_KERNEL_BUILDDIR} \
  CONFIG_MSM_ADSPRPC_TRUSTED=1 \
  ./build/build_module.sh
}

do_install() {
  install -d ${D}${sysconfdir}/initscripts
  install -d ${D}${systemd_unitdir}/system/multi-user.target.wants/
  install -d ${D}/include/linux
  install -m 755 ${WORKDIR}/start_dsp_le ${D}${sysconfdir}/initscripts
  install -m 0755 ${WORKDIR}/vendor/qcom/opensource/dsp-kernel/frpc-trusted-adsprpc.ko -D ${WORKDIR}/frpc-trusted-adsprpc.ko
  # strip debug symbols and sign the module
  ${STAGING_DIR_NATIVE}/usr/libexec/aarch64-oe-linux/gcc/aarch64-oe-linux/9.3.0/strip \
        --strip-debug ${WORKDIR}/vendor/qcom/opensource/dsp-kernel/frpc-trusted-adsprpc.ko

  LD_LIBRARY_PATH=${WORKSPACE}/kernel-${PREFERRED_VERSION_linux-msm}/kernel_platform/prebuilts/kernel-build-tools/linux-x86/lib64/ \
  ${KERNEL_PREBUILT_PATH}/../msm-kernel/scripts/sign-file sha1 ${KERNEL_PREBUILT_PATH}/../msm-kernel/certs/signing_key.pem \
  ${KERNEL_PREBUILT_PATH}/../msm-kernel/certs/signing_key.x509 ${WORKDIR}/vendor/qcom/opensource/dsp-kernel/frpc-trusted-adsprpc.ko

  install -m 0755 ${WORKDIR}/vendor/qcom/opensource/dsp-kernel/frpc-trusted-adsprpc.ko -D ${D}${libdir}/modules/frpc-trusted-adsprpc.ko
  install -m 0644 ${WORKDIR}/dsp.service -D ${D}${systemd_unitdir}/system/dsp.service
  ln -sf ${systemd_unitdir}/system/dsp.service ${D}${systemd_unitdir}/system/multi-user.target.wants/dsp.service
}

do_deploy() {
  cp -rp ${WORKDIR}/frpc-trusted-adsprpc.ko ${DEPLOYDIR}/
}

addtask do_deploy after do_install

FILES_${PN} += "${sysconfdir}/*"
FILES_${PN} += "/etc/initscripts/start_dsp_le"
FILES_${PN} += "${libdir}/modules/*"
FILES_${PN} += "${systemd_unitdir}/system/dsp.service"
FILES_${PN} += "${systemd_unitdir}/system/multi-user.target.wants/dsp.service"
