#Package is fetching from the codelinaro
SRC_URI = "${CLO_LE_GIT}/kmod.git;branch=kmod/master;protocol=https"
 
SRC_URI += " \
           file://depmod-search.conf \
           file://0001-build-Stop-using-dolt.patch \
           file://avoid_parallel_tests.patch \
          "


FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += "file://blacklist.conf \
           "

do_install_append () {
    install -Dm644 "${WORKDIR}/blacklist.conf" "${D}${sysconfdir}/modprobe.d/blacklist.conf"
}
