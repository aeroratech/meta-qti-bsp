require recipes-kernel/linux-msm/linux-msm.inc
COMPATIBLE_MACHINE = "genericarmv8"

SRC_URI   =  "file://kernel/msm-5.4"
S         =  "${WORKDIR}/kernel/msm-5.4"
PR = "r0"

DEPENDS += "llvm-arm-toolchain-native dtc-native rsync-native"

LDFLAGS_aarch64 = "-O1 --hash-style=gnu --as-needed"
TARGET_CXXFLAGS += "-Wno-format"
KERNEL_CC = "${STAGING_BINDIR_NATIVE}/llvm-arm-toolchain/bin/clang -target ${TARGET_ARCH}${TARGET_VENDOR}-${TARGET_OS}"

LIC_FILES_CHKSUM = "file://COPYING;md5=bbea815ee2795b2f4230826c0c6b8814"

do_shared_workdir_append () {
        # Generate kernel headers
        oe_runmake_call -C ${STAGING_KERNEL_DIR} ARCH=${ARCH} CC="${KERNEL_CC}" LD="${KERNEL_LD}" headers_install O=${STAGING_KERNEL_BUILDDIR}
}

do_deploy_append () {
         # Copy vmlinux and zImage into deplydir for boot.img creation
         install -d ${DEPLOYDIR}
         install -m 0644 ${KERNEL_OUTPUT_DIR}/${KERNEL_IMAGETYPE} ${DEPLOYDIR}/${KERNEL_IMAGETYPE}
         install -m 0644 vmlinux ${DEPLOYDIR}
}
