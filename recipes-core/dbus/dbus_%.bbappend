include dbus.inc

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += "file://extra-users.conf"
SRC_URI += "file://dbus.conf"
SRC_URI += "file://extra-users-reboot.conf"
SRC_URI += "${@bb.utils.contains('MACHINE_FEATURES', 'qti-remoteproc', 'file://pmlite-dbus.conf', '', d)}"

INITSCRIPT_NAME = "dbus-1"
INITSCRIPT_PARAMS = "start 98 5 3 2 . stop 02 0 1 6 ."

GROUPADD_PARAM_${PN} = "-r netdev"

do_install_append() {
   install -d ${D}/${datadir}/dbus-1/system.d/
   install -m 0644 ${WORKDIR}/extra-users.conf -D ${D}${datadir}/dbus-1/system.d/extra-users.conf
   if ${@bb.utils.contains('MACHINE_FEATURES', 'qti-remoteproc', 'true', 'false', d)}; then
      install -m 0644 ${WORKDIR}/pmlite-dbus.conf -D ${D}${datadir}/dbus-1/system.d/pmlite-dbus.conf
   fi
   if ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'true', 'false', d)}; then
      install -d ${D}${systemd_unitdir}/system/sockets.target.wants
      ln -fs ../dbus.service ${D}${systemd_system_unitdir}/sockets.target.wants/dbus.service
      rm -rf ${D}${systemd_system_unitdir}/multi-user.target.wants/dbus.service

      install -d ${D}/lib/systemd/system/dbus.service.d
      install -m 0666 ${WORKDIR}/dbus.conf ${D}/lib/systemd/system/dbus.service.d/dbus.conf
      install -m 0644 ${WORKDIR}/extra-users-reboot.conf -D ${D}${datadir}/dbus-1/system.d/extra-users-reboot.conf
   fi
}


