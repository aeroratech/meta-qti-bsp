FILESEXTRAPATHS_prepend := "${THISDIR}/systemd:"

SRC_URI += "file://Disable-unused-mount-points.patch"
SRC_URI += "file://systemd-udevd.service"
SRC_URI += "file://ffbm.target"
SRC_URI += "file://mtpserver.rules"
SRC_URI += "file://ion.rules"
SRC_URI += "file://kgsl.rules"
SRC_URI += "file://set-usb-nodes.rules"
SRC_URI += "file://sysctl.conf"
SRC_URI += "file://platform.conf"
SRC_URI += "${@bb.utils.contains('MACHINE_FEATURES', 'qti-vm', 'file://trusted_touch.conf', '',d)}"
SRC_URI += "file://sd-bus-Allow-extra-users-to-communicate.patch"
SRC_URI += "file://set-mhi-nodes.rules"
SRC_URI += "file://99-gpiochardev.rules"

# Custom setup for PACKAGECONFIG to get a slimmer systemd.
# Removed following:
#   * backlight - Loads/Saves Screen Backlight Brightness, not required.
#   * firstboot - initializes the most basic system settings interactively
#                  on the first boot if /etc is empty, not required.
#   * hostname  - No need to change the system's hostname
#   * ldconfig  - configures dynamic linker run-time bindings.
#                 ldconfig  creates  the  necessary links and cache to the most
#                 recent shared libraries found in the directories specified on
#                 the command line, in the file /etc/ld.so.conf, and in the
#                 trusted directories (/lib and /usr/lib).  The cache (created
#                 at /etc/ld.so.cache) is used by the run-time linker ld-linux.so.
#                 system-ldconfig.service runs "ldconfig -X", but as / is RO
#                 cache may not be created. Disabling this may introduce app
#                 start time latency.
#   * localed   - Service used to change the system locale settings, not needed.
#   * machined  - For tracking local Virtual Machines and Containers, not needed.
#   * networkd  - Manages network configurations, custom solution is used.
#   * polkit    - Not used.
#   * quotacheck- Not using Quota.
#   * resolvd   - Use custom network name resolution manager.
#   * smack     - Not used.
#   * timesyncd - Chronyd is being used instead for NTP timesync.
#                 Also timesyncd was resulting in higher boot KPI.
#   * utmp      - No back fill for SysV runlevel changes needed.
#   * vconsole  - Not used.
PACKAGECONFIG = " \
    ${@bb.utils.filter('DISTRO_FEATURES', 'selinux', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wifi', 'rfkill', '', d)} \
    acl \
    binfmt \
    coredump \
    hibernate \
    ima \
    ${@bb.utils.contains('MACHINE_FEATURES', 'qti-sdx', '', 'kmod', d)} \
    ${@bb.utils.contains('MACHINE_FEATURES', 'qti-sdx', '', 'logind', d)} \
    randomseed \
    timedated \
    xz \
"
# Don't support coredump generation for user builds.
PACKAGECONFIG_remove_qti-distro-user = "coredump"

EXTRA_OEMESON += " -Defi=false"
EXTRA_OEMESON += " -Dhwdb=false"

CFLAGS_append = " -fPIC"

# In aarch64 targets systemd is not booting with -finline-functions -finline-limit=64 optimizations
# So temporarily revert to default optimizations for systemd.
SELECTED_OPTIMIZATION = "-O2 -fexpensive-optimizations -frename-registers -fomit-frame-pointer -ftree-vectorize"

