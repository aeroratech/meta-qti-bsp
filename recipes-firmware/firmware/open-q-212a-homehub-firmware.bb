HOMEPAGE         = "http://codeaurora.org"
LICENSE          = "BSD-3-Clause-Clear"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta-qti-bsp/files/common-licenses/\
${LICENSE};md5=aa1caf1ecca146c499d29f5ff4709389"
NO_GENERIC_LICENSE[open-q-212a-homehub] = "${COREBSP}/meta-qti-bsp/files/common-license/\
${LICENSE}"

DESCRIPTION = "Recipe installs firmware files on rootfs and NHLOS images\
in DEPLOY_DIR"

inherit deploy

#Set NHLOS_RELEASE_URL to appropriate URL.
NHLOS_RELEASE_URL = "file://"
#Set NHLOS_RELEASE_NAME to appropriate name of meta zip file.
NHLOS_RELEASE_NAME = "NHLOS_Binaries"
NHLOS_SOURCE = "${NHLOS_RELEASE_URL}${NHLOS_RELEASE_NAME}.zip"

SRC_URI = "${NHLOS_SOURCE}"
S = "${WORKDIR}/${NHLOS_RELEASE_NAME}"

do_configure[noexec] = "1"
do_compile[noexec]   = "1"

QTI_WIFI_NAPLES = "\
    athwlan.bin bdwlan30.bin otp.bin otp30.bin qwlan30.bin utf.bin utf30.bin \
"

QTI_WIFI_PRONTO = "\
    athwlan.bin bdwlan30.bin otp.bin otp30.bin qwlan30.bin utf.bin utf30.bin \
    wcnss.b00 wcnss.b01 wcnss.b02 wcnss.b04 wcnss.b06 wcnss.b09 wcnss.b10 \
    wcnss.b11 wcnss.b12 wcnss.mdt \
"

QTI_WIFI_ROME = "\
    athwlan.bin bdwlan30.bin otp.bin otp30.bin qwlan30.bin utf.bin utf30.bin \
"

QTI_CMNLIB = "\
    cmnlib.b00 cmnlib.b01 cmnlib.b02 cmnlib.b03 cmnlib.b04 cmnlib.b05 \
    cmnlib.mdt \
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

QTI_VIDEO = "\
    venus.b00 venus.b01 venus.b02 venus.b03 venus.b04 venus.mdt \
"

do_install () {
    install -m 0755 -d ${D}/firmware
    install -m 0755 -d ${D}/firmware/image
    install -m 0755 -d ${D}/firmware/verinfo
    if [ -f ${S}/verinfo/ver_info.txt ]; then
        install -m 0644 ${S}/verinfo/ver_info.txt ${D}/firmware/verinfo/
    fi
    install -m 0755 ${S}/fakeboar.bin ${D}/firmware/image
    install -m 0755 ${S}/mba.mbn ${D}/firmware/image
    for bin in ${QTI_CMNLIB}; do
       install -m 0755 ${S}/${bin} ${D}/firmware/image/${bin}
    done
    for bin in ${QTI_KEYMASTER}; do
       install -m 0755 ${S}/${bin} ${D}/firmware/image/${bin}
    done

#### Install wifi related firmware split bins conditionally
    if [ ${@bb.utils.contains("COMBINED_FEATURES", "qti-wifi", "true", "", d)} ]; then
        if [ ${@bb.utils.contains("MACHINE_FEATURES", "naples", "true", "", d)} ]; then
            BIN_LIST="${QTI_WIFI_NAPLES}"
        fi
        if [ ${@bb.utils.contains("MACHINE_FEATURES", "pronto", "true", "", d)} ]; then
            BIN_LIST="${QTI_WIFI_PRONTO}"
        fi
        if [ ${@bb.utils.contains("MACHINE_FEATURES", "rome", "true", "", d)} ]; then
            BIN_LIST="${QTI_WIFI_ROME}"
        fi
        for bin in ${BIN_LIST}; do
            install -m 0755 ${S}/${bin} -D ${D}/firmware/image/${bin}
        done
    fi

#### Install bt related firware split bins conditionally
    if [ ${@bb.utils.contains("COMBINED_FEATURES", "qti-bluetooth", "true", "", d)} ]; then
        for bin in ${QTI_BT}; do
            install -m 0755 ${S}/${bin} ${D}/firmware/image/${bin}
        done
    fi
#### Install Video firmware
    if [ ${@bb.utils.contains("COMBINED_FEATURES", "qti-video", "true", "", d)} ]; then
        for bin in ${QTI_VIDEO}; do
            install -m 0755 ${S}/${bin} ${D}/firmware/image/${bin}
        done
    fi
#### Install modem firmware when either audio or modem is active
    if [ ${@bb.utils.contains_any("COMBINED_FEATURES", "qti-modem qti-audio", "true", "", d)} ];then
        for bin in ${QTI_MODEM}; do
            if [ -f ${S}/${bin} ]; then
                install -m 0755 ${S}/${bin} ${D}/firmware/image/${bin}
            fi
            if [ -d ${S}/${bin} ]; then
                for f in $(find ${S}/${bin} -type f -printf "%P\n"); do
                    install -m 0755 -D ${S}/${bin}/${f} ${D}/firmware/image/${bin}/${f}
                done
            fi
        done
    fi
}

do_deploy () {
    install -d ${DEPLOYDIR}
    if [ -f ${S}/prog_emmc_firehose_8909_ddr.mbn ];then
        install -m 0755 ${S}/prog_emmc_firehose_8909_ddr.mbn ${DEPLOYDIR}
    fi
    if [ -f ${S}/sbl1.mbn ]; then
        install -m 0755 ${S}/sbl1.mbn ${DEPLOYDIR}
    fi
    if [ -f ${S}/rpm.mbn ]; then
        install -m 0755 ${S}/rpm.mbn ${DEPLOYDIR}
    fi
    if [ -f ${S}/tz.mbn ]; then
        install -m 0755 ${S}/tz.mbn ${DEPLOYDIR}
    fi
    if [ -f ${S}/sec.dat ]; then
        install -m 0755 ${S}/sec.dat ${DEPLOYDIR}
    fi
    if [ -f ${S}/devcfg.mbn ]; then
        install -m 0755 ${S}/devcfg.mbn ${DEPLOYDIR}
    fi
    if [ -f ${S}/cmnlib.mbn ]; then
        install -m 0755 ${S}/cmnlib.mbn ${DEPLOYDIR}
    fi
    if [ -f ${S}/keymaster64.mbn ]; then
        install -m 0755 ${S}/keymaster64.mbn ${DEPLOYDIR}
    fi
}

addtask deploy after do_install

FILES_${PN} += "/firmware/*"
PACKAGE_ARCH = "${MACHINE_ARCH}"
INSANE_SKIP_${PN} = "arch already-stripped"
