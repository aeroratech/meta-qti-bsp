#!/bin/sh
# Copyright (c) 2023 Qualcomm Innovation Center, Inc. All rights reserved.
# SPDX-License-Identifier: BSD-3-Clause-Clear

FindAndMountUBI () {
   partition=$1
   dir=$2
   extra_opts=$3

   echo "MTD : Detected block device : $dir for $partition"
   mkdir -p $dir

   device=/dev/ubi3_0

   if [ "$SLOT_SUFFIX" = "_b" ]
   then
        device=/dev/ubi4_0
   fi

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
}

CreateSplitBinsSymlink () {
   vmbootsys_dir=$1
   device=$2
   for dir in $vmbootsys_dir/*/boot
    do
        ln -sf $dir/* $device/
    done
}

mtd_file=/proc/mtd
if [ -x /sbin/restorecon ]; then
    vm_bootsys_selinux_opt=",context=system_u:object_r:vm-bootsys_t:s0"
else
    vm_bootsys_selinux_opt=""
fi

if [ $SLOT_SUFFIX ]
then
    mtd_block_number=`cat $mtd_file | grep -i vm-bootsys_a | sed 's/^mtd//' | awk -F ':' '{print $1}'`
    ubiattach -m $mtd_block_number -d 3 /dev/ubi_ctrl

    mtd_block_number=`cat $mtd_file | grep -i vm-bootsys_b | sed 's/^mtd//' | awk -F ':' '{print $1}'`
    ubiattach -m $mtd_block_number -d 4 /dev/ubi_ctrl

    eval FindAndMountUBI vm-bootsys$SLOT_SUFFIX /vm-bootsys $vm_bootsys_selinux_opt
else
    mtd_block_number=`cat $mtd_file | grep -i -w vm-bootsys | sed 's/^mtd//' | awk -F ':' '{print $1}'`
    ubiattach -m $mtd_block_number -d 3 /dev/ubi_ctrl

    eval FindAndMountUBI vm-bootsys /vm-bootsys $vm_bootsys_selinux_opt
fi

eval CreateSplitBinsSymlink /vm-bootsys /firmware/image/

exit 0
