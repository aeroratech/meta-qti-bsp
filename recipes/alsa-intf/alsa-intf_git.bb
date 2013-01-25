inherit autotools

DESCRIPTION = "ALSA Framework Library"
LICENSE = "Apache-2.0"
PR = "r3"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/${LICENSE};md5=89aea4e17d99a7cacdbeed46a0096b10"
DEPENDS = "acdbloader glib-2.0"

SRC_URI = "file://${WORKSPACE}/qcom-opensource/mm-audio"
prefix="/etc"

S = "${WORKDIR}/mm-audio"

EXTRA_OECONF += "--prefix=/etc \
                 --with-kernel=${STAGING_KERNEL_DIR} \
                 --with-sanitized-headers=${STAGING_KERNEL_DIR}/usr/include \
                 --with-glib"

FILES_${PN} += "${prefix}/snd_soc_msm/*"
