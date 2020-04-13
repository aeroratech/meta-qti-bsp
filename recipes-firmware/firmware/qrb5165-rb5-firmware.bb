HOMEPAGE         = "http://codeaurora.org"
LICENSE          = "BSD-3-Clause-Clear"
#The above license applies only to this file, the packages installed
#by this file are not subjected to this license
LIC_FILES_CHKSUM = "file://${COREBASE}/meta-qti-bsp/files/common-licenses/\
${LICENSE};md5=aa1caf1ecca146c499d29f5ff4709389"
NO_GENERIC_LICENSE[qrb5165-rb5] = "${COREBSP}/meta-qti-bsp/files/common-license/\
${LICENSE}"

DESCRIPTION = "Recipe installs firmware files on rootfs and NHLOS images\
in DEPLOY_DIR"

inherit deploy

#Set NHLOS_RELEASE_URL to appropriate URL.
NHLOS_RELEASE_URL = "file://qrb5165-rb5/"
#Set NHLOS_RELEASE_NAME to appropriate name of meta zip file.
NHLOS_RELEASE_NAME = "NHLOS-QRB5165.LU.1.2.1-date"
NHLOS_SOURCE = "${NHLOS_RELEASE_URL}${NHLOS_RELEASE_NAME}.tar.gz"

SRC_URI = "${NHLOS_SOURCE}"
S = "${WORKDIR}/"

do_configure[noexec] = "1"
do_compile[noexec]   = "1"
INSANE_SKIP_${PN} += "arch"
INHIBIT_PACKAGE_DEBUG_SPLIT = "1"
INHIBIT_PACKAGE_STRIP = "1"



