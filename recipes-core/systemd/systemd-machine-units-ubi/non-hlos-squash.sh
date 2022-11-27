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
    act_slot=`cat /proc/cmdline | sed 's/.*SLOT_SUFFIX=//' | awk '{print $1}' | tr -d '"'`
    echo "active slot is $act_slot "  > /dev/kmsg
    firmware_ab_name=${firmware}${act_slot}
    volcount=`cat ${UBI_SYS_CLASS}/volumes_count`
    for vid in `seq 0 $volcount`; do
        echo $vid  > /dev/kmsg
        name=`cat ${UBI_SYS_CLASS}_$vid/name`
        if [ "$name" == "$firmware" ] || [ "$name" == "$firmware_ab_name" ]; then
            echo "volume id found for $firmware_ab_name, volume id $vid "  > /dev/kmsg
            echo $vid
            break
        fi
        echo $name  > /dev/kmsg
    done
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

   char_device=/dev/ubi0_0
   # Check if the image type is squashfs in UBI volume
   if dd if=${char_device}\
       count=1 bs=4 2>/dev/null | grep 'hsqs' > /dev/null; then
       image_type="squashfs"
   elif dd if=${char_device} count=1 bs=4 2>/dev/null |\
       hexdump | grep "${UBIFS_VOL_HEADER}" > /dev/null; then
       image_type="ubifs"
   else
       image_type="unknown"
   fi
   echo "root fstype is $image_type " > /dev/kmsg

   if [ "$image_type" == "squashfs" ]; then
       echo "mounting modem squashfs image " > /dev/kmsg
       mount -t squashfs $block_device $dir -o ro
   else
       echo "mounting modem ubifs image " > /dev/kmsg
       mount -t ubifs $device $dir -o bulk_read
   fi

   if [ $? -ne 0 ] ; then
      echo "Unable to mount firmware volume "
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
