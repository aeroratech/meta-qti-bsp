do_configure[depends] += "${@bb.utils.contains('MACHINE_FEATURES', 'qti-vm', 'linux-platform:do_deploy', '', d)}"

