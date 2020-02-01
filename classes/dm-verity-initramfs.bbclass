DEPENDS += "cryptsetup-native openssl-native mod-signing-keys"

CORE_IMAGE_EXTRA_INSTALL += "cryptsetup"

VERITY_SALT = "aee087a5be3b982978c923f566a94613496b417f2af592639bc80d141e34dfe7"
BLOCK_SIZE = "4096"
FEC_ROOTS = "2"

VERITY_HASH_DEVICE = "${WORKDIR}/${IMAGE_NAME}.verityhash"
VERITY_FEC_DEVICE = "${WORKDIR}/${IMAGE_NAME}.verityfec"
UNSPARSED_SYSTEMIMAGE = "${IMGDEPLOYDIR}/${IMAGE_BASENAME}/${SYSTEMIMAGE_TARGET}"

python adjust_system_size_for_verity () {
    system_size = int(d.getVar('SYSTEM_SIZE_EXT4'))
    block_size = int(d.getVar('BLOCK_SIZE'))
    data_blocks = int(system_size / block_size)
    d.setVar('DATA_BLOCKS', str(data_blocks))
    if system_size % block_size != 0:
        bb.warn("aligning system size to {} bytes".format(block_size))
        d.setVar('SYSTEM_SIZE_EXT4', str(data_blocks * block_size))
}
do_makesystem[prefuncs] += "adjust_system_size_for_verity"

append_verity_metadata_to_system_image () {
    # Reformat the system image with verity support
    veritysetup format ${UNSPARSED_SYSTEMIMAGE} \
                ${VERITY_HASH_DEVICE} \
                --data-blocks ${DATA_BLOCKS} \
                --fec-device ${VERITY_FEC_DEVICE} \
                --fec-roots ${FEC_ROOTS} \
                --salt ${VERITY_SALT} > ${WORKDIR}/verity_metadata.txt

    # Append hash and fec data to the end of the system image after calculating offsets
    hash_offset=${SYSTEM_SIZE_EXT4}
    hash_size=`wc -c ${VERITY_HASH_DEVICE} | awk '{print $1}'`
    fec_offset=`expr ${hash_offset} + ${hash_size}`
    cat ${VERITY_HASH_DEVICE} >> ${UNSPARSED_SYSTEMIMAGE}
    cat ${VERITY_FEC_DEVICE} >> ${UNSPARSED_SYSTEMIMAGE}

    # Generate environment variables for veritysetup on target system
    root_hash=`awk -F ':' '{ if ($1 == "Root hash") print $2 }' ${WORKDIR}/verity_metadata.txt | sed "s/^[ \t]*//"`
    cat <<-EOF > ${WORKDIR}/verity.env
	VERITY_DATA_BLOCKS=${DATA_BLOCKS}
	VERITY_HASH_OFFSET=${hash_offset}
	VERITY_FEC_OFFSET=${fec_offset}
	VERITY_FEC_ROOTS=${FEC_ROOTS}
	VERITY_SALT=${VERITY_SALT}
	VERITY_ROOT_HASH=${root_hash}
	EOF

    # Sign the root hash
    echo -n ${roothash} > ${WORKDIR}/roothash.txt
    openssl smime -sign -nocerts -noattr -binary -in ${WORKDIR}/roothash.txt -inkey ${STAGING_DIR_TARGET}/kernel-certs/verity_key.pem -signer ${STAGING_DIR_TARGET}/kernel-certs/verity_cert.pem -outform der -out ${WORKDIR}/verity_sig.txt

    # Clean up large files that are no longer needed
    rm ${VERITY_HASH_DEVICE}
    rm ${VERITY_FEC_DEVICE}
}
do_makesystem[postfuncs] += "append_verity_metadata_to_system_image"
