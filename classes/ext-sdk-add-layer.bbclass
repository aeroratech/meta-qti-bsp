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
        echo '' >> $add_external_layers_script
        echo 'workspace_root=""' >> $add_external_layers_script
        echo 'modify_recipes=""' >> $add_external_layers_script
        echo 'while test $# -gt 0; do' >> $add_external_layers_script
        echo '  case "$1" in' >> $add_external_layers_script
        echo '    -h|--help)' >> $add_external_layers_script
        echo '      echo " "' >> $add_external_layers_script
        echo '      echo "add_external_layers script lets you add layers of an external workspace to the eSDK."' >> $add_external_layers_script
        echo '      echo "Developer can choose to pass arguments as flags or enter them interactively during run-time"' >> $add_external_layers_script
        echo '      echo " "' >> $add_external_layers_script
        echo '      echo "Usage:"' >> $add_external_layers_script
        echo '      echo "       source add_external_layers -p [path to external workspace] -m [y/n]"' >> $add_external_layers_script
        echo '      echo " "' >> $add_external_layers_script
        echo '      echo "Options:"' >> $add_external_layers_script
        echo '      echo "-h, --help                show brief help"' >> $add_external_layers_script
        echo '      echo "-p, --path                path to external workspace"' >> $add_external_layers_script
        echo '      echo "-m, --modify              y if modify needs to be performed for all recipes, else n"' >> $add_external_layers_script
        echo '      echo " "' >> $add_external_layers_script
        echo '      return' >> $add_external_layers_script
        echo '      ;;' >> $add_external_layers_script
        echo '    -p|--path)' >> $add_external_layers_script
        echo '     shift' >> $add_external_layers_script
        echo '      if test $# -gt 0; then' >> $add_external_layers_script
        echo '        workspace_root=$1' >> $add_external_layers_script
        echo '        echo "workspace_root=${workspace_root}"' >> $add_external_layers_script
        echo '      else' >> $add_external_layers_script
        echo '        workspace_root=""' >> $add_external_layers_script
        echo '      fi' >> $add_external_layers_script
        echo '      shift' >> $add_external_layers_script
        echo '      ;;' >> $add_external_layers_script
        echo '    -m|--modify)' >> $add_external_layers_script
        echo '      shift' >> $add_external_layers_script
        echo '      if test $# -gt 0; then' >> $add_external_layers_script
        echo '        modify_recipes=$1' >> $add_external_layers_script
        echo '        if [ "$modify_recipes" == "y" ] || [ "$modify_recipes" == "Y" ] ;' >> $add_external_layers_script
        echo '        then' >> $add_external_layers_script
        echo '            echo "\"devtool modify\" operation will be performed for all new recipes"' >> $add_external_layers_script
        echo '        elif [ "$modify_recipes" == "n" ] || [ "$modify_recipes" == "N" ] ;' >> $add_external_layers_script
        echo '        then' >> $add_external_layers_script
        echo '            echo "\"devtool modify\" operation will not be performed with this run"' >> $add_external_layers_script
        echo '        else' >> $add_external_layers_script
        echo '            modify_recipes="N"' >> $add_external_layers_script
        echo '            echo "`tput setaf 3`$modify_recipes : Invalid option for --modify passed. Taken \"N\" by deafult`tput sgr0`"' >> $add_external_layers_script
        echo '        fi' >> $add_external_layers_script
        echo '      else' >> $add_external_layers_script
        echo '        modify_recipes=""' >> $add_external_layers_script
        echo '      fi' >> $add_external_layers_script
        echo '      shift' >> $add_external_layers_script
        echo '      ;;' >> $add_external_layers_script
        echo '  esac' >> $add_external_layers_script
        echo 'done' >> $add_external_layers_script
        echo '' >> $add_external_layers_script
        echo 'current_working_dir=`pwd`' >> $add_external_layers_script
        echo '' >> $add_external_layers_script
        echo 'if [[ "$workspace_root" == "" ]] ;' >> $add_external_layers_script
        echo 'then' >> $add_external_layers_script
        echo '    read -p  "Please enter the absolute path to root of the workspace: " workspace_root' >> $add_external_layers_script
        echo 'fi' >> $add_external_layers_script
        echo '' >> $add_external_layers_script
        echo 'if [ -d "${workspace_root}/poky" ];' >> $add_external_layers_script
        echo 'then' >> $add_external_layers_script
        echo '    cd ${workspace_root}/poky' >> $add_external_layers_script
        echo '    rm -rf layerlist.txt' >> $add_external_layers_script
        echo '    touch layerlist.txt' >> $add_external_layers_script
        echo '    echo "`find -name layer.conf`" >> layerlist.txt' >> $add_external_layers_script
        echo '' >> $add_external_layers_script
        echo '    layer_list=`cat layerlist.txt`' >> $add_external_layers_script
        echo '    : > layerlist.txt' >> $add_external_layers_script
        echo '    for layer in $layer_list ; do' >> $add_external_layers_script
        echo '        if [[ "`grep BBFILE_COLLECTIONS $layer`"  == *"qti-"* ]]; then' >> $add_external_layers_script
        echo '             echo $layer' >> $add_external_layers_script
        echo '        fi' >> $add_external_layers_script
        echo '    done >> layerlist.txt' >> $add_external_layers_script
        echo '' >> $add_external_layers_script
        echo "    sed -i 's+conf/layer.conf+ +g' layerlist.txt" >> $add_external_layers_script
        echo '    layer_list=`cat layerlist.txt`' >> $add_external_layers_script
        echo '    : > layerlist.txt' >> $add_external_layers_script
        echo '' >> $add_external_layers_script
        echo '    for layer in ${layer_list}' >> $add_external_layers_script
        echo '    do' >> $add_external_layers_script
        echo '         layer=${layer::${#layer}-1}' >> $add_external_layers_script
        echo '         layer=${layer:2}' >> $add_external_layers_script
        echo '         echo "$layer" >> layerlist.txt' >> $add_external_layers_script
        echo '    done' >> $add_external_layers_script
        echo '' >> $add_external_layers_script
        echo '    layer_list=`cat layerlist.txt`' >> $add_external_layers_script
        echo '' >> $add_external_layers_script
        echo '    for layer in ${layer_list}' >> $add_external_layers_script
        echo '    do' >> $add_external_layers_script
        echo '        grep -v "${layer} " ${SDK_ROOT}/conf/bblayers.conf > ${SDK_ROOT}/conf/tmp-bblayers.conf' >> $add_external_layers_script
        echo '        mv ${SDK_ROOT}/conf/tmp-bblayers.conf ${SDK_ROOT}/conf/bblayers.conf' >> $add_external_layers_script
        echo '    done' >> $add_external_layers_script
        echo '' >> $add_external_layers_script
        echo '    echo "BBLAYERS += \" \ " >> ${SDK_ROOT}/conf/bblayers.conf' >> $add_external_layers_script
        echo '    for layer in ${layer_list}' >> $add_external_layers_script
        echo '    do' >> $add_external_layers_script
        echo '        if [ -r ${workspace_root}/poky/${layer}/conf/layer.conf ] ;' >> $add_external_layers_script
        echo '        then' >> $add_external_layers_script
        echo '            echo "    ${workspace_root}/poky/${layer} \ " >> ${SDK_ROOT}/conf/bblayers.conf' >> $add_external_layers_script
        echo '            echo "`tput setaf 2`${workspace_root}/poky/${layer} has been added as a layer to the eSDK`tput sgr0`"' >> $add_external_layers_script
        echo '        else' >> $add_external_layers_script
        echo '            echo "`tput setaf 3`Unable to read ${workspace_root}/poky/${layer}/conf/layer.conf`tput sgr0`"' >> $add_external_layers_script
        echo '        fi' >> $add_external_layers_script
        echo '    done' >> $add_external_layers_script
        echo '    echo "    \"" >> ${SDK_ROOT}/conf/bblayers.conf' >> $add_external_layers_script
        echo '' >> $add_external_layers_script
        echo '    echo "Copying directories under ${workspace_root}/src to ${SDK_ROOT}/src"' >> $add_external_layers_script
        echo '    cp -rf ${workspace_root}/src/* ${SDK_ROOT}/src' >> $add_external_layers_script
        echo '' >> $add_external_layers_script
        echo '    if [ "$modify_recipes" == "" ] ;' >> $add_external_layers_script
        echo '    then' >> $add_external_layers_script
        echo '        read -p "Would you wish to perform devtool modify operation for all the recipes in the newly addd layers?(y/N)": modify_recipes' >> $add_external_layers_script
        echo '    fi' >> $add_external_layers_script
        echo '' >> $add_external_layers_script
        echo '    if [ "$modify_recipes" == "y" ] || [ "$modify_recipes" == "Y" ] ;' >> $add_external_layers_script
        echo '    then' >> $add_external_layers_script
        echo '        cd ${workspace_root}/poky' >> $add_external_layers_script
        echo '        rm -rf recipelist.txt' >> $add_external_layers_script
        echo '        touch recipelist.txt' >> $add_external_layers_script
	echo '        for layer in ${layer_list}' >> $add_external_layers_script
	echo '        do' >> $add_external_layers_script
        echo '        echo "`find ${workspace_root}/poky/${layer} -name *.bb`" >> recipelist.txt' >> $add_external_layers_script
        echo '        echo "`find ${workspace_root}/poky/${layer} -name *.bbappend`" >> recipelist.txt' >> $add_external_layers_script
        echo '        done' >> $add_external_layers_script
        echo '        grep -v "recipes-kernel" recipelist.txt > tmp-recipelist.txt' >> $add_external_layers_script
        echo '        mv tmp-recipelist.txt recipelist.txt' >> $add_external_layers_script
        echo '        recipe_list=`cat recipelist.txt`' >> $add_external_layers_script
        echo '        : > recipelist.txt' >> $add_external_layers_script
        echo '        for recipe in ${recipe_list}' >> $add_external_layers_script
        echo '        do' >> $add_external_layers_script
        echo '            recipe=`rev<<<"$recipe"`' >> $add_external_layers_script
        echo '            IFS="/" read -ra recipe_split <<< "${recipe}"' >> $add_external_layers_script
        echo '            recipe=${recipe_split[0]}' >> $add_external_layers_script
        echo '            recipe=`rev<<<"$recipe"`' >> $add_external_layers_script
        echo '            IFS="." read -ra recipe_split <<< "${recipe}"' >> $add_external_layers_script
        echo '            recipe=${recipe_split[0]}' >> $add_external_layers_script
        echo '            IFS="_" read -ra recipe_split <<< "${recipe}"' >> $add_external_layers_script
        echo '            recipe=${recipe_split[0]}' >> $add_external_layers_script
        echo '            echo "$recipe" >> recipelist.txt' >> $add_external_layers_script
        echo '        done' >> $add_external_layers_script
        echo '' >> $add_external_layers_script
        echo '        unsupported_recipe_types="image packagegroup"' >> $add_external_layers_script
        echo '' >> $add_external_layers_script
        echo '        for var in ${unsupported_recipe_types}' >> $add_external_layers_script
        echo '        do' >> $add_external_layers_script
        echo '            grep -v "${var}" recipelist.txt > tmp-recipelist.txt' >> $add_external_layers_script
        echo '            mv tmp-recipelist.txt recipelist.txt' >> $add_external_layers_script
        echo '        done' >> $add_external_layers_script
        echo '' >> $add_external_layers_script
        echo '        recipe_list=`cat recipelist.txt`' >> $add_external_layers_script
        echo '        for recipe in ${recipe_list}' >> $add_external_layers_script
        echo '        do' >> $add_external_layers_script
        echo '            echo "devtool modify $recipe"' >> $add_external_layers_script
        echo '            devtool modify $recipe' >> $add_external_layers_script
        echo '        done' >> $add_external_layers_script
        echo '        rm recipelist.txt' >> $add_external_layers_script
        echo '    else' >> $add_external_layers_script
        echo '        tput setaf 3' >> $add_external_layers_script
        echo '        echo "\"devtool modify\" operation was not performed on any recipe in the newly added layers"' >> $add_external_layers_script
        echo '        echo "If the developer wishes to edit or build a recipe from the newly added layers using devtool utility,"' >> $add_external_layers_script
        echo '        echo "\"devtool modify\" operation will have to be manually performed on that recipe."' >> $add_external_layers_script
        echo '        tput sgr0' >> $add_external_layers_script
        echo '    fi' >> $add_external_layers_script
        echo 'rm layerlist.txt' >> $add_external_layers_script
        echo 'cd ${current_working_dir}' >> $add_external_layers_script
        echo 'else' >> $add_external_layers_script
        echo '    echo "`tput setaf 1`${workspace_root} is not a workspace`tput sgr0`"' >> $add_external_layers_script
        echo 'fi' >> $add_external_layers_script
}
