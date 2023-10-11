inherit ${@bb.utils.contains('TARGET_KERNEL_ARCH', 'aarch64', 'qtikernel-arch', '', d)}

KERNEL_USE_PREBUILTS = "${@d.getVar('MACHINE_USES_KERNEL_PREBUILTS') or "False"}"

do_configure[depends] += "${@oe.utils.conditional('KERNEL_USE_PREBUILTS', 'True', bb.utils.contains('PREFERRED_PROVIDER_virtual/kernel', 'linux-msm', 'virtual/kernel:do_prebuilt_shared_workdir', '', d), '',d)}"
