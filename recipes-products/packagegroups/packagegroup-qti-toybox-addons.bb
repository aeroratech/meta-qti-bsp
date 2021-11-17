
SUMMARY = "Set of base utils provided by busybox but missing in toybox"
DESCRIPTION = "Package group bringing in much needed utility packages missing in toybox. \
               This is supposed to be used along with toybox in absence of busybox."

LICENSE = "BSD-3-Clause-Clear"

inherit packagegroup

PACKAGE_ARCH = "${MACHINE_ARCH}"

RDEPENDS_${PN} = "\
    base-passwd \
    bash \
    bind-utils \
    bzip2 \
    dhcp-client \
    diffutils \
    e2fsprogs \
    gawk \
    gzip \
    iproute2 \
    iputils \
    kmod \
    less \
    ncurses-tools \
    net-tools \
    parted \
    patch \
    psmisc \
    shadow-base \
    tar \
    time \
    unzip \
    wget \
    which \
    xz \
    "
