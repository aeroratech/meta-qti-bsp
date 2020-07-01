PR = "r157"

inherit systemd

SRC_URI += "file://umountfs"
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
         install -d ${D}/etc/systemd/system/multi-user.target.wants/
         install -m 0644 ${WORKDIR}/logging-restrictions.service -D ${D}/etc/systemd/logging-restrictions.service
         # enable logging-restrict service for multi-user.target
         ln -sf /etc/systemd/logging-restrictions.service \
              ${D}/etc/systemd/system/multi-user.target.wants/logging-restrictions.service
}
