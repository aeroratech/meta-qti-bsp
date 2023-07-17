#!/bin/sh
# Copyright (c) 2019, The Linux Foundation. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#   * Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#   * Redistributions in binary form must reproduce the above
#     copyright notice, this list of conditions and the following
#     disclaimer in the documentation and/or other materials provided
#     with the distribution.
#   * Neither the name of The Linux Foundation nor the names of its
#     contributors may be used to endorse or promote products derived
#     from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT
# ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS
# BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
# BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
# IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE

UBIFS_VOL_HEADER="1831 0610"
UBI_SYS_CLASS="/sys/class/ubi/ubi0"
UBI_DEV_BLOCK="/dev/ubiblock0"

IsFirmwareMounted () {
 mountpoint /firmware
 if [ $? -eq 0 ] ; then
    echo "firmware volume is already mounted" > /dev/kmsg
    exit 0;
 fi
}

GetFirmwareVolumeID () {
    firmware=$1

    if [ "x${SLOT_SUFFIX}" == "x" ]; then
       SLOT_SUFFIX="_a"
    fi

    firmware_ab_name=${firmware}${SLOT_SUFFIX}
    volcount=`cat ${UBI_SYS_CLASS}/volumes_count`
    vol_found=""
    for vid in `seq 0 $volcount`; do
        echo $vid  > /dev/kmsg
        name=`cat ${UBI_SYS_CLASS}_$vid/name`
        if [ "$name" == "$firmware" ] || [ "$name" == "$firmware_ab_name" ]; then
            echo "volume id found for $firmware_ab_name, volume id $vid "  > /dev/kmsg
            echo $vid
            vol_found=${vid}
            break
        fi
        echo $name  > /dev/kmsg
    done
    if [ "${vol_found}" == "" ]; then
       eval FindAndMountUBI modem /firmware
    fi
}

IsGPIOEnabled () {
    gpio_enable_status=`cat /proc/cmdline | awk -F'recoveryinfo_gpio=' '{print $2}' | awk '{print $1}' | tr -d '"'`
    return ${gpio_enable_status}
}

SlotSwitchReboot () {
    local abctl_cmd="/usr/bin/nad-abctl"
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
    local firmware_a="firmware_a"
    local firmware_b="firmware_b"
    local current_image_set_status=0

    if [ ! -e ${abctl_cmd} ]; then
        echo "${abctl_cmd} not found, reboot to edl " > /dev/kmsg
        /bin/sh -c 'reboot edl'
        exit 0
    fi

    mtd_device=`cat /proc/mtd | grep recoveryinfo | awk -F ':' '{print $1}'`
    if [ -z "${mtd_device}" ]; then
        echo " recoveryinfo part not found, reboot to edl " > /dev/kmsg
        /bin/sh -c 'reboot edl'
        exit 0
    fi

    chmod 664 /dev/${mtd_device}
    firmware_ab_name=$(cat /sys/class/ubi/ubi0_${volid}/name)
    if [ "$firmware_ab_name" == "$firmware_a" ] || [ "$firmware_ab_name" == "$firmware_b" ] ; then
        if [ "x${SLOT_SUFFIX}" == "x" ]; then
            echo "SLOT_SUFFIX not present or invalid, reboot to edl" > /dev/kmsg
            /bin/sh -c 'reboot edl'
            exit 0
        fi

        #Get current image set status
        (${abctl_cmd} --get_image_set_status)
        current_image_set_status=$?

        if [ "$current_image_set_status" -eq "-1" ]; then
            echo "Error: incorrect image set status" > /dev/kmsg
            /bin/sh -c 'reboot edl'
            exit 0
        fi

        if [ "$SLOT_SUFFIX" = "_a" ] && [ "$current_image_set_status" != "$dont_use_set_b" ]; then
            echo "firmware A volume corrupted " > /dev/kmsg
            ${abctl_cmd} --set_image_set_status ${dont_use_set_a}
            if [ "$?" -eq "-1" ]; then
                echo "Error: image set status failed" > /dev/kmsg
                /bin/sh -c 'reboot edl'
                exit 0
            fi
        elif [ "$SLOT_SUFFIX" = "_b" ] && [ "$current_image_set_status" != "$dont_use_set_a" ]; then
            echo "firmware B volume corrupted " > /dev/kmsg
            ${abctl_cmd} --set_image_set_status ${dont_use_set_b}
            if [ "$?" -eq "-1" ]; then
                echo "Error: image set status failed" > /dev/kmsg
                /bin/sh -c 'reboot edl'
                exit 0
            fi
        else
            echo "firmware A and B volume corrupted" > /dev/kmsg
            ${abctl_cmd} --set_image_set_status ${dont_use_set_ab}
            if [ "$?" -eq "-1" ]; then
                echo "Error: image set status failed" > /dev/kmsg
                /bin/sh -c 'reboot edl'
                exit 0
            fi
        fi
        ${abctl_cmd} --set_owner ${owner_hlos}
        if [ "$?" -eq "-1" ]; then
            echo "Error: set owner failed" > /dev/kmsg
            /bin/sh -c 'reboot edl'
            exit 0
        fi
        echo "Reboot for switching slots or EDL mode" > /dev/kmsg
        /bin/sh -c 'reboot'
    else
        echo "non a/b volumes , reboot to edl " > /dev/kmsg
        /bin/sh -c 'reboot edl'
        exit 0
    fi
}

