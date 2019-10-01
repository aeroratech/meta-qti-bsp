inherit autotools pkgconfig systemd

DESCRIPTION = "Android media transfer protocol"
HOMEPAGE = "http://developer.android.com/"
LICENSE = "Apache-2.0 & BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10 \
                    file://${COREBASE}/meta/files/common-licenses/\
BSD-3-Clause;md5=550794465ba0ec5312d6919e203a55f9"

DEPENDS += "glib-2.0 libcutils liblog libutils system-core-headers virtual/kernel"

FILESPATH =+ "${WORKSPACE}/frameworks/:"
SRC_URI   = "file://mtp/"
SRC_URI += "file://automtp.sh"

S = "${WORKDIR}/mtp"

EXTRA_OECONF += " \
    --with-kernel-headers=${STAGING_KERNEL_BUILDDIR}/include/uapi \
    --with-glib \
"

do_install_append() {
   if ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'true', 'false', d)}; then
       install -d ${D}${sysconfdir}/udev/scripts/
       install -m 0744 ${WORKDIR}/automtp.sh \
             ${D}${sysconfdir}/udev/scripts/automtp.sh
   fi
}
