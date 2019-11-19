inherit native autotools-brokensep pkgconfig deploy

SUMMARY = "ptool compliant partition generation utility"
DESCRIPTION = "Generates partition.xml in ptool suitable format and passes the same to ptool to generte partition bins"
SECTION = "devel"

LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = " \
   file://${COREBASE}/meta/files/common-licenses/BSD-3-Clause;md5=550794465ba0ec5312d6919e203a55f9 \
"

DEPENDS += "ptool"
RDEPENDS_${PN} += "python"

FILESEXTRAPATHS_prepend := "${THISDIR}:"

MACHINE_PARTITION_CONF ??= "${MACHINE}-partition.conf"

S = "${WORKDIR}"

SRC_URI = " \
    file://gen_partition.py \
    file://${MACHINE_PARTITION_CONF} \
"

do_configure[noexec] = "1"
do_install[noexec] = "1"

python do_compile () {
    import subprocess
    cmd = ("python gen_partition.py -i " + d.getVar("MACHINE_PARTITION_CONF", True) + " -o partition.xml")
    ret = subprocess.call(cmd, shell=True)
    if ret != 0:
        bb.error("Running: %s failed." % cmd)

    # partition.xml is ready. Pass it to ptool
    cmd = ("python " + d.getVar("STAGING_BINDIR_NATIVE") + "/" + "ptool.py -x " + "partition.xml")
    ret = subprocess.call(cmd, shell=True)
    if ret != 0:
        bb.error("Running: %s failed." % cmd)
}

do_deploy () {
    install -d ${DEPLOYDIR}
    install ${S}/*.bin ${DEPLOYDIR}
    install ${S}/*.xml ${DEPLOYDIR}
}
addtask deploy before do_build after do_compile

BBCLASSEXTEND = "nativesdk"
