require qti-console-image.bb

CORE_IMAGE_EXTRA_INSTALL += "\
              abctl \
              ab-slot-util \
              ab-status-updater \
"

CORE_IMAGE_EXTRA_INSTALL_remove += "packagegroup-qti-wifi"
