#!/bin/sh
# Copyright (c) 2022 Qualcomm Innovation Center, Inc. All rights reserved.
# SPDX-License-Identifier: BSD-3-Clause-Clear

counter=0
while [ ! -e /dev/mapper/persist ]; do
    counter=$((counter + 1))
    sleep 0.1
done
counter=$((counter * 100))
echo "/dev/mapper/persist ready, time = $counter ms"

blkid /dev/mapper/persist | grep "/dev/mapper/persist"
persistfmt=$?
if [ -b "/dev/mapper/persist" -a $persistfmt -ne 0 ]; then
    mkfs.ext4 /dev/mapper/persist
else
    echo "persist already formatted, directly mounting"
fi
mount -t ext4 /dev/mapper/persist /persist -o rootcontext=system_u:object_r:persist_t:s0
