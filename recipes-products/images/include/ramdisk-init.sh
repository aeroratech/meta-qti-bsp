#!/bin/sh

# Copyright (c) 2022-2023 Qualcomm Innovation Center, Inc. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted (subject to the limitations in the
# disclaimer below) provided that the following conditions are met:
#
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#
#     * Redistributions in binary form must reproduce the above
#       copyright notice, this list of conditions and the following
#       disclaimer in the documentation and/or other materials provided
#       with the distribution.
#
#     * Neither the name of Qualcomm Innovation Center, Inc. nor the names of its
#       contributors may be used to endorse or promote products derived
#       from this software without specific prior written permission.
#
# NO EXPRESS OR IMPLIED LICENSES TO ANY PARTY'S PATENT RIGHTS ARE
# GRANTED BY THIS LICENSE. THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT
# HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
# GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
# IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
# IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


PATH=/sbin:/bin:/usr/sbin:/usr/bin

#------------------------------------------------------------
Becho="busybox echo"
Bgrep="busybox grep"
Bcat="busybox cat"
Bsed="busybox sed"
Bawk="busybox awk"
Bcut="busybox cut"
Bseq="busybox seq"
Bdd="busybox dd"
Btr="busybox tr"
Bhexdump="busybox hexdump"

UBIFS_VOL_HEADER="1831 0610"
RAM_SIZE_LIMIT_VOL="512"

#------------------------------------------------------------
# Below macro can be set by build scripts, if not,
# a default volume will be set in function SetArgs()

# System image partition name not including slot suffix
SYS_PART_NAME="rootfs"

# UBI partition name, it can be system or nad_ubi, make sure
# they are not present at the same time.
UBI_PART_NAME="system|nad_ubi"

# Set UBI bad block percentage for current partition
MTD_UBI_BEB_LIMIT_PER1024="30"

# UBI device number for system image
SYS_UBI_DEV_NUM="0"

# root certificate key path
CERT_CA_PATH="/etc/keys/x509_root.der"

# FDE Encryption path
FDE_ENCRYPTION_PATH="/tmp/test.img"

# Recoveryfs partition or volume name
RECOVERYFS_DEV="recoveryfs"

# verity feature status
VERITY_ENV="/etc/verity.env"

#------------------------------------------------------------

# Temporary rootfs mount node
ROOT_MOUNT="/rootfs"

# Firmware dir
FW_DIR="/firmware"

# Function return status
STATUS_OK=0
STATUS_ERR=1

LOGD() {
  busybox echo "$1"
}

WaitDevReady()
{
    local maxTrials=500

    while [ ! "$1" "$2" ]; do
        busybox usleep 10000
        maxTrials=$( ${Becho} $(( ${maxTrials} - 1 )) )
        if [ ${maxTrials} -eq 0 ]; then
            return ${STATUS_ERR}
        fi
    done
    return ${STATUS_OK}
}

EarlySetup() {
    busybox mkdir -p /proc
    busybox mkdir -p /sys
    busybox.suid mount -t proc proc /proc
    busybox.suid mount -t sysfs sysfs /sys
    busybox.suid mount -t devtmpfs none /dev

    busybox mkdir -p /tmp
    busybox.suid mount -t tmpfs tmpfs /tmp

    busybox mkdir -p /run
    busybox mkdir -p /var/run

    busybox mkdir -p ${ROOT_MOUNT}
    return ${STATUS_OK}
}

SetArgs() {

    # Root image name
    DM_SYST_NAME="${SYS_PART_NAME}"

    return ${STATUS_OK}
}


UmountModem () {
    if ${Bgrep} "${FW_DIR}" /proc/mounts -w > /dev/null; then
        busybox killall qseecomd
        busybox.suid umount ${FW_DIR} -l
        busybox sleep 1
        LOGD "umount ${FW_DIR} -l"
    fi
}

