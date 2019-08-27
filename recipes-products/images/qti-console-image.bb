# The MSM Linux minimal boot image files.
# Rootfs creation.

inherit qimage

# use DISTRO_EXTRA_RDEPENDS = "list of packages"
# in distro conf file. These listed packages are specific to distro
# use MACHINE_EXTRA_RDEPENDS = "list of packages"
# these packages are complementary to image and specific to machine.
# specify IMAGE_FEATURES += "ssh-server-openssh" to bring in
#    packagegroup-core-ssh-openssh -> openssh


DEPENDS = " \
             mkbootimg-native \
             virtual/bootloader \
             pkgconfig-native \
             gtk-doc-native \
             gettext-native \
             e2fsprogs-native \
             ext4-utils-native \
             mtd-utils-native \
             openssl-native \
"

IMAGE_FEATURES += "ssh-server-openssh"

CORE_IMAGE_EXTRA_INSTALL = "\
              binder \
              chrony \
              e2fsprogs \
              e2fsprogs-e2fsck \
              e2fsprogs-mke2fs \
              glib-2.0 \
              kernel-modules \
              libcutils \
              liblog \
              libnl \
              libxml2 \
              start-scripts-firmware-links \
              system-core-adbd \
              system-core-leprop \
              system-core-logd \
              system-core-post-boot \
              system-core-usb \
              systemd-machine-units \
"
# TODO: image featurize mtd to install "mtd-utils-ubifs"
