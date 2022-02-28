SRCREV = "b10e14218646d8b74773b82b0f8b395bce698fa2"
FILESEXTRAPATHS_prepend := "${THISDIR}:"
SRC_URI = "${CLO_LE_GIT}/platform/external/prelink-cross.git;branch=caf_migration/yocto/cross_prelink_staging;protocol=https \
           file://prelink.conf \
           file://prelink.cron.daily \
           file://prelink.default \
           file://macros.prelink"
PR = "r1"
