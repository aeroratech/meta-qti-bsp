SUMMARY = "Basic programs and scripts required to encrypt userdata"
DESCRIPTION = "Package group to bring in all basic packages for userdata encryption"
LICENSE = "BSD-3-Clause"

inherit packagegroup

PROVIDES = "${PACKAGES}"
RPROVIDES_${PN} = "${PACKAGES}"

PACKAGES = ' \
    ${PN} \
    '

RDEPENDS_${PN} = "\
    cryptsetup \
    e2fsprogs-mke2fs \
    cryptinit \
    "
