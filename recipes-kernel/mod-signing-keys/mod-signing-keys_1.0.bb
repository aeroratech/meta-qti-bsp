SUMMARY = "Generates Linux kernel modules signing keys"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"

inherit allarch nopackages

DEPENDS += "openssl-native"

SRC_URI = "file://x509.genkey"

S = "${WORKDIR}"

# generate pair of private/public keys for module signing
do_compile() {
    openssl req -new -nodes -utf8 -sha256 -days 36500 -batch -x509 \
        -config x509.genkey -outform PEM -out signing_key.pem \
        -keyout signing_key.pem
}

do_install() {
    install -d ${D}/kernel-certs
    install -m 0644 signing_key.pem ${D}/kernel-certs/
}

SYSROOT_DIRS += "/kernel-certs"
