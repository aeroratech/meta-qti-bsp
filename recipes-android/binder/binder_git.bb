inherit autotools pkgconfig useradd

DESCRIPTION = "Android Binder support"
HOMEPAGE = "http://developer.android.com/"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=89aea4e17d99a7cacdbeed46a0096b10"

DEPENDS += "liblog libcutils libutils system-core-headers libselinux glib-2.0"

FILESPATH =+ "${WORKSPACE}/frameworks/:"
SRC_URI   = "file://binder"

S = "${WORKDIR}/binder"

EXTRA_OECONF += "--with-glib \
                 ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', '--with-systemd', '',d)}"

# This recipe assumes kernel always compile for default arch even when
# multilib compilation is enabled. If kernel is 64bit and binder is compiled
# for 32bit due to multilib settings default 64bit IPC need to be supported
# as kernel is 64bit. Only when kernel is 32bit, 32bit IPC need to be enabled.
EXTRA_OECONF_append_arm = " \
    ${@bb.utils.contains('MULTILIB_VARIANTS', 'lib32','','--enable-32bit-binder-ipc',d)} \
"

# sdmsteppe uses 64bit IPC though userspace is 32bit.
EXTRA_OECONF_remove_sdmsteppe = "--enable-32bit-binder-ipc"

do_install_append() {
   if ${@bb.utils.contains('EXTRA_OECONF', '--with-systemd', 'true', 'false', d)}; then
       if ${@bb.utils.contains('MACHINE_FEATURES', 'qti-vm', 'false', 'true', d)}; then
           install -d ${D}${systemd_unitdir}/system/
           install -d ${D}${systemd_unitdir}/system/multi-user.target.wants/
           # enable the service for multi-user.target
           ln -sf ${systemd_unitdir}/system/servicemanager.service \
               ${D}${systemd_unitdir}/system/multi-user.target.wants/servicemanager.service
       fi
   fi
}

FILES_${PN} += "${systemd_unitdir}/system/"