QTI_ADSP = "\
   adsp.b00 adsp.b01 adsp.b02 adsp.b03 adsp.b04 adsp.b05 \
   adsp.b06 adsp.b07 adsp.b08 adsp.b09 adsp.b10 adsp.b11 \
   adsp.b12 adsp.b13 adsp.b14 adsp.b15 adsp.b16 adsp.b17 \
   adsp.b18 adsp.b19 adsp.mdt adspr.jsn adspua.jsn \
   amss20.bin \
"
QTI_APT_CTA64 = "\
   aptcryptotestapp64.b00 aptcryptotestapp64.b01 aptcryptotestapp64.b02 aptcryptotestapp64.b03 \
   aptcryptotestapp64.b04 aptcryptotestapp64.b05 aptcryptotestapp64.b06 aptcryptotestapp64.b07 \
   aptcryptotestapp64.mdt \
"
QTI_APT_CTA = "\
   aptcryptotestapp.b00 aptcryptotestapp.b01 aptcryptotestapp.b02 aptcryptotestapp.b03 \
   aptcryptotestapp.b04 aptcryptotestapp.b05 aptcryptotestapp.b06 aptcryptotestapp.b07 \
   aptcryptotestapp.mdt \
"
QTI_APT_TA64 = "\
   apttestapp64.b00 apttestapp64.b01 apttestapp64.b02 apttestapp64.b03 apttestapp64.b04 apttestapp64.b05 \
   apttestapp64.b06 apttestapp64.b07 apttestapp64.mdt \
"
QTI_APT_TA = "\
   apttestapp.b00 apttestapp.b01 apttestapp.b02 apttestapp.b03 apttestapp.b04 apttestapp.b05 \
   apttestapp.b06 apttestapp.b07 apttestapp.mdt \
"
QTI_WIFI = "\
   bdwlan.elf bdwlan.e01 bdwlan.e02 bdwlan.e03 bdwlan.e04 bdwlan.e05 \
   bdwlan.e06 bdwlan.e07 bdwlan.e08 bdwlan.e09 bdwlan.e0a bdwlan.e0b \
   bdwlan.e0c bdwlan.e0d bdwlan.e0e bdwlan.e0f bdwlan.e10 bdwlan.e11 \
   bdwlan.e12 bdwlan.e13 bdwlan.e14 bdwlan.e15 bdwlan.e16 bdwlan.e17 \
   bdwlan.e18 bdwlan.e25 asym2p.sig asym2t.sig \
"
QTI_CDSP = "\
   cdsp.b00 cdsp.b01 cdsp.b02 cdsp.b03 cdsp.b04 cdsp.b05 cdsp.b06 cdsp.b08 cdsp.b09 \
   cdsp.b11 cdsp.mdt cdspr.jsn \
"
QTI_CMNLIB = "\
    cmnlib.b00 cmnlib.b01 cmnlib.b02 cmnlib.b03 cmnlib.b04 cmnlib.b05 cmnlib.mdt \
"
QTI_CMNLIB64 = "\
    cmnlib64.b00 cmnlib64.b01 cmnlib64.b02 cmnlib64.b03 cmnlib64.b04 cmnlib64.b05 cmnlib64.mdt \
"
QTI_CVPSS = "\
   cvpss.b00 cvpss.b01 cvpss.b02 cvpss.b03 cvpss.b04 cvpss.b05 cvpss.b06 cvpss.b07 cvpss.b08 \
   cvpss.b09 cvpss.b10 cvpss.b10 cvpss.b19 cvpss.mdt crypt2p.sig crypt2t.sig \
"
QTI_FACE3D = "\
   face3d.b00 face3d.b01 face3d.b02 face3d.b03 face3d.b04 face3d.b05 face3d.b06 face3d.b07 \
   face3d.mdt echo2p.sig echo2t.sig \
"
QTI_FEATENABLER = "\
   featenabler.b00 featenabler.b01 featenabler.b02 featenabler.b03 featenabler.b04 featenabler.b05 \
   featenabler.b06 featenabler.b07 featenabler.mdt \
"
QTI_FINGERPR = "\
   fingerpr.b00 fingerpr.b01 fingerpr.b02 fingerpr.b03 fingerpr.b04 fingerpr.b05 fingerpr.b06 \
   fingerpr.b07 fingerpr.mdt \
"
QTI_HAVENTKN = "\
   haventkn.b00 haventkn.b01 haventkn.b02 haventkn.b03 haventkn.b04 haventkn.b05 haventkn.b06 \
   haventkn.b07 haventkn.mbn haventkn.mdt \
"
QTI_HDCP1 = "\
   hdcp1.b00 hdcp1.b01 hdcp1.b02 hdcp1.b03 hdcp1.b04 hdcp1.b05 hdcp1.b06 hdcp1.b07 hdcp1.mdt \
"
QTI_HDCP2P2 = "\
   hdcp2p2.b00 hdcp2p2.b01 hdcp2p2.b02 hdcp2p2.b03 hdcp2p2.b04 hdcp2p2.b05 hdcp2p2.b06 \
   hdcp2p2.b07 hdcp2p2.mdt \
"
QTI_HDCPSRM = "\
   hdcpsrm.b00 hdcpsrm.b01 hdcpsrm.b02 hdcpsrm.b03 hdcpsrm.b04 hdcpsrm.b05 hdcpsrm.b06 \
   hdcpsrm.b07 hdcpsrm.mdt \
"
QTI_HDCPTEST = "\
   hdcptest.b00 hdcptest.b01 hdcptest.b02 hdcptest.b03 hdcptest.b04 hdcptest.b05 \
   hdcptest.b06 hdcptest.b07 hdcptest.mdt \
"
QTI_IRIS = "\
   iris.b00 iris.b01 iris.b02 iris.b03 iris.b04 iris.b05 iris.b06 iris.b07 iris.mdt \
"
QTI_LOADALGOTA64 = "\
   loadalgota64.b00 loadalgota64.b01 loadalgota64.b02 loadalgota64.b03 loadalgota64.b04 \
   loadalgota64.b05 loadalgota64.b06 loadalgota64.b07 loadalgota64.mdt \
"
QTI_MLDAPTA = "\
   mldapta.b00 mldapta.b01 mldapta.b02 mldapta.b03 mldapta.b04 mldapta.b05 mldapta.b06 \
   mldapta.b07 mldapta.mdt macch2p.sig macch2t.sig \
"
QTI_NPU = "\
   npu.b00 npu.b01 npu.b02 npu.b03 npu.b04 npu.b05 npu.b06 npu.mdt \
"
QTI_SECUREMM = "\
   securemm.b00 securemm.b01 securemm.b02 securemm.b03 securemm.b04 securemm.b05 \
   securemm.b06 securemm.b07 securemm.mdt \
"
QTI_SLPI = "\
   slpi.b00 slpi.b01 slpi.b02 slpi.b03 slpi.b04 slpi.b05 slpi.b06 slpi.b07 slpi.b08 \
   slpi.b09 slpi.b10 slpi.b11 slpi.b12 slpi.b13 slpi.b14 slpi.b15 slpi.b16 slpi.b17 \
   slpi.b18 slpi.b19 slpi.b20 slpi.mdt slpir.jsn slpius.jsn \
"
QTI_SMPLAP32 = "\
   smplap32.b00 smplap32.b01 smplap32.b02 smplap32.b03 smplap32.b04 smplap32.b05 \
   smplap32.b06 smplap32.b07 smplap32.mdt smpl2p.sig smpl2t.sig \
"
QTI_SMPLAP64 = "\
   smplap64.b00 smplap64.b01 smplap64.b02 smplap64.b03 smplap64.b04 smplap64.b05 \
   smplap64.b06 smplap64.b07 smplap64.mdt smpl2p.sig smpl2t.sig \
"
QTI_SOTER64 = "\
   soter64.b00 soter64.b01 soter64.b02 soter64.b03 soter64.b04 soter64.b05 \
   soter64.b06 soter64.b07 soter64.mdt \
"
QTI_SPSS = "\
   spsmt2p.sig spsmt2t.sig spss2p.b00 spss2p.b01 spss2p.b02 spss2p.mdt spss2t.b00 \
   spss2t.b01 spss2t.b02 spss2t.mdt \
"
QTI_VENUS = "\
   venus.b00 venus.b01 venus.b02 venus.b03 venus.b04 venus.b05 venus.b06 venus.b07 \
   venus.b08 venus.b09 venus.b10 venus.b19 venus.mdt \
"
QTI_VOICEPRJ = "\
   voicepri.b00 voicepri.b01 voicepri.b02 voicepri.b03 voicepri.b04 voicepri.b05 \
   voicepri.b06 voicepri.b07 voicepri.mdt \
"
QTI_WIDEVINE = "\
   widevine.b00 widevine.b01 widevine.b02 widevine.b03 widevine.b04 widevine.b05 \
   widevine.b06 widevine.b07 widevine.mdt \
"
QTI_WINSECAP = "\
   winsecap.b00 winsecap.b01 winsecap.b02 winsecap.b03 winsecap.b04 winsecap.b05 \
   winsecap.b06 winsecap.b07 winsecap.mdt wil6436.brd wil6436.fw \
"
QTI_RTIC= "\
   rtic.mbn rtic_tst.mbn \
"
QTI_M3 = "\
   m3.bin \
"
QTI_MODEM = "\
    modem.b00 modem.b01 modem.b02 modem.b03 modem.b09 modem.b12 modem.b13 \
    modem.b14 modem.b15 modem.b16 modem.b19 modem.b20 modem.b21 modem.mdt \
    modem_pr \
"
QTI_KEYMASTER = "\
   keymaster.b00 keymaster.b01 keymaster.b02 keymaster.b03 keymaster.b04 \
   keymaster.b05 keymaster.b06 keymaster.b07 keymaster.mdt \
"
QTI_BT = "\
    btfwnpla.tlv btfwnpls.tlv btnvnpls.bin btnvnpla.bin \
"

