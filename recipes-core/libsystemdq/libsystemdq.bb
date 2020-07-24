require libsystemdq.inc

PE = "1"

DEPENDS = "intltool-native gperf-native libcap util-linux"

SECTION = "base/shell"
PACKAGE = "libsystemdq"
inherit useradd pkgconfig meson perlnative update-alternatives qemu systemd gettext bash-completion manpages features_check

# As this recipe builds udev, respect systemd being in DISTRO_FEATURES so
# that we don't build both udev and systemd in world builds.
REQUIRED_DISTRO_FEATURES = "systemd"

SRC_URI += "file://touchscreen.rules \
           file://00-create-volatile.conf \
           file://init \
           file://99-default.preset \
           file://0001-binfmt-Don-t-install-dependency-links-at-install-tim.patch \
           file://0003-implment-systemd-sysv-install-for-OE.patch \
           "

SRC_URI += "file://remove-udev-references-from-meson-build.patch \
          file://remove-journal-from-systemctl.patch \
          file://src-shared-meson-build.patch \
          file://src-libsystemd-meson-build.patch \
          file://remove-udev-and-libudev.patch \
          file://update-libsystemd-pc-in.patch \
          "

# Helper variables to clarify locations.  This mirrors the logic in systemd's
# build system.
rootprefix ?= "${root_prefix}"
rootlibdir ?= "${base_libdir}"
rootlibexecdir = "${rootprefix}/lib"


EXTRA_OEMESON += "-Dnobody-user=nobody \
                  -Dnobody-group=nobody \
                  -Drootlibdir=${rootlibdir} \
                  -Drootprefix=${rootprefix} \
                  -Ddefault-locale=C \
                  "

# Hardcode target binary paths to avoid using paths from sysroot
EXTRA_OEMESON += "-Dkexec-path=${sbindir}/kexec \
                  -Dkmod-path=${base_bindir}/kmod \
                  -Dmount-path=${base_bindir}/mount \
                  -Dquotacheck-path=${sbindir}/quotacheck \
                  -Dquotaon-path=${sbindir}/quotaon \
                  -Dsulogin-path=${base_sbindir}/sulogin \
                  -Dnologin-path=${base_sbindir}/nologin \
                  -Dumount-path=${base_bindir}/umount"

EXTRA_OEMESON += "-Denvironment-d=false \
                  -Dnss-systemd=false -Dmyhostname=false \
                  -Dhibernate=false \
                  -Dblkid=false \
                  -Dresolve=false \
                  -Dlogind=false \
                  -Dpam=false \
                  -Defi=false \
                  -Dgnu-efi=false \
                  -Dportabled=false \
                  -Dbacklight=false \
                  -Drfkill=false \
                  -Dlibcryptsetup=false \
                  -Dsysv-compat=false \
                  -Dhostnamed=false \
                  -Dlocaled=false \
                  -Dtimedated=false \
                  -Dtimesyncd=false \
                  -Dmachined=false \
                  -Dimportd=false \
                  -Dremote=false \
                  -Dlibcurl=false \
                  -Dmicrohttpd=false \
                  -Dcoredump=false \
                  -Dvconsole=false \
                  -Dbinfmt=false \
                  -Drandomseed=false \
                  -Dfirstboot=false \
                  -Dsysusers=false \
                  -Dtmpfiles=false \
                  -Dhwdb=false \
                  -Dquotacheck=false \
                  -Dkmod=false \
                  -Dnetworkd=false \
                  -Didn=false \
                  -Dtpm=false \
                  -Dadm-group=false \
                  -Dwheel-group=false \
                  -Dpolkit=false \
                  -Dman=false "

do_install() {
   meson_do_install
   install -d ${D}/${base_sbindir}
   rm -rf ${D}/usr/share/zsh/
   rm -rf ${D}/usr/lib/systemd/
   rm -rf ${D}/usr/bin/
   rm -rf ${D}/bin/
   rm -rf ${D}/lib/systemd/
   rm -rf ${D}/var/
   rm -rf ${D}/lib/systemd/system-generators/
   rm -rf ${D}/sbin/
   rm -rf ${D}/usr/share/
   mv ${D}/usr/include/systemd ${D}/usr/include/systemdq
}

python populate_packages_prepend (){
    systemdlibdir = d.getVar("rootlibdir")
    do_split_packages(d, systemdlibdir, '^lib(.*)\.so\.*', 'lib%s', 'Systemd %s library', extra_depends='', allow_links=True)
}
PACKAGES_DYNAMIC += "^lib(systemd).*"

FILES_${PN} = " ${exec_prefix}/lib/systemd \
               "

FILES_${PN}-dev += "${base_libdir}/security/*.la ${datadir}/dbus-1/interfaces/ ${sysconfdir}/rpm/macros.systemd"

RDEPENDS_${PN} += "kmod dbus util-linux-mount util-linux-umount util-linux-agetty util-linux-fsck"
RDEPENDS_${PN} += "volatile-binds update-rc.d systemd-conf"

CFLAGS_append = " -fPIC"

INSANE_SKIP_${PN} += "dev-so libdir"
INSANE_SKIP_${PN}-dbg += "libdir"
INSANE_SKIP_${PN}-doc += " libdir"

python __anonymous() {
    if not bb.utils.contains('DISTRO_FEATURES', 'sysvinit', True, False, d):
        d.setVar("INHIBIT_UPDATERCD_BBCLASS", "1")
}

PACKAGE_WRITE_DEPS += "qemu-native"
