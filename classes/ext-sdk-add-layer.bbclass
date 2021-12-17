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

# This function creates a script to add layers of an external workspace
# to an extensible SDK
ext_sdk_add_external_layers_script() {
        add_external_layers_script=${1:-${SDK_OUTPUT}/${SDKPATH}/add_external_layers}
        rm -f $add_external_layers_script
        touch $add_external_layers_script
        echo 'current_working_dir=`pwd`' >> $add_external_layers_script
        echo 'read -p  "Please enter the path to root of the workspace: " workspace_root' >> $add_external_layers_script
        echo 'cd ${workspace_root}/poky' >> $add_external_layers_script
        echo 'rm -rf layerlist.txt' >> $add_external_layers_script
        echo 'touch layerlist.txt' >> $add_external_layers_script
        echo 'echo "`find -name layer.conf`" >> layerlist.txt' >> $add_external_layers_script
        echo "sed -i 's+conf/layer.conf+ +g' layerlist.txt" >> $add_external_layers_script
        echo 'lines=`cat layerlist.txt`' >> $add_external_layers_script
        echo ': > layerlist.txt' >> $add_external_layers_script
        echo '' >> $add_external_layers_script
        echo 'for var in ${lines}' >> $add_external_layers_script
        echo 'do' >> $add_external_layers_script
        echo '     var=${var::${#var}-1}' >> $add_external_layers_script
        echo '     var=${var:2}' >> $add_external_layers_script
        echo '     echo "$var" >> layerlist.txt' >> $add_external_layers_script
        echo 'done' >> $add_external_layers_script
        echo '' >> $add_external_layers_script
        echo 'lines=`cat layerlist.txt`' >> $add_external_layers_script
        echo '' >> $add_external_layers_script
        echo 'for var in ${lines}' >> $add_external_layers_script
        echo 'do' >> $add_external_layers_script
        echo '    grep -v "${var} " ${SDK_ROOT}/conf/bblayers.conf > ${SDK_ROOT}/conf/tmp-bblayers.conf' >> $add_external_layers_script
        echo '    mv ${SDK_ROOT}/conf/tmp-bblayers.conf ${SDK_ROOT}/conf/bblayers.conf' >> $add_external_layers_script
        echo 'done' >> $add_external_layers_script
        echo '' >> $add_external_layers_script
        echo 'echo "BBLAYERS += \" \ " >> ${SDK_ROOT}/conf/bblayers.conf' >> $add_external_layers_script
        echo 'for var in ${lines}' >> $add_external_layers_script
        echo 'do' >> $add_external_layers_script
        echo '    if [[ -r ${workspace_root}/poky/${var}/conf/layer.conf ]] ;' >> $add_external_layers_script
        echo '    then' >> $add_external_layers_script
        echo '        echo "    ${workspace_root}/poky/${var} \ " >> ${SDK_ROOT}/conf/bblayers.conf' >> $add_external_layers_script
        echo '        echo "`tput setaf 2`${workspace_root}/poky/${var} has been added as a layer to the eSDK`tput sgr0`"' >> $add_external_layers_script
        echo '    else' >> $add_external_layers_script
        echo '        echo "`tput setaf 3`Unable to read ${workspace_root}/poky/${var}/conf/layer.conf`tput sgr0`"' >> $add_external_layers_script
        echo '    fi' >> $add_external_layers_script
        echo 'done' >> $add_external_layers_script
        echo 'echo "    \"" >> ${SDK_ROOT}/conf/bblayers.conf' >> $add_external_layers_script
        echo 'rm layerlist.txt' >> $add_external_layers_script
        echo '' >> $add_external_layers_script
        echo 'cp -rf ${workspace_root}/src/* ${SDK_ROOT}/src' >> $add_external_layers_script
        echo 'cd ${current_working_dir}' >> $add_external_layers_script
}
