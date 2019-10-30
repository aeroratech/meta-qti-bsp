require conf/distro/include/user_permissions.inc

do_update_files() {
    set +e
    export FILE_PERMISSIONS="${QPERM_FILE}"
    if [ "$FILE_PERMISSIONS" != "" ] ; then
        for each_file in ${FILE_PERMISSIONS};    do
            path="$(echo $each_file | cut -d ":" -f 1)"
            user="$(echo $each_file | cut -d ":" -f 2)"
            group="$(echo $each_file | cut -d ":" -f 3)"
            chown -R $user:$group ${D}$path
        done
    fi
}

do_install[postfuncs] += "do_update_files"