gracefullReboot () {
    local mode=$1
    local abctl_cmd="/usr/bin/nad-abctl"
    UmountModem

    if [ ! -e ${abctl_cmd} ]; then
        LOGD "${abctl_cmd} not found."
        return ${STATUS_ERR}
    fi

    LOGD "InitRamFS: Found issue, rebooting ${mode}..."
    busybox sleep 1

    ${abctl_cmd} --reboot ${mode}
    if [ "$?" -eq "-1" ]; then
        LOGD "Error: reboot failed"
        return ${STATUS_ERR}
    fi
}

SlotSwitchReboot () {
    local abctl_cmd="/usr/bin/nad-abctl"
    local sys_vol_name=""
    local sys_vol=""
    # Set image_set_status fields in recoveryinfo struct
    #  'A &B' Usable     :  SET_AB_USABLE(0)
    #  'A' corrupted     :  DONT_USE_SET_A(1)
    #  'B' corrupted     :  DONT_USE_SET_B(2)
    #  'A &B' corrupted  :  DONT_USE_SET_AB(3)

    # Set owner fields in recoveryinfo struct
    #  OWNER_XBL         :  1
    #  OWNER_HLOS        :  2
    local owner_hlos=2
    local dont_use_set_a=1
    local dont_use_set_b=2
    local dont_use_set_ab=3
    local current_image_set_status=0
    local mtd_device=`${Bgrep} recoveryinfo /proc/mtd | ${Bawk} -F ':' '{print $1}'`

    # TODO GPIO needs to be handled
    if [ ! -e ${abctl_cmd} ]; then
        LOGD "${abctl_cmd} not found."
        return ${STATUS_ERR}
    fi

    if [ -z "${mtd_device}" ]; then
        LOGD " recoveryinfo part not found."
        return ${STATUS_ERR}
    fi

    if [ ! -e "/dev/ubi${SYS_UBI_DEV_NUM}" ]; then
        LOGD "Error: /dev/ubi${SYS_UBI_DEV_NUM} not found"
        return ${STATUS_ERR}
    fi

    GetUbiVolumeID ${SYS_UBI_DEV_NUM} ${DM_SYST_NAME}
    if [ "${GetUbiVolumeID_RESULT}" == "" ]; then
        LOGD "Cannot get ${DM_SYST_NAME} volume."
        return ${STATUS_ERR}
    fi
    sys_vol=${GetUbiVolumeID_RESULT}
    sys_vol_name="/sys/class/ubi/ubi${SYS_UBI_DEV_NUM}_${sys_vol}/name"

    # check current slot and image_set_status in recoveryinfo
    #  'A' corrupted     :  set image_set_status = DONT_USE_SET_A
    #  'B' corrupted     :  set image_set_status = DONT_USE_SET_B
    #  'A &B' corrupted  :  set image_set_status = DONT_USE_SET_AB
    #

    if ${Bgrep} ${sys_vol_name} -e "_a\|_b" > /dev/null; then
        # A/B system case
        curr_slot=`${Bcat} /proc/cmdline | ${Bawk} -F'SLOT_SUFFIX=' '{print $2}' | ${Bawk} '{print $1}' | ${Btr} -d '"'`
        if [ "x${curr_slot}" == "x" ]; then
            LOGD "slot_suffix not present"
            return ${STATUS_ERR}
        fi
        busybox chmod 666 /dev/${mtd_device}

        #Get current image set status
        (${abctl_cmd} --get_image_set_status)
        current_image_set_status=$?

        if [ "$current_image_set_status" -eq "-1" ]; then
            LOGD "Error: incorrect image set status"
            return ${STATUS_ERR}
        fi

        if [ "$curr_slot" = "_a" ] && [ "$current_image_set_status" != "$dont_use_set_b" ]; then
            LOGD "rootfs A volume corrupted "
            ${abctl_cmd} --set_image_set_status ${dont_use_set_a}
            if [ "$?" -eq "-1" ]; then
                LOGD "Error: image set status failed"
                return ${STATUS_ERR}
            fi
        elif [ "$curr_slot" = "_b" ] && [ "$current_image_set_status" != "$dont_use_set_a" ]; then
            LOGD "rootfs B volume corrupted "
            ${abctl_cmd} --set_image_set_status ${dont_use_set_b}
            if [ "$?" -eq "-1" ]; then
                LOGD "Error: image set status failed"
                return ${STATUS_ERR}
                fi
        else
            LOGD "rootfs A and B volume is corrupted."
            ${abctl_cmd} --set_image_set_status ${dont_use_set_ab}
            if [ "$?" -eq "-1" ]; then
                LOGD "Error: image set status failed"
                return ${STATUS_ERR}
            fi
        fi
    else
        # Single system (ar)
        # TODO Behavior needs to be decided for AR
        LOGD "AR scenario, reboot to edl"
        gracefullReboot edl
    fi

    # Set owner to HLOS & reboot device
    ${abctl_cmd} --set_owner ${owner_hlos}
    if [ "$?" -eq "-1" ]; then
        LOGD "Error: owner set failed"
        return ${STATUS_ERR}
    fi
    LOGD "Reboot device for Slot Switch or EDL"
    gracefullReboot

    return ${STATUS_ERR}
}