do_install () {
    install -m 0755 -d ${D}/firmware
    install -m 0755 -d ${D}/firmware/image
    install -m 0755 -d ${D}/firmware/verinfo
    if [ -f ${S}/verinfo/ver_info.txt ]; then
        install -m 0644 ${S}/verinfo/ver_info.txt ${D}/firmware/verinfo/
    fi
    if [ -f ${S}/fakeboar.bin ]; then
        install -m 0755 ${S}/fakeboar.bin ${D}/firmware/image
    fi
    if [ -f ${S}/mba.mbn ]; then
        install -m 0755 ${S}/mba.mbn ${D}/firmware/image
    fi
    for bin in ${QTI_CMNLIB}; do
       install -m 0755 ${S}/${bin} ${D}/firmware/image/${bin}
    done
    for bin in ${QTI_CMNLIB64}; do
       install -m 0755 ${S}/${bin} ${D}/firmware/image/${bin}
    done

#### Install wifi related firmware split bins conditionally
    if [ ${@bb.utils.contains("COMBINED_FEATURES", "qti-wifi", "true", "", d)} ]; then
        for bin in ${QTI_WIFI}; do
            install -m 0755 ${S}/${bin} -D ${D}/firmware/image/${bin}
        done
    fi
#### Install bt related firware split bins conditionally
    if [ ${@bb.utils.contains("COMBINED_FEATURES", "qti-bluetooth", "true", "", d)} ]; then
        for bin in ${QTI_BT}; do
            install -m 0755 ${S}/${bin} ${D}/firmware/image/${bin}
        done
    fi
#### Install Video firmware bins
    if [ ${@bb.utils.contains("COMBINED_FEATURES", "qti-video", "true", "", d)} ]; then
        for bin in ${QTI_VENUS}; do
            install -m 0755 ${S}/${bin} ${D}/firmware/image/${bin}
        done
    fi

#### Install adsp firmware bins
    if [ ${@bb.utils.contains("COMBINED_FEATURES", "qti-adsp", "true", "", d)} ];then
        for bin in ${QTI_ADSP}; do
            install -m 0755 ${S}/${bin} ${D}/firmware/image/${bin}
        done
    fi
#### Install cdsp firmware bins
    if [ ${@bb.utils.contains("COMBINED_FEATURES", "qti-cdsp", "true", "", d)} ];then
        for bin in ${QTI_CDSP}; do
            install -m 0755 ${S}/${bin} ${D}/firmware/image/${bin}
        done
    fi
#### Install modem firmware bins
    if [ ${@bb.utils.contains("COMBINED_FEATURES", "qti-modem", "true", "", d)} ];then
        for bin in ${QTI_MODEM}; do
            install -m 0755 ${S}/${bin} ${D}/firmware/image/${bin}
        done
    fi

#### Install qrb5165 other firmware  bins by default
#### Install apt test app firmware bins
    for bin in ${QTI_APT_CTA64}; do
       install -m 0755 ${S}/${bin} ${D}/firmware/image/${bin}
    done
    for bin in ${QTI_APT_CTA}; do
       install -m 0755 ${S}/${bin} ${D}/firmware/image/${bin}
    done
    for bin in ${QTI_APT_TA64}; do
       install -m 0755 ${S}/${bin} ${D}/firmware/image/${bin}
    done
    for bin in ${QTI_APT_TA}; do
       install -m 0755 ${S}/${bin} ${D}/firmware/image/${bin}
    done

    for bin in ${QTI_CVPSS}; do
       install -m 0755 ${S}/${bin} ${D}/firmware/image/${bin}
    done
    for bin in ${QTI_FACE3D}; do
       install -m 0755 ${S}/${bin} ${D}/firmware/image/${bin}
    done
	for bin in ${QTI_FINGERPR}; do
       install -m 0755 ${S}/${bin} ${D}/firmware/image/${bin}
    done
	for bin in ${QTI_HAVENTKN}; do
       install -m 0755 ${S}/${bin} ${D}/firmware/image/${bin}
    done
    for bin in ${QTI_HDCP1}; do
       install -m 0755 ${S}/${bin} ${D}/firmware/image/${bin}
    done
    for bin in ${QTI_HDCP2P2}; do
       install -m 0755 ${S}/${bin} ${D}/firmware/image/${bin}
    done
	for bin in ${QTI_HDCPSRM}; do
       install -m 0755 ${S}/${bin} ${D}/firmware/image/${bin}
    done
	for bin in ${QTI_HDCPTEST}; do
       install -m 0755 ${S}/${bin} ${D}/firmware/image/${bin}
    done

    for bin in ${QTI_IRIS}; do
       install -m 0755 ${S}/${bin} ${D}/firmware/image/${bin}
    done
    for bin in ${QTI_LOADALGOTA64}; do
       install -m 0755 ${S}/${bin} ${D}/firmware/image/${bin}
    done
    for bin in ${QTI_MLDAPTA}; do
       install -m 0755 ${S}/${bin} ${D}/firmware/image/${bin}
    done
    for bin in ${QTI_NPU}; do
       install -m 0755 ${S}/${bin} ${D}/firmware/image/${bin}
    done
    for bin in ${QTI_SECUREMM}; do
       install -m 0755 ${S}/${bin} ${D}/firmware/image/${bin}
    done
    for bin in ${QTI_SLPI}; do
       install -m 0755 ${S}/${bin} ${D}/firmware/image/${bin}
    done
    for bin in ${QTI_SMPLAP32}; do
       install -m 0755 ${S}/${bin} ${D}/firmware/image/${bin}
    done
    for bin in ${QTI_SMPLAP64}; do
       install -m 0755 ${S}/${bin} ${D}/firmware/image/${bin}
    done
    for bin in ${QTI_SOTER64}; do
       install -m 0755 ${S}/${bin} ${D}/firmware/image/${bin}
    done
    for bin in ${QTI_SPSS}; do
       install -m 0755 ${S}/${bin} ${D}/firmware/image/${bin}
    done
    for bin in ${QTI_VOICEPRJ}; do
       install -m 0755 ${S}/${bin} ${D}/firmware/image/${bin}
    done
    for bin in ${QTI_WIDEVINE}; do
       install -m 0755 ${S}/${bin} ${D}/firmware/image/${bin}
    done
    for bin in ${QTI_FACE3D}; do
       install -m 0755 ${S}/${bin} ${D}/firmware/image/${bin}
    done
    for bin in ${QTI_WINSECAP}; do
       install -m 0755 ${S}/${bin} ${D}/firmware/image/${bin}
    done
    for bin in ${QTI_RTIC}; do
       install -m 0755 ${S}/${bin} ${D}/firmware/image/${bin}
    done
    for bin in ${QTI_M3}; do
       install -m 0755 ${S}/${bin} ${D}/firmware/image/${bin}
    done

}

