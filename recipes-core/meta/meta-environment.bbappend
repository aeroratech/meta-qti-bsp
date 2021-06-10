inherit sdk-kernel-devsrc-scripts

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}/../../../meta/:"

create_sdk_files_append () {
# This generates kernel-devsrc-setup script
	sdk_kernel_devsrc_script ${SDK_OUTPUT}/${SDKPATH}/kernel-devsrc-setup
}
