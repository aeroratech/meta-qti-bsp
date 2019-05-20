# Modify default CONFFILES as per machine needs

# coredump.conf
do_install_append() {
}

# journald.conf
do_install_append() {
}

# logind.conf
do_install_append() {
    # Ignore PowerKey
    sed -i -e 's/#HandlePowerKey=poweroff/HandlePowerKey=ignore/' ${D}${sysconfdir}/systemd/logind.conf
}

# system.conf
do_install_append() {
}

# user.conf
do_install_append() {
}
