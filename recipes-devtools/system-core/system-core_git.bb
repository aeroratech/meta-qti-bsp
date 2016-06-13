inherit autotools pkgconfig update-rc.d

DESCRIPTION = "Android system/core components"
HOMEPAGE = "http://developer.android.com/"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=89aea4e17d99a7cacdbeed46a0096b10"

FILESPATH =+ "${WORKSPACE}:"
SRC_URI   = "file://system/core/"

S = "${WORKDIR}/system/core"
PR = "r17"

DEPENDS = "virtual/kernel openssl glib-2.0 libselinux safe-iop ext4-utils"

EXTRA_OECONF = " --with-host-os=${HOST_OS} --with-glib"
EXTRA_OECONF_append = " --with-sanitized-headers=${STAGING_KERNEL_BUILDDIR}/usr/include"

CPPFLAGS += "-I${STAGING_INCDIR}/ext4_utils"
CPPFLAGS += "-I${STAGING_INCDIR}/libselinux"

do_install_append() {
   install -m 0755 ${S}/adb/start_adbd -D ${D}${sysconfdir}/init.d/adbd
   install -m 0755 ${S}/usb/start_usb -D ${D}${sysconfdir}/init.d/usb
   install -m 0755 ${S}/rootdir/etc/init.qcom.post_boot.sh -D ${D}${sysconfdir}/init.d/init_qcom_post
   install -m 0755 ${S}/usb/usb_composition -D ${D}${base_sbindir}/
   install -d ${D}${base_sbindir}/usb/compositions/
   install -m 0755 ${S}/usb/compositions/* -D ${D}${base_sbindir}/usb/compositions/
   install -m 0755 ${S}/usb/target -D ${D}${base_sbindir}/usb/
   install -d ${D}${base_sbindir}/usb/debuger/
   install -m 0755 ${S}/usb/debuger/debugFiles -D ${D}${base_sbindir}/usb/debuger/
   install -m 0755 ${S}/usb/debuger/help -D ${D}${base_sbindir}/usb/debuger/
   install -m 0755 ${S}/usb/debuger/usb_debug -D ${D}${base_sbindir}/
   ln -s  /sbin/usb/compositions/9025 ${D}${base_sbindir}/usb/boot_hsusb_composition
   ln -s  /sbin/usb/compositions/empty ${D}${base_sbindir}/usb/boot_hsic_composition
}

INITSCRIPT_PACKAGES =+ "${PN}-usb"
INITSCRIPT_NAME_${PN}-usb = "usb"
INITSCRIPT_PARAMS_${PN}-usb = "start 30 S ."

PACKAGES =+ "${PN}-adbd-dbg ${PN}-adbd ${PN}-adbd-dev"
FILES_${PN}-adbd-dbg = "${base_sbindir}/.debug/adbd ${libdir}/.debug/libadbd.*"
FILES_${PN}-adbd     = "${base_sbindir}/adbd ${sysconfdir}/init.d/adbd ${libdir}/libadbd.so.*"
FILES_${PN}-adbd-dev = "${libdir}/libadbd.so ${libdir}/libadbd.la"

PACKAGES =+ "${PN}-usb-dbg ${PN}-usb"
FILES_${PN}-usb-dbg  = "${bindir}/.debug/usb_composition_switch"
FILES_${PN}-usb      = "${sysconfdir}/init.d/usb ${base_sbindir}/usb_composition ${bindir}/usb_composition_switch ${base_sbindir}/usb/compositions/*"
FILES_${PN}-usb     += "${base_sbindir}/usb/* ${base_sbindir}/usb_debug ${base_sbindir}/usb/debuger/*"

PACKAGES =+ "${PN}-init-qcom-post"
FILES_${PN}-init-qcom-post = " ${sysconfdir}/init.d/init_qcom_post"
INSANE_SKIP_${PN}-init-qcom-post = "file-rdeps"

FILES_${PN}-dbg  = "${bindir}/.debug/fs_mgr ${bindir}/.debug/logwrapper ${bindir}/.debug/sync_test"
FILES_${PN}-dbg += "${libdir}/.debug/libfs_mgr.* ${libdir}/.debug/liblogwrap.* ${libdir}/.debug/libsync.*"
FILES_${PN}-dbg += "${libdir}/.debug/libbase.* ${libdir}/.debug/libutils.*"
FILES_${PN}      = "${bindir}/fs_mgr ${bindir}/logwrapper ${bindir}/sync_test ${libdir}/pkgconfig/*"
FILES_${PN}     += "${libdir}/libfs_mgr.so.* ${libdir}/liblogwrap.so.* ${libdir}/libsync.so.* ${libdir}/libbase.so.* ${libdir}/libutils.so.*"
FILES_${PN}-dev  = "${libdir}/libfs_mgr.so ${libdir}/libfs_mgr.la ${libdir}/liblogwrap.so ${libdir}/liblogwrap.la ${libdir}/libsync.so ${libdir}/libsync.la"
FILES_${PN}-dev += "${libdir}/libbase.so ${libdir}/libbase.la ${libdir}/libutils.so ${libdir}/libutils.la ${includedir}*"