MountModemVol() {
    busybox mkdir -p ${FW_DIR}
    GetUbiVolumeID ${SYS_UBI_DEV_NUM} "firmware"
    if [ "${GetUbiVolumeID_RESULT}" == "" ]; then
        LOGD "Cannot get 'firmware' volume."
        return ${STATUS_ERR}
    fi
    firmvol=${GetUbiVolumeID_RESULT}

    m_char_device=/dev/ubi${SYS_UBI_DEV_NUM}_${firmvol}
    m_block_device=/dev/ubiblock${SYS_UBI_DEV_NUM}_${firmvol}

   ubiblock --create "${m_char_device}"
   WaitDevReady "-b" "${m_block_device}"
   if [ $? -ne ${STATUS_OK} ]; then
       LOGD "Error: wait UBI volume: ${m_block_device} timeout"
       return ${STATUS_ERR}
   fi
   busybox.suid mount -t squashfs ${m_block_device} ${FW_DIR} -oro
   if [ $? -ne ${STATUS_OK} ]; then
       LOGD "Error: mount ${m_block_device} on ${FW_DIR} failed"
       return ${STATUS_ERR}
   fi
   return ${STATUS_OK}
}

#
# Get device number with partition name
# $1 -- partition name
#
GetStorageDev() {
    local partition_name=$1

    DEV_NUM=`${Bgrep} -Ew "\"${partition_name}\"" /proc/mtd | ${Bcut} -d ":" -f 1 | ${Bcut} -b 4-`
    if [ -z "${DEV_NUM}" ]; then
        LOGD "Error: GetStorageDev: Get device of ${partition_name} failed."
        return ${STATUS_ERR}
    fi
    return ${STATUS_OK}
}

GetUbiVolumeID () {
    local ubi_dev_number=$1
    local ubi_vol_name=$2
    GetUbiVolumeID_RESULT=""

    act_slot=`${Bcat} /proc/cmdline | ${Bawk} -F'SLOT_SUFFIX=' '{print $2}' | ${Bawk} '{print $1}' | ${Btr} -d '"'`
    if [ "x${act_slot}" == "x" ]; then
        act_slot="_a"
    fi
    fs_ab_name=${ubi_vol_name}${act_slot}
    volcount=`${Bcat} /sys/class/ubi/ubi${ubi_dev_number}/volumes_count`

    for vid in `${Bseq} 0 ${volcount}`; do
        WaitDevReady "-c" "/dev/ubi${ubi_dev_number}_${vid}"
        if [ $? -ne ${STATUS_OK} ]; then
            LOGD "Error: wait UBI volume: /dev/ubi${ubi_dev_number}_${vid} timeout"
            return ${STATUS_ERR}
        fi

        name=`${Bcat} /sys/class/ubi/ubi${ubi_dev_number}_${vid}/name`
        if [ "${name}" == "${ubi_vol_name}" ] || [ "${name}" == "${fs_ab_name}" ]; then
            GetUbiVolumeID_RESULT=${vid}
            break
        fi
    done
}

