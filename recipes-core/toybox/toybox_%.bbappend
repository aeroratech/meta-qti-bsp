do_configure_append() {
    # Enable mdev
    sed -e 's/# CONFIG_MDEV is not set/CONFIG_MDEV=y/' -i .config

    # Enable mdev conf
    sed -e 's/# CONFIG_MDEV_CONF is not set/CONFIG_MDEV_CONF=y/' -i .config

    sed -e 's/# CONFIG_SWAPON is not set/CONFIG_SWAPON=y/' -i .config
}
