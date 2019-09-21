# The MSM Linux minimal boot image files.
# Rootfs creation.

inherit qimage

# use DISTRO_EXTRA_RDEPENDS = "list of packages"
# in distro conf file. These listed packages are specific to distro
# use MACHINE_EXTRA_RDEPENDS = "list of packages"
# these packages are complementary to image and specific to machine.
# specify IMAGE_FEATURES += "ssh-server-openssh" to bring in
#    packagegroup-core-ssh-openssh -> openssh

IMAGE_FEATURES += "ssh-server-openssh"

CORE_IMAGE_EXTRA_INSTALL += "\
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
              start-scripts-post-boot \
              adbd \
              leproperties \
              logd \
              usb-composition \
              systemd-machine-units \
"
# TODO: image featurize mtd to install "mtd-utils-ubifs"
