# strip debug symbols and sign the module
sign_strip_module() {
    module_path="$1"

    ${STAGING_DIR_NATIVE}/usr/libexec/aarch64-oe-linux/gcc/aarch64-oe-linux/9.3.0/strip \
           --strip-debug ${module_path}

    LD_LIBRARY_PATH=${WORKSPACE}/kernel-${PREFERRED_VERSION_linux-msm}/kernel_platform/prebuilts/kernel-build-tools/linux-x86/lib64/ \
    ${STAGING_KERNEL_BUILDDIR}/scripts/sign-file sha1 ${STAGING_KERNEL_BUILDDIR}/certs/signing_key.pem \
          ${STAGING_KERNEL_BUILDDIR}/certs/signing_key.x509 ${module_path}
}