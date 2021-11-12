# Copyright (c) 2021 The Linux Foundation. All rights reserved.
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

# This function creates a script to add custom bitbake layers
# to an extensible SDK.
ext_sdk_add_layer_script() {
        add_layer_script=${1:-${SDK_OUTPUT}/${SDKPATH}/add_bitbake_layer}
        rm -f $add_layer_script
        touch $add_layer_script
        echo 'read -p  "Please enter the path to your custom layer: " layer_path' >> $add_layer_script
        echo 'if [[ -r ${layer_path}/conf/layer.conf ]] ;' >> $add_layer_script
        echo 'then' >> $add_layer_script
        echo '    working_dir=`pwd`' >> $add_layer_script
        echo '    cd ${SDK_ROOT}' >> $add_layer_script
        echo '    ${SDK_ROOT}/layers/poky/bitbake/bin/bitbake-layers add-layer ${layer_path}' >> $add_layer_script
        echo '    echo "Your layer is successfully added to the eSDK workspace."' >> $add_layer_script
        echo '    echo "You may now start the development using devtools"' >> $add_layer_script
        echo '    cd ${working_dir}' >> $add_layer_script
        echo 'else' >> $add_layer_script
        echo '    echo "`tput setaf 3`Specified layer directory ${layer_path} does not contain a conf/layer.conf file`tput sgr0`"' >> $add_layer_script
        echo 'fi' >> $add_layer_script
}
