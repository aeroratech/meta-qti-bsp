# Provides packages required to build
# QTI Linux eXtended Reality image for Neo.

require qti-xreality-image.bb

# Remove unsupported package groups
CORE_IMAGE_EXTRA_INSTALL_remove = "packagegroup-qti-camera"
CORE_IMAGE_EXTRA_INSTALL_remove = "packagegroup-qti-display"
CORE_IMAGE_EXTRA_INSTALL_remove = "packagegroup-qti-fastcv"
CORE_IMAGE_EXTRA_INSTALL_remove = "packagegroup-qti-cvp"
CORE_IMAGE_EXTRA_INSTALL_remove = "packagegroup-qti-gfx"
CORE_IMAGE_EXTRA_INSTALL_remove = "packagegroup-qti-sensors-see"
CORE_IMAGE_EXTRA_INSTALL_remove = "packagegroup-qti-test-sensors-see"
CORE_IMAGE_EXTRA_INSTALL_remove = "packagegroup-qti-securemsm"
CORE_IMAGE_EXTRA_INSTALL_remove = "packagegroup-qti-video"
CORE_IMAGE_EXTRA_INSTALL_remove = "packagegroup-qti-gst"

# Remove unsupported packages
CORE_IMAGE_EXTRA_INSTALL_remove = "audiodlkm"
CORE_IMAGE_EXTRA_INSTALL_remove = "init-audio"
CORE_IMAGE_EXTRA_INSTALL_remove = "tinyalsa"
CORE_IMAGE_EXTRA_INSTALL_remove = "tinycompress"
CORE_IMAGE_EXTRA_INSTALL_remove = "gbm"
CORE_IMAGE_EXTRA_INSTALL_remove = "libdrm"
CORE_IMAGE_EXTRA_INSTALL_remove = "libdrm-tests"
CORE_IMAGE_EXTRA_INSTALL_remove = "libdrm-kms"