CheckTmpDirectorySizeForFde () {
    local ubi_dev_num=${1}
    local ubi_vol_num=${2}

    local tmp_directory_size=`${Bdf} -m | ${Bgrep} "/tmp" | ${Bawk} '{print $4}'`
    local ubi_vol_size=`${Bcat} /sys/class/ubi/ubi${ubi_dev_num}_${ubi_vol_num}/data_bytes`

    # Reserved 10MiB space for FDE encryption should be safe enough.
    busybox let ubi_vol_size=ubi_vol_size/1024/1024+10
    if [ ${ubi_vol_size} -gt ${tmp_directory_size} ]; then

        # If the reserved space is bigger than 5MiB and smaller than 10MiB,
        # the encryption will be in a high risk, need to export warning info.
        busybox let ubi_vol_size=ubi_vol_size-5
        if [ ${ubi_vol_size} -gt ${tmp_directory_size} ]; then
            LOGD "Err: Not enough RAM size for FDE."
            return ${STATUS_ERR}
        else
            LOGD "Warning: The RAM size is insufficient for FDE."
        fi
    fi
    return ${STATUS_OK}
}

FdeInitialize ()
{
    MountModemVol
    if [ $? -ne ${STATUS_OK} ]; then
        LOGD "Error: Mount modem UBI volume failed."
        return ${STATUS_ERR}
    fi

    chmod 664 /dev/qseecom
    chmod 664 /dev/ion
    /usr/bin/qseecomd > /dev/kmsg &
    return ${STATUS_OK}
}

# device_name - The name of the partition
# ubi_dev_num - UBI device number
# ubi_vol_num - UBI volume number
# key_index - The key use for partition encryption
# for_vb_parameter - These parameters need to transmit to verified-boot utility
EncryptUbiPartition () {
    local device_name=${1}
    local ubi_dev_num=${2}
    local ubi_vol_num=${3}
    local key_index=${4}
    local for_vb_parameter="${5}"

    local char_device=""
    local block_device=""
    local encryption_path=${FDE_ENCRYPTION_PATH}

    if [ "${FDE_INIT_STATUS}" != "DONE" ]; then
        FdeInitialize
        if [ $? -ne ${STATUS_OK} ]; then
            LOGD "Error: FDE initialization failed."
            return ${STATUS_ERR}
        fi
        FDE_INIT_STATUS="DONE"
    fi

    if [ "${ubi_vol_num}" == "null" ]; then
        GetUbiVolumeID ${ubi_dev_num} ${device_name}
        if [ "${GetUbiVolumeID_RESULT}" == "" ]; then
            LOGD "Cannot get ${device_name} volume."
            return ${STATUS_ERR}
        fi
        ubi_vol_num=${GetUbiVolumeID_RESULT}
    fi

    char_device=/dev/ubi${ubi_dev_num}_${ubi_vol_num}
    block_device=/dev/ubiblock${ubi_dev_num}_${ubi_vol_num}

    CheckTmpDirectorySizeForFde ${ubi_dev_num} ${ubi_vol_num}
    if [ $? -ne ${STATUS_OK} ]; then
        LOGD "Error: Not enough RAM size for ${device_name} encryption."
        return ${STATUS_ERR}
    fi

    if [ ! -e "${block_device}" ]; then
        ubiblock --create "${char_device}"
        WaitDevReady "-b" "${block_device}"
        if [ $? -ne ${STATUS_OK} ]; then
            LOGD "Error: EncryptUbiPartition no device: ${block_device} found"
            return ${STATUS_ERR}
        fi
    fi

    # nad-fde-app return:
    # 0 -- Run encryption and/or decryption successful
    # 1 -- Fuse not blown, continue as normal boot
    # 2 -- Failed
    nad-fde-app -c ${char_device} -d ${block_device} -n ${device_name} -p ${encryption_path} -k ${key_index} \
                -V "${for_vb_parameter}"
    nad_fde_result=$?
    case "${nad_fde_result}" in
        0)
            LOGD "FDE enabled for ${device_name}."
            FDE_MOUNT_NODE="/dev/mapper/${device_name}"
            busybox rm -rf ${encryption_path}
            return ${STATUS_OK}
        ;;
        1)
            LOGD "FDE fuse bit not blown."
            FDE_MOUNT_NODE=${block_device}
            busybox rm -rf ${encryption_path}
            return ${STATUS_OK}
        ;;
        *)
            LOGD "FDE encryption failed ${nad_fde_result}."
            FDE_MOUNT_NODE=""
            busybox rm -rf ${encryption_path}
            return ${STATUS_ERR}
        ;;
    esac
}

