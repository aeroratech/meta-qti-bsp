# QTI Linux mbb minimal image file.
# Provides packages required to build an mbb minimal image with
# boot to console

inherit qimage qramdisk

IMAGE_FEATURES += "read-only-rootfs persist-volume"

CORE_IMAGE_EXTRA_INSTALL += "\
              glib-2.0 \
              kernel-modules \
              coreutils \
              powerapp \
              binder \
              powerapp-powerconfig \
              powerapp-reboot \
              powerapp-shutdown \
              systemd-machine-units \
              packagegroup-android-utils \
              packagegroup-startup-scripts \
              packagegroup-qti-data \
              packagegroup-qti-core \
              packagegroup-qti-securemsm \
              packagegroup-qti-ss-mgr \
              ${@bb.utils.contains('MACHINE_FEATURES', 'qti-location', 'packagegroup-qti-location', '', d)} \
              ${@bb.utils.contains('DISTRO_FEATURES','selinux', 'packagegroup-selinux-minimal', '', d)} \
"
