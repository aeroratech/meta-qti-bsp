PR = "r157"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}-${PV}:"

#re-use non-perf settings
BASEMACHINE = "${@d.getVar('MACHINE', True).replace('-perf', '')}"

SRC_URI += "file://umountfs"
SRC_URI += "file://bsp_paths.sh"

do_install_append() {
        update-rc.d -f -r ${D} mountnfs.sh remove
        update-rc.d -f -r ${D} urandom remove

	install -m 0755 ${WORKDIR}/bsp_paths.sh  ${D}${sysconfdir}/init.d
	update-rc.d -r ${D} bsp_paths.sh start 15 2 3 4 5 .
}
