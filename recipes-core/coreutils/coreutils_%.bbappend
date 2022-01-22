# Limit packages need to be included as part of the default package.
# To add more extend bindir_progs, base_bindir_progs by referring
# original recipe. Accordingly update alternatives to avoid pkg warnings

CUSTOMIZE_COREUTILS_COMMANDS = "${@oe.utils.conditional('TOYBOX_RAMDISK', 'True', 'False', 'True', d)}"

python () {
    if d.getVar("CUSTOMIZE_COREUTILS_COMMANDS") == "True":
        d.setVar("bindir_progs", "chcon")
        d.setVar("base_bindir_progs", "cp")
}

ALTERNATIVE_${PN} = "${bindir_progs} ${base_bindir_progs} ${sbindir_progs}"
ALTERNATIVE_${PN}-doc = ""

PACKAGE_PREPROCESS_FUNCS += "${@oe.utils.conditional('CUSTOMIZE_COREUTILS_COMMANDS', 'True', 'remove_extra_progs', '', d)}"
remove_extra_progs() {
    cd ${PKGD}${bindir}
    find . -type f ! -name '${bindir_progs}.${BPN}' -delete

    cd ${PKGD}${base_bindir}
    find . -type f ! -name '${base_bindir_progs}.${BPN}' -delete
}
