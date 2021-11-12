inherit ext-sdk-add-layer

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}/../../../meta/:"

create_sdk_files_append() {
# This generates a script to add custom bitbake layers to an extensible SDK.
        ext_sdk_add_layer_script ${SDK_OUTPUT}/${SDKPATH}/add_bitbake_layer
}
