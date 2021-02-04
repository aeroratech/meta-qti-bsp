#Below Package is fetch from CAF 
SRC_URI = "git://source.codeaurora.org/quic/le/e2fsprogs.git;branch=ext2/master;protocol=https"

SRC_URI += "file://remove.ldconfig.call.patch \
           file://run-ptest \
           file://ptest.patch \
           file://mkdir_p.patch \
           file://0001-misc-create_inode.c-set-dir-s-mode-correctly.patch \
           file://0001-configure.ac-correct-AM_GNU_GETTEXT.patch \
           file://0001-intl-do-not-try-to-use-gettext-defines-that-no-longe.patch \
           file://CVE-2019-5188.patch \
           file://0001-e2fsck-don-t-try-to-rehash-a-deleted-directory.patch \
           file://e2fsck-fix-use-after-free-in-calculate_tree.patch \
           "
