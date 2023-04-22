MACHINE_FEATURES_append = " qti-vm-host qti-virtualization"

MACHINE_MNT_POINTS = " \
    /dsp \
    /firmware \
    /systemrw \
    /persist \
    /data \
    /cache \
    /vm-bootsys \
"
KERNEL_VARIANT_qti-distro-debug ??= "hostvm_debug_"
KERNEL_VARIANT_qti-distro-perf ??= "hostvm_perf_"

MACHINE_FEATURES_remove = "qti-wwan-plus-cv2x"
