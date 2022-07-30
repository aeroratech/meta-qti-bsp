do_install_append() {
    if [ "${BASEMACHINE}" = "qrbx210" ]; then
      rm -rf $kerneldir/build/scripts/basic/fixdep
      rm -rf $kerneldir/build/scripts/kconfig/conf
      rm -rf $kerneldir/build/scripts/kconfig/*.o
    fi
}
