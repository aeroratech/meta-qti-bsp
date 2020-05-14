def append_recipe_for_qtidistros(d):
    distrooverrides = d.getVar("DISTROOVERRIDES", True).split(":")
    thisdir = d.getVar("THISDIR", True)
    if "qti-distro-base" in distrooverrides:
        return os.path.join(thisdir, "qti-distro-initscripts.inc")

include ${@append_recipe_for_qtidistros(d)}
FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}-${PV}:"
