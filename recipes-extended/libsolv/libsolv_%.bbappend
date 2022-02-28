#Package is fetch from the CLO
SRC_URI = "${CLO_LE_GIT}/libsolv.git;protocol=https;branch=libsolv/master"
SRC_URI += "\
        file://CVE-2021-3200.patch \
        "

