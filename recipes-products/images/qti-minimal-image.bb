# QTI Linux minimal boot image file.
# Provides packages required to build an image with
# boot to console

inherit qimage

IMAGE_FEATURES += "read-only-rootfs persist-volume"

CORE_IMAGE_EXTRA_INSTALL += "\
              glib-2.0 \
              kernel-modules \
              systemd-machine-units \
              packagegroup-android-utils \
              packagegroup-startup-scripts \
"

