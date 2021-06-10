INIT_RAMDISK = "${@d.getVar('MACHINE_SUPPORTS_INIT_RAMDISK') or "False"}"
RAMDISKDIR = "${WORKDIR}/ramdisk"

do_ramdisk_create[depends] += "virtual/kernel:do_deploy"
do_ramdisk_create[cleandirs] += "${RAMDISKDIR}"
fakeroot do_ramdisk_create() {
        mkdir -p ${RAMDISKDIR}/bin
        mkdir -p ${RAMDISKDIR}/etc
        mkdir -p ${RAMDISKDIR}/etc/init.d
        mkdir -p ${RAMDISKDIR}/lib
        mkdir -p ${RAMDISKDIR}/usr
        mkdir -p ${RAMDISKDIR}/usr/bin
        mkdir -p ${RAMDISKDIR}/usr/sbin
        mkdir -p ${RAMDISKDIR}/dev
        mknod -m 0600 ${RAMDISKDIR}/dev/console c 5 1
        mknod -m 0600 ${RAMDISKDIR}/dev/tty c 5 0
        mknod -m 0600 ${RAMDISKDIR}/dev/tty0 c 4 0
        mknod -m 0600 ${RAMDISKDIR}/dev/tty1 c 4 1
        mknod -m 0600 ${RAMDISKDIR}/dev/tty2 c 4 2
        mknod -m 0600 ${RAMDISKDIR}/dev/tty3 c 4 3
        mknod -m 0600 ${RAMDISKDIR}/dev/tty4 c 4 4
        mknod -m 0600 ${RAMDISKDIR}/dev/zero c 1 5
        mkdir -p ${RAMDISKDIR}/dev/pts
        mkdir -p ${RAMDISKDIR}/root
        mkdir -p ${RAMDISKDIR}/proc
        mkdir -p ${RAMDISKDIR}/sys
        cd ${RAMDISKDIR}
        ln -s bin sbin
        cp ${IMAGE_ROOTFS}/bin/busybox bin/
        cp ${IMAGE_ROOTFS}/bin/busybox.suid bin/
        if ${@bb.utils.contains('IMAGE_FEATURES', 'vm', 'true', 'false', d)}; then
            cp ${IMAGE_ROOTFS}/lib/ld-linux-aarch64.so.1 lib/ld-linux-aarch64.so.1
            cp ${COREBASE}/meta-qti-bsp/recipes-products/images/include/vmrd-init .
            chmod 744 vmrd-init
            ln -s vmrd-init init
        else
            cp ${IMAGE_ROOTFS}/lib/ld-linux-armhf.so.3 lib/ld-linux-armhf.so.3
            cp ${IMAGE_ROOTFS}/sbin/adbd sbin/
            cp ${IMAGE_ROOTFS}/sbin/usb_composition sbin/
            cp -r ${IMAGE_ROOTFS}/sbin/usb/ sbin/
            cp ${IMAGE_ROOTFS}/usr/lib/libadbd.so.0 lib/libadbd.so.0
            cp ${IMAGE_ROOTFS}/usr/lib/libext4_utils.so.0 lib/libext4_utils.so.0
            cp ${IMAGE_ROOTFS}/usr/lib/libbase.so.0 lib/libbase.so.0
            cp ${IMAGE_ROOTFS}/usr/lib/libfs_mgr.so.0 lib/libfs_mgr.so.0
            cp ${IMAGE_ROOTFS}/usr/lib/liblog.so.0 lib/liblog.so.0
            cp ${IMAGE_ROOTFS}/usr/lib/libcutils.so.0 lib/libcutils.so.0
            cp ${IMAGE_ROOTFS}/usr/lib/libsparse.so.0 lib/libsparse.so.0
            cp ${IMAGE_ROOTFS}/usr/lib/libmincrypt.so.0 lib/libmincrypt.so.0
            cp ${IMAGE_ROOTFS}/usr/lib/libgthread-2.0.so.0 lib/libgthread-2.0.so.0
            cp ${IMAGE_ROOTFS}/usr/lib/libglib-2.0.so.0 lib/libglib-2.0.so.0
            cp ${IMAGE_ROOTFS}/usr/lib/liblogwrap.so.0 lib/liblogwrap.so.0
            cp ${IMAGE_ROOTFS}/lib/libgcc_s.so.1 lib/libgcc_s.so.1
            #cp ${IMAGE_ROOTFS}/lib/libcrypto.so.1.0.0 lib/libcrypto.so.1.0.0
            cp ${IMAGE_ROOTFS}/usr/lib/libstdc++.so.6 lib/libstdc++.so.6
            ln -s bin/busybox init
        fi
        cp ${IMAGE_ROOTFS}/lib/libz.so.1 lib/libz.so.1
        cp ${IMAGE_ROOTFS}/lib/libc.so.6 lib/libc.so.6
        cp ${IMAGE_ROOTFS}/lib/libm.so.6 lib/libm.so.6
        cp ${IMAGE_ROOTFS}/lib/librt.so.1 lib/librt.so.1
        cp ${IMAGE_ROOTFS}/lib/libpthread.so.0 lib/libpthread.so.0
        cp ${IMAGE_ROOTFS}/lib/libdl.so.2 lib/libdl.so.2
        cp ${IMAGE_ROOTFS}/lib/libresolv.so.2 lib/libresolv.so.2
        cp ${COREBASE}/meta-qti-bsp/recipes-core/busybox/files/fstab etc/
        cp ${COREBASE}/meta-qti-bsp/recipes-core/busybox/files/inittab etc/
        cp ${COREBASE}/meta-qti-bsp/recipes-core/busybox/files/profile etc/
        cp ${COREBASE}/meta-qti-bsp/recipes-core/busybox/files/rcS etc/init.d
        if ${@bb.utils.contains('IMAGE_DEV_MANAGER', 'mdev', 'true', 'false', d)}; then
            cp ${IMAGE_ROOTFS}/etc/init.d/mdev etc/init.d/
            cp ${IMAGE_ROOTFS}/etc/mdev.conf etc/
            cp -r ${IMAGE_ROOTFS}/etc/mdev etc/
            cat etc/init.d/mdev >> etc/init.d/rcS
        fi

        # Run rcS script only if busybox is init manager in ramdisk.
        # In other cases, ramdisk will be used in early boot but no init in busybox.
        if ${@oe.utils.conditional('INIT_RAMDISK', 'True', 'true', 'false', d)}; then
            chmod 744 etc/init.d/rcS
        fi

        if ${@bb.utils.contains('DISTRO_FEATURES', 'selinux', 'true', 'false', d)}; then
            cp ${IMAGE_ROOTFS}/lib/libselinux.so.1 lib/libselinux.so.1
            cp ${IMAGE_ROOTFS}/lib/libpcre.so.1 lib/libpcre.so.1
        fi

        # meta-selinux layer does not currently check for distro_features
        if [ -f ${IMAGE_ROOTFS}/usr/lib/libpcre.so.1 ]; then
            cp ${IMAGE_ROOTFS}/usr/lib/libpcre.so.1 lib/libpcre.so.1
        else
            cp ${IMAGE_ROOTFS}/lib/libpcre.so.1 lib/libpcre.so.1
        fi
        ln -s busybox bin/sh
        ln -s busybox bin/echo
        ln -s busybox.suid bin/mount
        ln -s busybox.suid bin/umount
        if ${@bb.utils.contains('IMAGE_DEV_MANAGER', 'mdev', 'true', 'false', d)}; then
            ln -s busybox bin/mdev
        fi

        if ${@bb.utils.contains('DISTRO_FEATURES', 'dm-verity', bb.utils.contains('MACHINE_FEATURES', 'dm-verity-initramfs', 'true', 'false', d), 'false', d)}; then
            cp ${IMAGE_ROOTFS}/usr/sbin/veritysetup bin/
            cp ${WORKDIR}/verity.env etc/
            cp ${WORKDIR}/verity_sig.txt etc/

            # Shared library dependencies for dm-verity feature
            cp ${IMAGE_ROOTFS}/usr/lib/libcryptsetup.so.12 lib/
            cp ${IMAGE_ROOTFS}/lib/libblkid.so.1 lib/
            cp ${IMAGE_ROOTFS}/usr/lib/libpopt.so.0 lib/
            cp ${IMAGE_ROOTFS}/lib/libuuid.so.1 lib/
            cp ${IMAGE_ROOTFS}/usr/lib/libdevmapper.so.1.02 lib/
            cp ${IMAGE_ROOTFS}/usr/lib/libssl.so.1.1 lib/
            cp ${IMAGE_ROOTFS}/usr/lib/libcrypto.so.1.1 lib/
            cp ${IMAGE_ROOTFS}/usr/lib/libjson-c.so.4 lib/
            cp ${IMAGE_ROOTFS}/lib/libudev.so.1 lib/
            cp ${IMAGE_ROOTFS}/lib/libmount.so.1 lib/
        fi

        #gen_initramfs_list.sh expects to be run from kernel directory
        cd ${DEPLOY_DIR_IMAGE}/build-artifacts/kernel_scripts
        # remove the initrd.gz file if exist
        rm -rf ${IMGDEPLOYDIR}/${PN}-initrd.gz
        if ${@bb.utils.contains_any('PREFERRED_VERSION_linux-msm', '5.10', 'true', 'false', d)}; then
            bash ./scripts/gen_initramfs.sh -o ${IMGDEPLOYDIR}/${PN}-initrd.gz -u 0 -g 0 ${RAMDISKDIR}
        else
            bash ./scripts/gen_initramfs_list.sh -o ${IMGDEPLOYDIR}/${PN}-initrd.gz -u 0 -g 0 ${RAMDISKDIR}
        fi

        cd ${CURRENT_DIR}
}

addtask do_ramdisk_create after do_image before do_image_complete