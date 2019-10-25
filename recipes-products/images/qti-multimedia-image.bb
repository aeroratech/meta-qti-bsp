
inherit qimage

IMAGE_FEATURES += "ssh-server-openssh"

CORE_IMAGE_EXTRA_INSTALL += "\
        chrony \
        ${@bb.utils.contains('COMBINED_FEATURES', 'qti-display', 'display-hal-linux', '', d)} \
        e2fsprogs \
        e2fsprogs-e2fsck \
        e2fsprogs-mke2fs \
        glib-2.0 \
        kernel-modules \
        libnl \
        libxml2 \
        ${@bb.utils.contains('COMBINED_FEATURES', 'qti-video', 'media', '', d)} \
        packagegroup-android-utils \
        packagegroup-qti-bluetooth \
        packagegroup-qti-data \
        packagegroup-qti-wifi \
        packagegroup-startup-scripts \
        systemd-machine-units \
        wayland \
        weston \
        weston-init \
"