do_install_append () {
   install -d ${D}/etc/systemd/system/
   install -d ${D}/lib/systemd/system/ffbm.target.wants
   install -d ${D}/etc/systemd/system/ffbm.target.wants
   rm ${D}/lib/udev/rules.d/60-persistent-v4l.rules

   # Place systemd-udevd.service in /etc/systemd/system
   install -m 0644 ${WORKDIR}/systemd-udevd.service \
       -D ${D}/etc/systemd/system/systemd-udevd.service
   install -m 0644 ${WORKDIR}/ffbm.target \
       -D ${D}/etc/systemd/system/ffbm.target

   # Enable logind/getty/password-wall service in FFBM mode
   ln -sf /lib/systemd/system/systemd-logind.service ${D}/lib/systemd/system/ffbm.target.wants/systemd-logind.service
   ln -sf /lib/systemd/system/getty.target ${D}/lib/systemd/system/ffbm.target.wants/getty.target
   ln -sf /lib/systemd/system/systemd-ask-password-wall.path ${D}/lib/systemd/system/ffbm.target.wants/systemd-ask-password-wall.path
   install -d /etc/sysctl.d/
   install -m 0644 ${WORKDIR}/sysctl.conf -D ${D}/etc/sysctl.d/sysctl.conf
   install -m 0644 ${WORKDIR}/platform.conf -D ${D}/etc/tmpfiles.d/platform.conf

   if ${@bb.utils.contains('MACHINE_FEATURES', 'qti-vm', 'true', 'false', d)}; then
       install -m 0644 ${WORKDIR}/trusted_touch.conf -D ${D}/etc/tmpfiles.d/trusted_touch.conf
   fi

   #  Mask journaling services by default.
   #  'systemctl unmask' can be used on device to enable them if needed.
   if [ "${SYSTEMD_ENABLE_JOURNAL}" != "1" ]; then
       ln -sf /dev/null ${D}/etc/systemd/system/systemd-journald.service
       ln -sf /dev/null ${D}${systemd_unitdir}/system/sysinit.target.wants/systemd-journal-flush.service
       ln -sf /dev/null ${D}${systemd_unitdir}/system/sysinit.target.wants/systemd-journal-catalog-update.service
       ln -sf /dev/null ${D}${systemd_unitdir}/system/sockets.target.wants/systemd-journald-audit.socket
       ln -sf /dev/null ${D}${systemd_unitdir}/system/sockets.target.wants/systemd-journald-dev-log.socket
       ln -sf /dev/null ${D}${systemd_unitdir}/system/sockets.target.wants/systemd-journald.socket
   fi
   install -d ${D}${sysconfdir}/udev/rules.d/
   install -m 0644 ${WORKDIR}/ion.rules -D ${D}${sysconfdir}/udev/rules.d/ion.rules
   install -m 0644 ${WORKDIR}/kgsl.rules -D ${D}${sysconfdir}/udev/rules.d/kgsl.rules
   install -m 0644 ${WORKDIR}/set-mhi-nodes.rules -D ${D}${sysconfdir}/udev/rules.d/set-mhi-nodes.rules
   install -m 0644 ${WORKDIR}/99-gpiochardev.rules -D ${D}${sysconfdir}/udev/rules.d/99-gpiochardev.rules

   # Mask dev-ttyS0.device
   ln -sf /dev/null ${D}/etc/systemd/system/dev-ttyS0.device

   # Update persistent-storage.rules to create bootdevice/by-name symlinks
   sed -i 's/LABEL="persistent_storage_end"/# block\/bootdevice\/by-name links'"\n"'LABEL="persistent_storage_end"/g' \
       ${D}/lib/udev/rules.d/60-persistent-storage.rules
   sed -i 's/LABEL="persistent_storage_end"/ENV{ID_PART_ENTRY_SCHEME}=="gpt", ENV{ID_PART_ENTRY_NAME}=="?*", SYMLINK+="block\/bootdevice\/by-name\/$env{ID_PART_ENTRY_NAME}"'"\n\n"'LABEL="persistent_storage_end"/g' \
       ${D}/lib/udev/rules.d/60-persistent-storage.rules
}

# Run fsck as part of local-fs-pre.target instead of local-fs.target
do_install_append () {
   # remove from After
   sed -i '/After/s/local-fs-pre.target//' ${D}${systemd_unitdir}/system/systemd-fsck@.service
   # Add to Before
   sed -i '/Before/s/$/ local-fs-pre.target/' ${D}${systemd_unitdir}/system/systemd-fsck@.service
}

RRECOMMENDS_${PN}_remove += "systemd-extra-utils"
PACKAGES_remove += "${PN}-extra-utils"

FILES_${PN} += "/etc/initscripts \
                ${sysconfdir}/udev/rules.d ${userfsdatadir}/*"
