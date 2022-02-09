SUMMARY = "Linux Kernel prebuilt modules"
DESCRIPTION = "Installs boot critical kernel modules into images. \
These modules are auto-loaded by systemd at boot"
LICENSE = "GPLv2.0-with-linux-syscall-note"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta-qti-bsp/files/common-licenses/\
${LICENSE};md5=8afb6abdac9a14cb18a0d6c9c151e9b4"

MODULES_LIST = ""
MODULES_LIST_sxrneo = "modules.list.neo"

FILESPATH =+ "${WORKSPACE}:"
SRC_URI   =  "file://kernel-5.10/kernel_platform/msm-kernel"

S  =  "${WORKDIR}/kernel-5.10/kernel_platform/msm-kernel"

do_configure () {
    cd ${KERNEL_PREBUILT_DISTDIR}
    install -d ${B}/include/generated
    install -m 0644 ../msm-kernel/include/generated/utsrelease.h ${B}/include/generated
}

do_compile () {
    # Segregate modules into first and second stages.
    mod_list=${B}/${MODULES_LIST}

    while IFS= read -r module;
    do
        case "$module" in
            \#*|"") continue;;
        esac
        [ -n "$(echo $first_mods | grep " $module ")" ] && continue
        first_mods="${first_mods}${module} "
    done < "$mod_list"

    for f in $(find ${KERNEL_PREBUILT_DISTDIR} -type f -name '*.ko' -exec basename {} \;) ; do
        found=0
        for m in ${first_mods} ; do
              [ "$f" = "$m" ] && found=1
        done
        [ "$found" = 0 ] && second_mods="${second_mods}$f "
    done

    # Copy first stage modules into ${B} and update modules-load.d conf
    for m in $first_mods; do
        if [ -f ${KERNEL_PREBUILT_DISTDIR}/$m ]; then
            install -m 0644 ${KERNEL_PREBUILT_DISTDIR}/$m ${B}
            mname=`basename ${m} .ko`
            echo "$mname"
        else
            echo "# Module $m not found"
        fi
    done > ${B}/firstmods.conf

    # Copy remaining modules into ${B} and update modules-load.d conf
    for m in ${second_mods}; do
        install -m 0644 ${KERNEL_PREBUILT_DISTDIR}/$m ${B}
        mname=`basename ${m} .ko`
        echo "$mname"
    done > ${B}/secondmods.conf
}

do_install() {
    cd ${B}
    kversion=$(cat include/generated/utsrelease.h | grep -w UTS_RELEASE | awk '{print $3}')
    kversion=$(eval echo $kversion)
    # Install modules
    mkdir -p ${D}/lib/modules/${kversion}
    for mod in *.ko; do
        if [ -f $mod ]; then
            install -m 0644 $mod ${D}/lib/modules/${kversion}
        fi
    done

    # Install systemd configuration file for auto load
    install -d ${D}${sysconfdir}/modules-load.d/
    install -m 0644 firstmods.conf ${D}${sysconfdir}/modules-load.d
    install -m 0644 secondmods.conf ${D}${sysconfdir}/modules-load.d
}

ALLOW_EMPTY_${PN} = "1"

PACKAGE_ARCH = "${MACHINE_ARCH}"
PACKAGES = "${PN}-first-stage ${PN}-second-stage"

python get_files_pn_from_conf() {
    pn = d.getVar('PN')

    f_conf = os.path.join(d.getVar('D'), 'etc/modules-load.d', 'firstmods.conf')
    s_conf = os.path.join(d.getVar('D'), 'etc/modules-load.d', 'secondmods.conf')

    f_mods = [ '/etc/modules-load.d/firstmods.conf' ]
    with open(f_conf) as f:
        lines = f.readlines()
        for line in lines:
            if line.startswith('#'):
                continue
            f_mods += [ '/lib/modules/*/' + line.rstrip() + '.ko' ]
    d.setVar('FILES_' + pn + '-first-stage', " ".join(f_mods))

    s_mods = [ '/etc/modules-load.d/secondmods.conf' ]
    with open(s_conf) as f:
        lines = f.readlines()
        for line in lines:
            if line.startswith('#'):
                continue
            s_mods += [ '/lib/modules/*/' + line.rstrip() + '.ko' ]
    d.setVar('FILES_' + pn + '-second-stage', " ".join(s_mods))
}

PACKAGE_PREPROCESS_FUNCS += "get_files_pn_from_conf "
