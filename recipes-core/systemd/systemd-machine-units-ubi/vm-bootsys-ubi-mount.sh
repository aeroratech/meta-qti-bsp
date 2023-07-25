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

IsGPIOEnabled () {
    gpio_enable_status=`cat /proc/cmdline | awk -F'recoveryinfo_gpio=' '{print $2}' | awk '{print $1}' | tr -d '"'`
    return ${gpio_enable_status}
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

SlotSwitchReboot () {
    # Set image_set_status fields in recoveryinfo struct
    #  'A &B' Usable     :  SET_AB_USABLE(0)
    #  'A' corrupted     :  DONT_USE_SET_A(1)
    #  'B' corrupted     :  DONT_USE_SET_B(2)
    #  'A &B' corrupted  :  DONT_USE_SET_AB(3)

    # Set owner fields in recoveryinfo struct
    #  OWNER_XBL         :  1
    #  OWNER_HLOS        :  2
    local abctl_cmd="/usr/bin/nad-abctl"
    local owner_hlos=2
    local dont_use_set_a=1
    local dont_use_set_b=2
    local dont_use_set_ab=3
    local vmbootsys_a="vm-bootsys_a"
    local vmbootsys_b="vm-bootsys_b"
    local current_image_set_status=0

    # TODO GPIO needs to be handled
    if [ ! -e ${abctl_cmd} ]; then
        echo "${abctl_cmd} not found, reboot to edl " > /dev/kmsg
        /bin/sh -c 'reboot edl'
    fi

    mtd_device=`cat /proc/mtd | grep recoveryinfo | awk -F ':' '{print $1}'`
    if [ -z "${mtd_device}" ]; then
        echo " recoveryinfo part not found, reboot to edl " > /dev/kmsg
        /bin/sh -c 'reboot edl'
    fi
    chmod 666 /dev/${mtd_device}

    vmbootsys_ab_name=$(cat /sys/class/ubi/ubi0_${volid}/name)
    if [ "$vmbootsys_ab_name" == "$vmbootsys_a" ] || [ "$vmbootsys_ab_name" == "$vmbootsys_b" ];
    then
        if [ "x${SLOT_SUFFIX}" == "x" ]; then
            echo "SLOT_SUFFIX not present or invalid, reboot to edl" > /dev/kmsg
            /bin/sh -c 'reboot edl'
         fi

         #Get current image set status
         (${abctl_cmd} --get_image_set_status)
         current_image_set_status=$?

         if [ "$current_image_set_status" -eq "-1" ];
         then
            echo "Error: incorrect image set status" > /dev/kmsg
            /bin/sh -c 'reboot edl'
            exit 0
         fi

         if [ "$SLOT_SUFFIX" = "_a" ] && [ "$current_image_set_status" != "$dont_use_set_b" ];
         then
            echo "$vmbootsys_a volume corrupted " > /dev/kmsg
            ${abctl_cmd} --set_image_set_status ${dont_use_set_a}
            if [ "$?" -eq "-1" ]; then
               echo "Error: image set status failed" > /dev/kmsg
               /bin/sh -c 'reboot edl'
            fi
         elif [ "$SLOT_SUFFIX" = "_b" ] && [ "$current_image_set_status" != "$dont_use_set_a" ];
         then
            echo "$vmbootsys_b volume corrupted " > /dev/kmsg
            ${abctl_cmd} --set_image_set_status ${dont_use_set_b}
            if [ "$?" -eq "-1" ]; then
               echo "Error: image set status failed" > /dev/kmsg
               /bin/sh -c 'reboot edl'
            fi
         else
            echo "$vmbootsys_a and $vmbootsys_b volume corrupted" > /dev/kmsg
            ${abctl_cmd} --set_image_set_status ${dont_use_set_ab}
            if [ "$?" -eq "-1" ]; then
               echo "Error: image set status failed" > /dev/kmsg
               /bin/sh -c 'reboot edl'
            fi
         fi
         ${abctl_cmd} --set_owner ${owner_hlos}
         if [ "$?" -eq "-1" ]; then
            echo "Error: owner set failed" > /dev/kmsg
            /bin/sh -c 'reboot edl'
         fi
         echo "Reboot for switching slots or EDL mode" > /dev/kmsg
         /bin/sh -c 'reboot'
      else
         echo "non a/b volumes , reboot to edl " > /dev/kmsg
         /bin/sh -c 'reboot edl'
      fi
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
       IsGPIOEnabled
       if [ "$?" -eq "1" ]; then
          #GPIO Enabled keeping behavior similar to Mount failure.
          echo "GPIO Enabled donot switch slots" > /dev/kmsg
       elif [ "$?" -eq "0" ]; then
          echo "GPIO disabled switch slots" > /dev/kmsg
          SlotSwitchReboot
       else
          echo "GPIO status invalid" > /dev/kmsg
       fi
       exit 0
    fi
}

if [ -x /sbin/restorecon ]; then
    vm_bootsys_selinux_opt=",context=system_u:object_r:vm-bootsys_t:s0"
else
    vm_bootsys_selinux_opt=""
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
