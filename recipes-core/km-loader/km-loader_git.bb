inherit systemd

DESCRIPTION = "Kernel Module Loader"
PR = "r0"

LICENSE          = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/${LICENSE};md5=550794465ba0ec5312d6919e203a55f9"

FILESPATH =+ "${WORKSPACE}:"

SRC_URI += "file://evdev_load.service"
SYSTEMD_SERVICE_${PN} += "evdev_load.service"

do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install () {
      # Place mount_event_driver.service in systemd unitdir
      install -d ${D}${systemd_unitdir}/system/
      install -m 0644 ${WORKDIR}/evdev_load.service  \
          -D ${D}${systemd_unitdir}/system/evdev_load.service

}

