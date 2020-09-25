# QTI Linux mbb image file.
# Provides packages required to build an mbb image with
# boot to console with connectivity support.

require qti-mbb-minimal-image.bb

CORE_IMAGE_EXTRA_INSTALL += "\
              ${@bb.utils.contains('MACHINE_FEATURES', 'qti-bluetooth', "packagegroup-qti-bluetooth", "", d)} \
              ${@bb.utils.contains('MACHINE_FEATURES', 'qti-ril', "packagegroup-qti-ril-prop", "", d)} \
              ${@bb.utils.contains('MACHINE_FEATURES', 'qti-wifi', "packagegroup-qti-wifi", "", d)} \
"
