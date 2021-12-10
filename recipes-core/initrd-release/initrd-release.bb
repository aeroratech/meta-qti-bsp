inherit allarch

SUMMARY = "Initial RAM disk identification"
DESCRIPTION = "/etc/os-release file helps systemd to identify ramdisk boot."

LICENSE = "BSD-3-Clause-Clear"

INHIBIT_DEFAULT_DEPS = "1"

do_fetch[noexec] = "1"
do_unpack[noexec] = "1"
do_patch[noexec] = "1"
do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install () {
  install -dm 0755 ${D}/etc
  touch ${D}/etc/initrd-release
}

FILES_${PN} += " /etc/initrd-release "
