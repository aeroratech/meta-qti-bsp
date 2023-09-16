# Get signing files from Prebuilts
KERNEL_PREBUILT_SCRIPTS_PATH = "${KERNEL_OUT_PATH}/msm-kernel"
KERNEL_BUILD_TOOLS_PATH = "${KERNEL_OUT_PATH}/../../kernel_platform/prebuilts/kernel-build-tools/linux-x86/lib64/"
MODULE_SIGN_FILE = "${KERNEL_PREBUILT_SCRIPTS_PATH}/scripts/sign-file"
MODULE_SIGNING_KEY_PEM = "${KERNEL_PREBUILT_SCRIPTS_PATH}/certs/signing_key.pem"
MODULE_SIGNING_KEY_X509 = "${KERNEL_PREBUILT_SCRIPTS_PATH}/certs/signing_key.x509"

# strip debug symbols and sign tech-pack module
# Input - module path to sign
sign_strip_module() {
    module_path="$1"

    #strip debug symbols
    ${STRIP}  --strip-debug ${module_path}

    #sign module
    LD_LIBRARY_PATH=${KERNEL_BUILD_TOOLS_PATH} ${MODULE_SIGN_FILE} sha1 ${MODULE_SIGNING_KEY_PEM} ${MODULE_SIGNING_KEY_X509} ${module_path}
}

do_strip_and_sign_dlkm() {
    module_path="$1"
    enable_debug_symbols="${2:-false}"

    if [ $enable_debug_symbols == "false" ]; then
        #strip debug symbols
       ${STRIP}  --strip-debug ${module_path}
    fi
    #sign module
    LD_LIBRARY_PATH=${KERNEL_BUILD_TOOLS_PATH} ${MODULE_SIGN_FILE} sha1 ${MODULE_SIGNING_KEY_PEM} ${MODULE_SIGNING_KEY_X509} ${module_path}
}
