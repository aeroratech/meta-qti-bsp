FILESEXTRAPATHS_prepend := "${THISDIR}/systemd:"

SRC_URI += "file://sysctl-coredump.conf"
SRC_URI += "file://limits-coredump.conf"

# Modify default CONFFILES as per machine needs

# Don't install coredump.conf for user builds.
COREDUMP = "1"
COREDUMP_qti-distro-user = ""

SYSTEMD_COREDUMP_PATH ?= "${userfsdatadir}/coredump"

do_install_append() {
   if [ "${COREDUMP}" == "1" ]; then
       sed -i "s#@COREDUMP_PATH@#${SYSTEMD_COREDUMP_PATH}#" ${WORKDIR}/sysctl-coredump.conf

       install -m 0644 ${WORKDIR}/sysctl-coredump.conf -D ${D}${sysconfdir}/sysctl.d/sys-coredump.conf
       install -m 0644 ${WORKDIR}/limits-coredump.conf -D ${D}${sysconfdir}/security/limits.d/sys-coredump.conf

       #create coredump folder if needed
       install -m 0666 -d ${D}${SYSTEMD_COREDUMP_PATH}
   else
       rm -f ${D}${sysconfdir}/systemd/coredump.conf
   fi

   if ${@bb.utils.contains('MACHINE_FEATURES', 'qti-vm', 'true', 'false', d)}; then
      sed -i -e 's/.*RuntimeMaxUse.*/RuntimeMaxUse=5M/' ${D}${systemd_unitdir}/journald.conf.d/00-${PN}.conf
      if ${@bb.utils.contains('BASEMACHINE', 'trustedvm-v2', 'true', 'false', d)}; then
         sed -i 's/ForwardToSyslog/ForwardToKMsg/g' ${D}${systemd_unitdir}/journald.conf.d/00-${PN}.conf
      fi
   fi
}

FILES_${PN} += "${sysconfdir}/sysctl.d/* ${sysconfdir}/security/limits.d/* ${SYSTEMD_COREDUMP_PATH}"

# journald.conf
do_install_append() {
}

# logind.conf
do_install_append() {
    # Ignore PowerKey
    sed -i '$aHandlePowerKey=ignore' ${D}${systemd_unitdir}/logind.conf.d/00-${PN}.conf
}

# system.conf
do_install_append() {
    # Set LogTarget as syslog
    sed -i '$aLogTarget=syslog' ${D}${systemd_unitdir}/system.conf.d/00-${PN}.conf
}

# user.conf
do_install_append() {
}
