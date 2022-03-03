#Package is fetch from the codelinaro

SRC_URI = "${CLO_LE_GIT}/ca-certificates.git;protocol=https;branch=debian/master"

SRC_URI += "\
           file://0002-update-ca-certificates-use-SYSROOT.patch \
           file://0001-update-ca-certificates-don-t-use-Debianisms-in-run-p.patch \
           file://default-sysroot.patch \
           file://0003-update-ca-certificates-use-relative-symlinks-from-ET.patch \
           file://0001-Revert-mozilla-certdata2pem.py-print-a-warning-for-e.patch \
           "
