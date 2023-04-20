#Copyright (c) 2023 Qualcomm Innovation Center, Inc. All rights reserved.
#SPDX-License-Identifier: BSD-3-Clause-Clear
DEPENDS += "cryptsetup-native openssl-native"

CONFLICT_MACHINE_FEATURES += " dm-verity-bootloader dm-verity-none dm-verity-initramfs"

VERITY_SALT = "aee087a5be3b982978c923f566a94613496b417f2af592639bc80d141e34dfe7"
BLOCK_SIZE = "4096"
SECTOR_SIZE = "512"
FEC_ROOTS = "2"

VERITY_CREATE = "dm-mod.create="
VERITY_HASH_DEVICE = "${WORKDIR}/${IMAGE_NAME}.verityhash"
VERITY_FEC_DEVICE = "${WORKDIR}/${IMAGE_NAME}.verityfec"
UNSPARSED_SYSTEMIMAGE = "${IMGDEPLOYDIR}/${IMAGE_BASENAME}/${SYSTEMIMAGE_TARGET}"

python system_size_for_verity () {
    system_size = int(d.getVar('SYSTEM_IMAGE_ROOTFS_SIZE'))
    block_size = int(d.getVar('BLOCK_SIZE'))
    sector_size = int(d.getVar('SECTOR_SIZE'))
    data_blocks = int(system_size / block_size)
    hash_start_block = int(data_blocks + 1)
    data_sectors = int(block_size/sector_size*data_blocks)
    d.setVar('DATA_BLOCKS', str(data_blocks))
    d.setVar('DATA_SECTORS', str(data_sectors))
    d.setVar('HASH_START_BLOCK', str(hash_start_block))

    if system_size % block_size != 0:
        bb.warn("aligning system size to {} bytes".format(block_size))
        d.setVar('SYSTEM_SIZE_EXT4', str(data_blocks * block_size))
}
do_makesystem[prefuncs] += "system_size_for_verity"


append_verity_data_to_system_image () {
    # Reformat the system image with verity support
    veritysetup format ${UNSPARSED_SYSTEMIMAGE} \
                ${VERITY_HASH_DEVICE} \
                --data-blocks ${DATA_BLOCKS} \
                --fec-device ${VERITY_FEC_DEVICE} \
                --fec-roots ${FEC_ROOTS} \
                --salt ${VERITY_SALT} > ${WORKDIR}/verity_metadata.txt

    # # Append hash and fec data to the end of the system image after calculating offsets
    hash_offset=${SYSTEM_SIZE_EXT4}
    hash_size=`wc -c ${VERITY_HASH_DEVICE} | awk '{print $1}'`
    fec_offset=`expr ${hash_offset} + ${hash_size}`
    fec_start_block=`expr ${fec_offset} / ${BLOCK_SIZE}`
    fec_blocks=`expr ${fec_start_block} - 1`
    cat ${VERITY_HASH_DEVICE} >> ${UNSPARSED_SYSTEMIMAGE}
    cat ${VERITY_FEC_DEVICE} >> ${UNSPARSED_SYSTEMIMAGE}

    # Generate environment variables for veritysetup on target system
    root_hash=`awk -F ':' '{ if ($1 == "Root hash") print $2 }' ${WORKDIR}/verity_metadata.txt | sed "s/^[ \t]*//"`

    # Sign the root hash
    echo -n "${root_hash}" > ${WORKDIR}/roothash.txt
    openssl smime -sign -nocerts -noattr -binary -in ${WORKDIR}/roothash.txt -inkey ${KERNEL_PREBUILT_PATH}/../msm-kernel/certs/verity_key.pem -signer ${KERNEL_PREBUILT_PATH}/../msm-kernel/certs/verity_cert.pem -outform der -out ${WORKDIR}/verity_sig.txt

    root_hash_sig_key_value=`od -tx1 -An ${WORKDIR}/verity_sig.txt | tr -d ' \n'`

    echo -ne "${VERITY_CREATE}\"verity,,,ro,0 ${DATA_SECTORS} verity 1 \
/dev/vda /dev/vda ${BLOCK_SIZE} ${BLOCK_SIZE} ${DATA_BLOCKS} ${HASH_START_BLOCK} \
sha256 ${root_hash} ${VERITY_SALT} 10 use_fec_from_device /dev/vda fec_start ${fec_start_block} fec_blocks ${fec_blocks} fec_roots ${FEC_ROOTS} \
root_hash_sig_key_value ${root_hash_sig_key_value}\"" \
> ${WORKDIR}/verity-cmdline

    # Clean up large files that are no longer needed
    rm ${VERITY_HASH_DEVICE}
    rm ${VERITY_FEC_DEVICE}
}
do_makesystem[postfuncs] += "append_verity_data_to_system_image"

# ramdisk creation now requires the verity artifacts
do_ramdisk_create[depends] += "${PN}:do_makesystem"