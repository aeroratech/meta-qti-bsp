# Copyright (c) 2021 The Linux Foundation. All rights reserved.

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

#  Function to get most suitable .inc file with list of packages
#  to be installed into root filesystem from layer it is called.
#  Currently deprecated.
def get_bblayer_img_inc(layerkey, d):
    bb.warn("get_bblayer_img_inc task is deprecated, please add packages to appropariate packagegroups.")
    return " "

#  Function to search for machine configs
def machine_search(f, search_path):
    if os.path.isabs(f):
        if os.path.exists(f):
            return f
    else:
        searched = bb.utils.which(search_path, f)
        if searched:
            return searched

def get_size_in_bytes (size):
    import re
    split_size = re.split("[aA-zZ]", size)
    partition_size = split_size[0].strip()

    split_unit = re.split("[0-9]", size)
    split_len = len(split_unit)
    partition_unit = split_unit[split_len-1].strip()

    bb.debug(1, "get_size_in_bytes: unit: %s" %partition_unit)
    bb.debug(1, "get_size_in_bytes: size: %s" %partition_size)

    if (partition_unit.lower() == "KB".lower()):
        size = int(partition_size)*1000
    elif (partition_unit.lower() == "KiB".lower()):
        size = int(partition_size)*1024
    elif (partition_unit.lower() == "MB".lower()):
        size = int(partition_size)*1000*1000
    elif (partition_unit.lower() == "MiB".lower()):
        size = int(partition_size)*1024*1024
    elif (partition_unit.lower() == "GB".lower()):
        size = int(partition_size)*1000*1000*1000
    elif (partition_unit.lower() == "GiB".lower()):
        size = int(partition_size)*1024*1024*1024
    elif (partition_unit.lower() == "TB".lower()):
        size = int(partition_size)*1000*1000*1000*1000
    elif (partition_unit.lower() == "TiB".lower()):
        size = int(partition_size)*1024*1024*1024*1024
    elif (not (partition_unit and partition_unit.strip())):
        size = int(partition_size)
    else:
        bb.note("get_size_in_bytes: unhandled unit")
        size = int(partition_size)
    bb.debug(1, "get_size_in_bytes: final size in bytes: %s" %size)
    return size