# rootca_path - The rootCA storing path, use to verify NOT system image
EncryptNotSysPartition () {
    local rootca_path=${1}
    local fde_parti_list=`${Bcat} /proc/cmdline | ${Bsed} 's/ /\n/g' | ${Bgrep} -E "fde\."`
    local vb_parameter="-p ${rootca_path}"

    for parti in ${fde_parti_list}; do
        parti_name=`${Becho} ${parti} | ${Bawk} -F "." '{print $2}'`
        key_index=`${Becho} ${parti} | ${Bawk} -F "." '{print $3}'`

        if [ "${DM_SYST_NAME}" == "${parti_name}" ]; then
            continue
        fi

        EncryptUbiPartition ${parti_name} \
                            ${SYS_UBI_DEV_NUM} \
                            "null" \
                            ${key_index} \
                            "${vb_parameter}"

        if [ $? -ne ${STATUS_OK} ] ; then
            LOGD "Encrypt partition ${parti_name} failed."
            return ${STATUS_ERR}
        fi
    done
    return ${STATUS_OK}
}

MoveMountToSystem() {
    busybox.suid mount -n --move /proc ${ROOT_MOUNT}/proc
    busybox.suid mount -n --move /sys ${ROOT_MOUNT}/sys
    busybox.suid mount -n --move /dev ${ROOT_MOUNT}/dev
    return ${STATUS_OK}
}

SwitchToSystem() {
    exec busybox switch_root ${ROOT_MOUNT} /sbin/init
    LOGD "switch_root failure: We are not expected to reach here..."
}

