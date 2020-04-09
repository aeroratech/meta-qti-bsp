PR = "r157"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}-${PV}:"

SRC_URI += "file://umountfs"
SRC_URI += "file://bsp_paths.sh"
SRC_URI += "file://set_core_pattern.sh"
SRC_URI += "file://bsp_paths.service"
SRC_URI += "file://set_core_pattern.service"
SRC_URI += "file://logging-restrictions.sh"
SRC_URI += "file://logging-restrictions.service"

do_install_append() {
         rm  ${D}${sysconfdir}/init.d/halt
         rm  ${D}${sysconfdir}/init.d/reboot
         rm  ${D}${sysconfdir}/init.d/save-rtc.sh
         rm  ${D}${sysconfdir}/init.d/sendsigs
         rm  ${D}${sysconfdir}/init.d/single
         rm  ${D}${sysconfdir}/init.d/sysfs.sh
         rm  ${D}${sysconfdir}/init.d/umountfs
         rm  ${D}${sysconfdir}/init.d/umountnfs.sh
         if [ "${TARGET_ARCH}" = "arm" ]; then
               rm  ${D}${sysconfdir}/init.d/alignment.sh
         fi
         install -d ${D}${sysconfdir}/initscripts
         install -m 0755 ${WORKDIR}/bsp_paths.sh  ${D}${sysconfdir}/initscripts/bsp_paths.sh
         install -m 0755 ${WORKDIR}/set_core_pattern.sh  ${D}${sysconfdir}/initscripts/set_core_pattern.sh
         install -m 0755 ${WORKDIR}/logging-restrictions.sh -D ${D}${sysconfdir}/initscripts/logging-restrictions.sh
         install -d ${D}/etc/systemd/system/
         install -m 0644 ${WORKDIR}/bsp_paths.service -D ${D}/etc/systemd/system/bsp_paths.service
         install -d ${D}/etc/systemd/system/multi-user.target.wants/
         # enable the service for multi-user.target
         ln -sf /etc/systemd/system/bsp_paths.service \
              ${D}/etc/systemd/system/multi-user.target.wants/bsp_paths.service

         install -m 0644 ${WORKDIR}/set_core_pattern.service -D ${D}/etc/systemd/system/set_core_pattern.service
         # enable the service for multi-user.target
         ln -sf /etc/systemd/system/set_core_pattern.service \
              ${D}/etc/systemd/system/multi-user.target.wants/set_core_pattern.service

         install -m 0644 ${WORKDIR}/logging-restrictions.service -D ${D}/etc/systemd/logging-restrictions.service
         # enable logging-restrict service for multi-user.target
         ln -sf /etc/systemd/logging-restrictions.service \
	      ${D}/etc/systemd/system/multi-user.target.wants/logging-restrictions.service
}
