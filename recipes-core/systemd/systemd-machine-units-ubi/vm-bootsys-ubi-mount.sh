#!/bin/sh
# Copyright (c) 2023 Qualcomm Innovation Center, Inc. All rights reserved.
# SPDX-License-Identifier: BSD-3-Clause-Clear

UBI_SYS_CLASS="/sys/class/ubi/ubi0"
UBI_DEV_BLOCK="/dev/ubiblock0"
SQUASHFS_IMG="1"

GetVMBootSysVolumeID () {
    partition=$1
    volcount=`cat ${UBI_SYS_CLASS}/volumes_count`

    for vid in `seq 0 $volcount`; do
        name=`cat ${UBI_SYS_CLASS}_$vid/name`
        if [ "$name" == "$partition" ]; then
            echo $vid
            break
        fi
    done
}

FindAndMountUBI () {
    partition=$1
    dir=$2
    extra_opts=$3
    ubi_dev_id=$4

    echo "MTD : Detected block device : $dir for $partition"
    mkdir -p $dir

    device="/dev/ubi$ubi_dev_id""_0"

    while [ 1 ]
     do
        if [ -c $device ]
        then
            test -x /sbin/restorecon && /sbin/restorecon $device
            mount -t ubifs $device $dir -o bulk_read$extra_opts
            break
        else
            sleep 0.010
        fi
     done

    chown -R root:root /vm-bootsys
}

FindAndMountUBIVolume () {
    partition=$1
    dir=$2
    extra_opts=$3
    ubi_dev_id=$4

    volid=$(GetVMBootSysVolumeID $partition)
    if [ "$volid" == "" ]; then
        echo "volume index not found for $partition volume "  > /dev/kmsg
        exit 0
    fi

    device=/dev/ubi0_$volid
    block_device=${UBI_DEV_BLOCK}_$volid

    if [ "$SQUASHFS_IMG" == "1" ]; then
        ubiblock --create $device
        eval mount -t squashfs $block_device $dir -o ro$extra_opts
    else
        eval mount -t ubifs ubi$ubi_dev_id:$partition $dir -o bulk_read$extra_opts
     fi

    if [ $? -ne 0 ] ; then
        echo "$partition volume mount failed" > /dev/kmsg
        exit 0
     fi
}

if [ -x /sbin/restorecon ]; then
    vm_bootsys_selinux_opt=",context=system_u:object_r:vm-bootsys_t:s0"
else
    vm_bootsys_selinux_opt=""
fi

# SLOT_SUFFIX is not available it is hardcode for now
num_volume=`ubinfo -a | grep -o -i "vm-bootsys" | wc -l`
if [ "x${SLOT_SUFFIX}" == "x" ] && [ ${num_volume} == "2" ]; then
    SLOT_SUFFIX="_a"
fi

mtd_file=/proc/mtd
vm_bootsys_part_name="vm-bootsys$SLOT_SUFFIX"
is_vm_bootsys_vol_enabled=`ubinfo -d 0 -N $vm_bootsys_part_name`

if [ ! -z "$is_vm_bootsys_vol_enabled" ];
then
    ubi_dev_id=0
    eval FindAndMountUBIVolume $vm_bootsys_part_name /vm-bootsys $vm_bootsys_selinux_opt $ubi_dev_id
else
    ubi_dev_id=4
    if [ "$SLOT_SUFFIX" != "_b" ];
    then
        ubi_dev_id=3
        vm_bootsys_part_name="vm-bootsys$SLOT_SUFFIX|vm-bootsys"
    fi
    mtd_block_number=`cat $mtd_file | grep -i -w -E $vm_bootsys_part_name | sed 's/^mtd//' | awk -F ':' '{print $1}'`
    ubiattach -m $mtd_block_number -d $ubi_dev_id /dev/ubi_ctrl

    eval FindAndMountUBI vm-bootsys$SLOT_SUFFIX /vm-bootsys $vm_bootsys_selinux_opt $ubi_dev_id
fi

chown -R root:root /vm-bootsys

exit 0