#
# Mount the root file system
#
MountSystem () {
    local parti_name="${UBI_PART_NAME}"
    local image_type="ubifs"
    local nad_fde_status="disabled"
    local sys_key_index="0"
    local vb_parameter="-k /etc/keys/x509_root.der"
    local vb_option=

    if [ ! -e /bin/dd ]; then
        LOGD "Error: cmd: /bin/dd not found"
        return ${STATUS_ERR}
    fi

    if [ "x${VERITY_ENV}" == "x" ]; then
        VERITY_ENV="/proc/cmdline"
    fi

    if ${Bgrep} 'recovery=' /proc/cmdline > /dev/null; then
        LOGD "Runing to recovery mode"
        if ${Bgrep} -Ew "${RECOVERYFS_DEV}" /proc/mtd > /dev/null; then
            # Recoveryfs is a partition and use ${DM_SYST_NAME} as volume name
            parti_name="${RECOVERYFS_DEV}"
        else
            # Recoveryfs is a UBI volume name in partition: ${parti_name}
            DM_SYST_NAME="${RECOVERYFS_DEV}"
        fi
    fi

    GetStorageDev "${parti_name}"
    if [ $? -ne ${STATUS_OK} ]; then
        LOGD "Error: GetStorageDev failed DEV_NUM=${DEV_NUM}"
        return ${STATUS_ERR}
    fi

    # Check if it is UBI partition
    if ${Bdd} if=/dev/mtd${DEV_NUM} count=1 bs=4 2>/dev/null | ${Bgrep} 'UBI#' > /dev/null; then

        ubiattach -m ${DEV_NUM} -d ${SYS_UBI_DEV_NUM} -b ${MTD_UBI_BEB_LIMIT_PER1024}
        WaitDevReady "-e" "/sys/class/ubi/ubi${SYS_UBI_DEV_NUM}/volumes_count"
        if [ $? -ne ${STATUS_OK} ]; then
            LOGD "Error: /sys/class/ubi/ubi${SYS_UBI_DEV_NUM}/volumes_count not found"
            return ${STATUS_ERR}
        fi

        # Get the boot system volume number
        GetUbiVolumeID ${SYS_UBI_DEV_NUM} ${DM_SYST_NAME}
        if [ "${GetUbiVolumeID_RESULT}" == "" ]; then
            LOGD "Cannot get ${DM_SYST_NAME} volume."
            return ${STATUS_ERR}
        fi
        SYS_IMAGE_VOL=${GetUbiVolumeID_RESULT}

        if [ "${SYS_IMAGE_VOL}" == "" ]; then
            LOGD "Cannot get ${DM_SYST_NAME} volume."
            return ${STATUS_ERR}
        fi

        char_device=/dev/ubi${SYS_UBI_DEV_NUM}_${SYS_IMAGE_VOL}
        block_device=/dev/ubiblock${SYS_UBI_DEV_NUM}_${SYS_IMAGE_VOL}

        # Check if the image type is squashfs in UBI volume
        if ${Bdd} if=${char_device}\
            count=1 bs=4 2>/dev/null | ${Bgrep} 'hsqs' > /dev/null; then
            image_type="squashfs"
        elif ${Bdd} if=${char_device} count=1 bs=4 2>/dev/null |\
            ${Bhexdump} | ${Bgrep} "${UBIFS_VOL_HEADER}" > /dev/null; then
            image_type="ubifs"
        else
            image_type="unknown"
        fi

        # UBIFS don't support signing, so won't work with FDE
        if [ "${image_type}" != "ubifs" ]; then
            if ${Bgrep} 'nad_fde=1' ${VERITY_ENV} > /dev/null; then

                # 4+4 device has not enough ram size for FDE encryption
                # So, skip encryption if the memory is smaller than ${RAM_SIZE_LIMIT_VOL}
                supported_mem_size=`free -m | ${Bgrep} Mem | ${Bawk} '{print $2}'`
                if [ ${supported_mem_size} -gt ${RAM_SIZE_LIMIT_VOL} ]; then

                    nad_fde_status="enabled"

                    # Currently, only squashfs image is supported for FDE. If the image magic
                    # isn't squashfs type "hsqs", then suppose this partition was encrypted.
                    # And, after decrypted, it still squashfs type.
                    if [ "${image_type}" == "unknown" ]; then
                        image_type="squashfs"
                    fi
                else
                    LOGD "Warning: Memory size ${supported_mem_size} is too small, skip FDE."
                fi
            fi
        fi

        if [ "${image_type}" == "squashfs" ]; then

            if [ ! -e "${block_device}" ]; then
                ubiblock --create "${char_device}"
                WaitDevReady "-b" "${block_device}"
                if [ $? -ne ${STATUS_OK} ]; then
                    LOGD "Error: EncryptUbiPartition no device: ${block_device} found"
                    return ${STATUS_ERR}
                fi
            fi

            # For system and/or other partitions FDE enabling
            if [ "${nad_fde_status}" == "enabled" ]; then

                sys_key_index=`${Bcat} /proc/cmdline | ${Bsed} 's/ /\n/g' |\
                                    ${Bgrep} -E 'fde\.system' | ${Bawk} -F '.' '{print $3}'`

                EncryptUbiPartition ${DM_SYST_NAME} \
                                    ${SYS_UBI_DEV_NUM} \
                                    ${SYS_IMAGE_VOL} \
                                    ${sys_key_index} \
                                    "${vb_parameter}"

                if [ $? -ne ${STATUS_OK} ] ; then
                    LOGD "Encrypt partition ${DM_SYST_NAME} failed."
                    return ${STATUS_ERR}
                fi
                block_device=${FDE_MOUNT_NODE}
                LOGD "fde: block_device=${block_device}"

                # Before encryption, the image should pass the signing verify first.
                # For NONE system partition, the verification CA was stored at the
                # end of system image. We can get it from one of below interfaces:
                # "/dev/ubiblockx_x" or "/dev/mapper/system".
                EncryptNotSysPartition ${block_device}
                if [ $? -ne ${STATUS_OK} ]; then
                    LOGD "Error: MountSystem no device: ${block_device} found"
                    return ${STATUS_ERR}
                fi

            # For root file system Verified boot enabling
            elif ${Bgrep} 'nad_avb=1' ${VERITY_ENV} > /dev/null; then
                dm_verity_device=/dev/mapper/${DM_SYST_NAME}
                if ${Bgrep} 'secure=1' /proc/cmdline > /dev/null; then
                    vb_option="-s"
                fi
                verified-boot -n ${DM_SYST_NAME} -d ${block_device} -k ${CERT_CA_PATH} ${vb_option}

                if [ $? -ne ${STATUS_OK} ] ; then
                    LOGD "Created dm-verity device ${dm_verity_device} failed."
                    return ${STATUS_ERR}
                fi
                WaitDevReady "-b" "${dm_verity_device}"
                if [ $? -ne ${STATUS_OK} ]; then
                   LOGD "Failed to wait on ${dm_verity_device}, exiting."
                   return ${STATUS_ERR}
                else
                    block_device=${dm_verity_device}
                fi
            fi

            busybox.suid mount -t ${image_type} ${block_device} ${ROOT_MOUNT} -oro
            if [ $? -ne ${STATUS_OK} ]; then
                LOGD "Error: mount squashfs ${block_device} failed"
                return ${STATUS_ERR}
            fi
        elif [ "${image_type}" == "ubifs" ]; then
            busybox.suid mount -t ${image_type} "${char_device}" ${ROOT_MOUNT} -o bulk_read,ro
            if [ $? -ne ${STATUS_OK} ]; then
                LOGD "Error: mount ubifs ${char_device} failed"
                return ${STATUS_ERR}
            fi
        else
            LOGD "Unknown system type: ${image_type}"
            return ${STATUS_ERR}
        fi
    else
        LOGD "This is not a ubi partition, not support yet"
        return ${STATUS_ERR}
    fi
    return ${STATUS_OK}
}

MainBoot() {

    local tasks_list1="
                    EarlySetup
                    SetArgs
                    MountSystem
                    "

    for task1 in ${tasks_list1}; do
        ${task1}
        if [ $? -ne ${STATUS_OK} ]; then
            LOGD "Error: ${task1} failed"

            # According to the conditions does system switch or reboot
            SlotSwitchReboot
            return ${STATUS_ERR}
        else
            LOGD "Init: ${task1}"
        fi
    done

    local tasks_list2="
                    MoveMountToSystem
                    SwitchToSystem
                    "
    for task2 in ${tasks_list2}; do
        ${task2}
        if [ $? -ne ${STATUS_OK} ]; then
            LOGD "Error: ${task2} failed"
            return ${STATUS_ERR}
        else
            LOGD "Init: ${task2}"
        fi
    done
    return ${STATUS_OK}
}

MainBoot
if [ $? -ne ${STATUS_OK} ]; then
    # Go to edl for all other error cases
    LOGD "Error: going to edl"
    gracefullReboot edl
fi
LOGD "MainBoot Error: InitRamFS boot failed"
