#!/bin/sh
# Copyright (c) 2023 Qualcomm Innovation Center, Inc. All rights reserved.
# SPDX-License-Identifier: BSD-3-Clause-Clear

FindAndMountUBI () {
   partition=$1
   dir=$2
   extra_opts=$3

   mtd_block_number=`cat $mtd_file | grep -i $partition | sed 's/^mtd//' | awk -F ':' '{print $1}'`
   echo "MTD : Detected block device : $dir for $partition"
   mkdir -p $dir

   ubiattach -m $mtd_block_number -d 2 /dev/ubi_ctrl
   device=/dev/ubi2_0
   while [ 1 ]
    do
        if [ -c $device ]
        then
            test -x /sbin/restorecon && /sbin/restorecon $device
            mount -t ubifs /dev/ubi2_0 $dir -o bulk_read
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
eval FindAndMountUBI vm-bootsys /vm-bootsys $vm_bootsys_selinux_opt
eval CreateSplitBinsSymlink /vm-bootsys /firmware/image/

exit 0
