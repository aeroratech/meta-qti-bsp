# Provides packages required to build
# QTI Generic Linux image.

inherit qimage

IMAGE_FEATURES += "ssh-server-openssh"

CORE_IMAGE_EXTRA_INSTALL += "\
        chrony \
        e2fsprogs \
	packagegroup-android-utils-base \
	packagegroup-startup-scripts-base \
        e2fsprogs-e2fsck \
        e2fsprogs-mke2fs \
        glib-2.0 \
        kernel-modules \
        libnl \
        libxml2 \
        systemd-machine-units \
        ${@bb.utils.contains('DISTRO_FEATURES','selinux', 'packagegroup-selinux-minimal', '', d)} \
"
# Install display packages
CORE_IMAGE_EXTRA_INSTALL += " \
            libdrm \
            wayland \
            "
