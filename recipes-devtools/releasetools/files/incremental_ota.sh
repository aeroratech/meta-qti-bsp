#!/bin/sh
# Copyright (c) 2017, The Linux Foundation. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above
#       copyright notice, this list of conditions and the following
#       disclaimer in the documentation and/or other materials provided
#       with the distribution.
#     * Neither the name of The Linux Foundation nor the names of its
#       contributors may be used to endorse or promote products derived
#       from this software without specific prior written permission.
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
#
# incremental_ota.sh     script to generate OTA upgrade pacakges.
# if sign is part of arguments, the testkey.pk8 located at OTA/build/target/product/security is taken as private key.
# OEMs can replaces this file with their own private key.

# Changes from Qualcomm Innovation Center are provided under the following license:
# Copyright (c) 2022 Qualcomm Innovation Center, Inc. All rights reserved.
# SPDX-License-Identifier: BSD-3-Clause-Clear

set -o xtrace

if [ "$#" -lt 5 ]; then
    echo "Usage  : $0 v1_target_files_zipfile v2_target_files_zipfile rootfs_path ext4_or_ubi [-c fsconfig_file [-p prefix]][--system_path path] [--sign]"
    echo "----------------------------------------------------------------------------------------------------"
    echo "example: $0 v1_target_files_ubi.zip  v2_target_files_ubi.zip  machine-image/1.0-r0/rootfs ubi --system_path <path>"
    echo "example: $0 v1_target_files_ext4.zip v2_target_files_ext4.zip machine-image/1.0/rootfs ext4 --system_path <path>"
    echo "example: $0 v1_target_files_ext4.zip v2_target_files_ext4.zip machine-image/1.0/rootfs ext4 --block --system_path <path>"
    echo "example: $0 v1_target_files_ext4.zip  v2_target_files_ext4.zip  machine-image/1.0-r0/rootfs ext4 --sign"
    exit 1
fi

export PATH=.:$PATH:/usr/bin
export OUT_HOST_ROOT=.

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export FSCONFIGFOPTS=" "
block_based=" "
python_version="python3"
system_path=" "
mirror_sync= ""
install_only=" "

if [ "$#" -gt 5 ]; then
    IFS=' ' read -a allopts <<< "$@"
    for i in $(seq 4 $#); do
       if [ "${allopts[${i}]}" = "--block" ]; then
           block_based="${allopts[${i}]}"
       elif [ "${allopts[${i}]}" = "--system_path" ]; then
           i=$((i+1))
           system_path="${allopts[${i}]}"
       elif [ "${allopts[${i}]}" = "--sign" ]; then
           sign_ota_package="${allopts[${i}]}"
       elif [ "${allopts[${i}]}" = "--mirror_sync" ]; then
           mirror_sync="${allopts[${i}]}"
       elif [ "${allopts[${i}]}" = "--install_only" ]; then
           install_only="${allopts[${i}]}"
       else
           FSCONFIGFOPTS=$FSCONFIGFOPTS${allopts[${i}]}" "
       fi
    done
fi

# Specify MMC or MTD type device. MTD by default
[[ $4 = "ext4" ]] && device_type="MMC" || device_type="MTD"

# Setup temp folder to unzip target files
target_files=target_files_incremental_$4
rm -rf $target_files
unzip -qo $2 -d $target_files
mkdir -p $target_files/META
mkdir -p $target_files/SYSTEM

if [ "${block_based}" = "--block" ]; then
    # python2 is needed for block based OTA.
    python_version="python2"
else
    # File-based OTA needs this to assign the correct context to '/' after OTA upgrade
    echo "/system -d system_u:object_r:root_t:s0" >> $target_files/BOOT/RAMDISK/file_contexts

    # File-based OTA also can use canned_fs_config to set uid, gid & mode to all the files
    # The "-x" is to tell fs_config that the modes in fsconfig file are in hex, not octal.
    if [ -e $target_files/META/system.canned.fsconfig ]; then
        FSCONFIGFOPTS=${FSCONFIGFOPTS}" -p system/ -x $target_files/META/system.canned.fsconfig "
    fi
fi

# Generate selabel rules only if file_contexts is packed in target-files
if grep "selinux_fc" $target_files/META/misc_info.txt
then
    zipinfo -1 $2 |  awk 'BEGIN { FS="SYSTEM/" } /^SYSTEM\// {print "system/" $2}' | fs_config ${FSCONFIGFOPTS} -C -S $target_files/BOOT/RAMDISK/file_contexts -D ${3} > $target_files/META/filesystem_config.txt
else
    zipinfo -1 $2 |  awk 'BEGIN { FS="SYSTEM/" } /^SYSTEM\// {print "system/" $2}' | fs_config ${FSCONFIGFOPTS} -D ${3} > $target_files/META/filesystem_config.txt
fi

cd $target_files && zip -q $2 META/*filesystem_config.txt SYSTEM/build.prop && cd ..

$python_version ./ota_from_target_files $block_based  $mirror_sync $install_only -n -v -d $device_type -v -p . -m linux_embedded --no_signing --system_mount_path $system_path -i $1 $2 update_incr_$4.zip > ota_debug.txt 2>&1

if [[ $? = 0 ]]; then
    echo "OTA zip signing started"
    if [ "${sign_ota_package}" = "--sign" ]; then
    # Pipe the contents of OTA zip to openssl to generate the signature of the OTA zip
        unzip -p update_incr_$4.zip | openssl dgst -sha256 -sign private.pem -out update.sig
        if [[ $? = 0 ]]; then
            zip -q -u update_incr_$4.zip update.sig
            echo "OTA zip signing is successful"
        else
            echo "OTA zip signing is failed"
        fi
    else
        echo "update_incr_$4.zip generation was successful"
    fi
else
    echo "update_incr_$4.zip generation failed"
    # Add the python script errors back into the target-files zip
    zip -q $1 ota_debug.txt
    rm update_incr_$4.zip # delete the half-baked update.zip if any;
fi

# Clean up temporary folder.
rm -rf $target_files
