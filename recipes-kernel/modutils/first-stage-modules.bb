SUMMARY = "Linux Kernel first stage modules"
DESCRIPTION = "Installs boot critical kernel modules into ramdisk. \
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
    cd ${KERNEL_PREBUILT_PATH}
    install -d ${B}/include/generated
    install -m 0644 ../msm-kernel/include/generated/utsrelease.h ${B}/include/generated
}

do_compile () {
    loaded_modules=" "
    file=${B}/${MODULES_LIST}

    while IFS= read -r module;
    do
        case "$module" in
            \#*|"") continue;;
        esac
        [ -n "$(echo $loaded_modules | grep " $module ")" ] && continue
        loaded_modules="${loaded_modules}${module} "
    done < "$file"

    # Copy modules into ${B} and update modules-load.d conf with name
    for m in $loaded_modules; do
        if [ -f ${KERNEL_PREBUILT_PATH}/$m ]; then
            install -m 0644 ${KERNEL_PREBUILT_PATH}/$m ${B}
            mname=`basename ${m}`
            echo "$mname"
        else
            echo "# Module $m not found"
        fi
    done > ${B}/firstmods.conf
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
    install -d ${D}${sysconfdir}/modules-load.d/ ${D}${sysconfdir}/modprobe.d/
    install -m 0644 firstmods.conf ${D}${sysconfdir}/modules-load.d
}

ALLOW_EMPTY_${PN} = "1"

PACKAGE_ARCH = "${MACHINE_ARCH}"
FILES_${PN} += "/lib/modules/* ${sysconfdir}/*"