do_deploy () {
    install -d ${DEPLOYDIR}
    if [ -f ${S}/prog_firehose_ddr.mbn ];then
        install -m 0755 ${S}/prog_firehose_ddr.mbn ${DEPLOYDIR}
    fi
    if [ -f ${S}/xbl.elf ]; then
        install -m 0755 ${S}/xbl.elf ${DEPLOYDIR}
    fi
    if [ -f ${S}/xbl.elf ]; then
        install -m 0755 ${S}/xbl_config.elf ${DEPLOYDIR}
    fi
    if [ -f ${S}/xbl.elf ]; then
        install -m 0755 ${S}/xbl_config.elf ${DEPLOYDIR}
    fi
    if [ -f ${S}/xbl.elf ]; then
        install -m 0755 ${S}/uefi_sec.mbn ${DEPLOYDIR}
    fi
    if [ -f ${S}/xbl.elf ]; then
        install -m 0755 ${S}/uefi_sec.mbn ${DEPLOYDIR}
    fi
    if [ -f ${S}/spunvm.bin ]; then
        install -m 0755 ${S}/spunvm.bin ${DEPLOYDIR}
    fi
    if [ -f ${S}/qupv3fw.elf ]; then
        install -m 0755 ${S}/qupv3fw.elf ${DEPLOYDIR}
    fi
    if [ -f ${S}/multi_image.mbn ]; then
        install -m 0755 ${S}/multi_image.mbn ${DEPLOYDIR}
    fi
    if [ -f ${S}/cmnlib64.mbn ]; then
        install -m 0755 ${S}/cmnlib64.mbn ${DEPLOYDIR}
    fi
    if [ -f ${S}//cmnlib.mbn ]; then
        install -m 0755 ${S}/cmnlib.mbn ${DEPLOYDIR}
    fi
    if [ -f ${S}/multi_image.mbn ]; then
        install -m 0755 ${S}/cmnlib64.mbn ${DEPLOYDIR}
    fi
    if [ -f ${S}/tz.mbn ]; then
        install -m 0755 ${S}/tz.mbn ${DEPLOYDIR}
    fi
    if [ -f ${S}/dspso.bin ]; then
        install -m 0755 ${S}/dspso.bin ${DEPLOYDIR}
    fi
    if [ -f ${S}/devcfg.mbn ]; then
        install -m 0755 ${S}/devcfg.mbn ${DEPLOYDIR}
    fi
    if [ -f ${S}/apdp.mbn ]; then
        install -m 0755 ${S}/apdp.mbn ${DEPLOYDIR}
    fi
    if [ -f ${S}/aop.mbn ]; then
        install -m 0755 ${S}/aop.mbn ${DEPLOYDIR}
    fi
}

addtask deploy after do_install

FILES_${PN} += "/firmware/*"
PACKAGE_ARCH = "${MACHINE_ARCH}"
INSANE_SKIP_${PN} = "arch already-stripped"
