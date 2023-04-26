DESCRIPTION = "avbtool: Image signing tool"

LICENSE = "Apache-2.0 & BSD-3-Clause & MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10 \
                    file://${COREBASE}/meta/files/common-licenses/BSD-3-Clause;md5=550794465ba0ec5312d6919e203a55f9 \
                    file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

PR = "r1"

FILESEXTRAPATHS_prepend := "${THISDIR}/sigkeys:"
FILESPATH =+ "${WORKSPACE}/external/avb:"
SRC_URI = "file://avbtool"

SRC_URI += "file://qpsa_attest.der"
SRC_URI += "file://qpsa_attest.key"
SRC_URI += "file://qpsa_attestca.der"
SRC_URI += "file://qpsa_attestca.key"
SRC_URI += "file://qpsa_rootca.der"

do_install(){
   install -d ${TMPDIR}/work-shared/avbtool/
   install -m 0555 ${WORKDIR}/avbtool ${TMPDIR}/work-shared/avbtool/

   install -d "${D}${sysconfdir}/keys"
   install -m 0444 ${WORKDIR}/qpsa_rootca.der ${D}${sysconfdir}/keys/x509_root.der
   install -m 0444 ${WORKDIR}/qpsa_attest.key ${TMPDIR}/work-shared/avbtool/
   install -m 0444 ${WORKDIR}/qpsa_attest.der ${TMPDIR}/work-shared/avbtool/
   install -m 0444 ${WORKDIR}/qpsa_attestca.key ${TMPDIR}/work-shared/avbtool/
   install -m 0444 ${WORKDIR}/qpsa_attestca.der ${TMPDIR}/work-shared/avbtool/

}

#don't run these functions
do_configure[noexec] = "1"
do_compile[noexec] = "1"

BBCLASSEXTEND =+ "native nativesdk"
