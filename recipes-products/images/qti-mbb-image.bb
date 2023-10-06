# QTI Linux mbb image file.
# Provides packages required to build an mbb image with
# boot to console with connectivity support.

require qti-mbb-minimal-image.bb

IMAGE_FEATURES += "nand2x"

# gluebi is read only and prevents debugging/experimentation. Only enable in user variant
IMAGE_FEATURES_append_qti-distro-base-user = " gluebi"

CORE_IMAGE_EXTRA_INSTALL += "\
              packagegroup-qti-data-1g \
              ${@bb.utils.contains('BASEMACHINE', 'sdxlemur', "crash-collect", "", d)} \
              ${@bb.utils.contains('MACHINE_FEATURES', 'qti-ssdk', "packagegroup-qti-ssdk", "", d)} \
              ${@bb.utils.contains('MACHINE_FEATURES', 'qti-audio', 'packagegroup-qti-audio', '', d)} \
              ${@bb.utils.contains('MACHINE_FEATURES', 'qti-bluetooth', "packagegroup-qti-bluetooth", "", d)} \
              ${@bb.utils.contains('MACHINE_FEATURES', 'qti-wifi', "packagegroup-qti-wifi", "", d)} \
"

do_cleanup_sepolicy() {

        policy_version=31
        policy_type=mls
        policy_dir=${IMAGE_ROOTFS}/etc/selinux/${policy_type}/policy
        recovery_policy=${policy_dir}/recovery.policy.${policy_version}
        if [ -f ${recovery_policy} ]; then
                rm ${recovery_policy}
        fi
}

ROOTFS_POSTPROCESS_COMMAND += "${@bb.utils.contains('DISTRO_FEATURES', 'selinux', 'do_cleanup_sepolicy;', '', d)}"

