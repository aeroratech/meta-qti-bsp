inherit autotools pkgconfig

BBCLASSEXTEND += "native"

DESCRIPTION = "Verity utilites"
HOMEPAGE = "http://developer.android.com/"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/\
${LICENSE};md5=89aea4e17d99a7cacdbeed46a0096b10"

DEPENDS = "libgcc libmincrypt libsparse zlib openssl bouncycastle"

FILESPATH =+ "${WORKSPACE}/system/extras/:"
SRC_URI = "file://verity \
           file://ext4_utils \
           file://../core/include \
           file://../core/mkbootimg"


S = "${WORKDIR}/verity"

do_editveritysigner () {
    sed -i -e '/^java/d' ${S}/verity_signer
    echo 'java -Xmx512M -jar ${STAGING_LIBDIR}/VeritSigner.jar "$@"' >> ${S}/verity_signer
}

addtask do_editveritysigner after do_compile before do_install

#NATIVE_INSTALL_WORKS="1"
