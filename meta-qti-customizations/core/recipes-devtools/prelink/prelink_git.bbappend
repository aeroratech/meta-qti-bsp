FILESEXTRAPATHS_prepend := "${THISDIR}:"
SRC_URI = "git://git.yoctoproject.org/prelink-cross.git;branch=cross_prelink_staging \
           file://prelink.conf \
           file://prelink.cron.daily \
           file://prelink.default \
           file://macros.prelink"
PR = "r1"
