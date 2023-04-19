#!/bin/sh
# Copyright (c) 2023 Qualcomm Innovation Center, Inc. All rights reserved.
# SPDX-License-Identifier: BSD-3-Clause-Clear

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

   mkdir -p $dir
   eval mount -t ubifs $partition $dir -o bulk_read$extra_opts
   if [ $? -ne 0 ] ; then
       echo "vm-bootsys mount failed" > /dev/kmsg
   fi
}

if [ -x /sbin/restorecon ]; then
    vm_bootsys_selinux_opt=",context=system_u:object_r:vm-bootsys_t:s0"
else
    vm_bootsys_selinux_opt=""
fi

mtd_file=/proc/mtd
vm_bootsys_part_name="vm-bootsys$SLOT_SUFFIX"
is_vm_bootsys_vol_enabled=`ubinfo -a | grep -i -w $vm_bootsys_part_name`

if [ ! -z "$is_vm_bootsys_vol_enabled" ];
then
    eval FindAndMountUBIVolume ubi0:$vm_bootsys_part_name /vm-bootsys $vm_bootsys_selinux_opt
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
