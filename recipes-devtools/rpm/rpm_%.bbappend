#Remove of bash from rpm
RDEPENDS_${PN}_remove = "bash"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
	file://0001-rpm-shell-changes-to-sh.patch \
	file://0001-rpmdb_loader-script-changes-to-sh.patch \
"

