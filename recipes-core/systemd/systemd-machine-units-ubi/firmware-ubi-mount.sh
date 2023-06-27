#!/bin/sh
# Copyright (c) 2018, The Linux Foundation. All rights reserved.
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
# IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Changes from Qualcomm Innovation Center are provided under the following license:
# Copyright (c) 2023 Qualcomm Innovation Center, Inc. All rights reserved.
# SPDX-License-Identifier: BSD-3-Clause-Clear

FindAndMountUBI () {
   partition=$1
   dir=$2
   extra_opts=$3

   echo "MTD : Detected block device : $dir for $partition"
   mkdir -p $dir

   device=/dev/ubi1_0

   if [ "$SLOT_SUFFIX" = "_b" ]
   then
        device=/dev/ubi2_0
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

FindAndMountUBIVolume () {
   partition=$1
   dir=$2
   extra_opts=$3

   mkdir -p $dir
   eval mount -t ubifs $partition $dir -o bulk_read$extra_opts
   if [ $? -ne 0 ] ; then
       echo "Modem $partition mount failed" > /dev/kmsg
   fi
}

mtd_file=/proc/mtd
if [ -x /sbin/restorecon ]; then
    firmware_selinux_opt=",context=system_u:object_r:firmware_t:s0"
else
    firmware_selinux_opt=""
fi


cmdline=`cat /proc/cmdline | grep -i -w SLOT_SUFFIX`

if [ ! -z "$cmdline" ];
then
    modem_var="firmware$SLOT_SUFFIX"
    is_modem_vol_enabled=`ubinfo -a | grep -i -w -E $modem_var | sed 's/^Name://' | sed 's/ //g'`
    if [ ! -z "$is_modem_vol_enabled" ];
    then
        eval FindAndMountUBIVolume ubi0:$is_modem_vol_enabled /firmware $firmware_selinux_opt
    else
        ubi_dev_id=1
        modem_part_name="modem$SLOT_SUFFIX|modem"
        if [ "$SLOT_SUFFIX" = "_b" ];
        then
            ubi_dev_id=2
            modem_part_name="modem$SLOT_SUFFIX"
        fi
        mtd_block_number=`cat $mtd_file | grep -i -w -E $modem_part_name | sed 's/^mtd//' | awk -F ':' '{print $1}'`
        ubiattach -m $mtd_block_number -d $ubi_dev_id /dev/ubi_ctrl
        eval FindAndMountUBI modem$SLOT_SUFFIX /firmware $firmware_selinux_opt
        mtd_block_number=`cat $mtd_file | grep -i misc | sed 's/^mtd//' | awk -F ':' '{print $1}'`
        chown 1000:6 /dev/mtd$mtd_block_number
    fi
else
    mtd_block_number=`cat $mtd_file | grep -i -w modem | sed 's/^mtd//' | awk -F ':' '{print $1}'`
    ubiattach -m $mtd_block_number -d 1 /dev/ubi_ctrl
    eval FindAndMountUBI modem /firmware $firmware_selinux_opt
fi

exit 0
