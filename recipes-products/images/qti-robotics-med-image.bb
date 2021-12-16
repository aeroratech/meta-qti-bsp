# QTI Linux minimal boot image file.
# Provides packages required to build an image with
# boot to console and wifi support.

inherit qimage

# use DISTRO_EXTRA_RDEPENDS = "list of packages"
# in distro conf file. These listed packages are specific to distro
# use MACHINE_EXTRA_RDEPENDS = "list of packages"
# these packages are complementary to image and specific to machine.
# specify IMAGE_FEATURES += "ssh-server-openssh" to bring in
#    packagegroup-core-ssh-openssh -> openssh

IMAGE_FEATURES += "ssh-server-openssh"

CORE_IMAGE_EXTRA_INSTALL += "\
              alsa-utils \
              e2fsprogs \
              e2fsprogs-e2fsck \
              e2fsprogs-mke2fs \
              glib-2.0 \
              kernel-modules \
              packagegroup-android-utils \
              packagegroup-qti-audio \
              ${@bb.utils.contains('COMBINED_FEATURES', 'qti-bluetooth', "packagegroup-qti-bluetooth", "", d)} \
              packagegroup-qti-camera \
              packagegroup-qti-core \
              packagegroup-qti-data \
              packagegroup-qti-display \
              packagegroup-qti-dsp \
              packagegroup-qti-fastcv \
              packagegroup-qti-gfx \
              packagegroup-qti-ss-mgr \
              ${@bb.utils.contains('COMBINED_FEATURES', 'qti-security', "packagegroup-qti-securemsm", "", d)} \
              packagegroup-qti-sensors-see \
              packagegroup-qti-test-sensors-see \
              packagegroup-qti-video \
              ${@bb.utils.contains('COMBINED_FEATURES', 'qti-wifi', "packagegroup-qti-wifi", "", d)} \
              packagegroup-startup-scripts \
              packagegroup-support-utils \
              systemd-machine-units \
              ${@bb.utils.contains('DISTRO_FEATURES','selinux', 'packagegroup-selinux-minimal', '', d)} \
"