FindAndMountUBIVol () {
   partition=$1
   dir=$2
   local image_type="ubifs"
   IsFirmwareMounted

   volid=$(GetFirmwareVolumeID $partition)
   echo "found volume index for firmware mount " $volid  > /dev/kmsg

   if [ "$volid" == "" ]; then
       echo "volume index not found for firmware volume "  > /dev/kmsg
       exit 0
   fi

   device=/dev/ubi0_$volid
   block_device=${UBI_DEV_BLOCK}_$volid
   mkdir -p $dir

   if [ -e "${UBI_DEV_BLOCK}_$volid" ]; then
        echo "${UBI_DEV_BLOCK}_$volid exists" > /dev/kmsg
   else
        echo "${UBI_DEV_BLOCK}_$volid desnt exists, creating" > /dev/kmsg
        ubiblock --create $device
   fi

   # Check if the image type is squashfs in UBI volume
   if dd if=${device}\
       count=1 bs=4 2>/dev/null | grep 'hsqs' > /dev/null; then
       image_type="squashfs"
   elif dd if=${device} count=1 bs=4 2>/dev/null |\
       hexdump | grep "${UBIFS_VOL_HEADER}" > /dev/null; then
       image_type="ubifs"
   else
       image_type="unknown"
   fi
   echo "root fstype is $image_type " > /dev/kmsg

   if [ "$image_type" == "squashfs" ]; then
       mount -t squashfs $block_device $dir -o ro
   elif [ "$image_type" == "ubifs" ]; then
       mount -t ubifs $device $dir -o bulk_read
   else
       echo "not an ubi partiton" > /dev/kmsg
       IsGPIOEnabled
       if [ $? -eq 1 ]; then
           #GPIO Enabled keeping behavior similar to Mount failure.
           echo "GPIO Enabled donot switch slots" > /dev/kmsg
       elif [ $? -eq 0 ]; then
           echo "GPIO disabled switch slots" > /dev/kmsg
           SlotSwitchReboot
       else
           echo "GPIO status invalid" > /dev/kmsg
       fi
       exit 0
   fi

   if [ $? -ne 0 ] ; then
      echo "Unable to mount firmware volume " > /dev/kmsg
      IsGPIOEnabled
      if [ $? -eq 1 ]; then
          #GPIO Enabled keeping behavior similar to Mount failure.
          echo "GPIO Enabled donot switch slots" > /dev/kmsg
      elif [ $? -eq 0 ]; then
          echo "GPIO disabled switch slots" > /dev/kmsg
          SlotSwitchReboot
      else
          echo "GPIO status invalid" > /dev/kmsg
      fi
      exit 0
   fi
}

FindAndMountUBI () {
   partition=$1
   dir=$2

   mtd_block_number=`cat $mtd_file | grep -i $partition | sed 's/^mtd//' | awk -F ':' '{print $1}'`
   echo "MTD : Detected block device : $dir for $partition"
   mkdir -p $dir

   ubiattach -m $mtd_block_number
   non_hlos_block=`cat $mtd_file | grep -i nonhlos-fs | sed 's/^mtd//' | awk -F ':' '{print $1}'`
   device=/dev/mtdblock$non_hlos_block
   while [ 1 ]
    do
        if [ -b $device ]
        then
            mount $device /firmware
            break
        else
            sleep 0.010
        fi
    done
}
mtd_file=/proc/mtd
eval FindAndMountUBI modem /firmware
exit 0
