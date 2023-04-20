#Copyright (c) 2023 Qualcomm Innovation Center, Inc. All rights reserved.
#SPDX-License-Identifier: BSD-3-Clause-Clear
CPIODIR = "${WORKDIR}/extracpio"
CMDLINE_FILE = "verity.cmdline"
VERITY_CMDLINE = "${WORKDIR}/verity-cmdline"
NOVERITY_INIT = "${COREBASE}/meta-qti-bsp/recipes-products/images/include/noverity-init"
VERITY_INIT = "${COREBASE}/meta-qti-bsp/recipes-products/images/include/verity-init"

do_ramdisk_create[depends] += "virtual/kernel:do_deploy"
do_ramdisk_create[cleandirs] += "${CPIODIR}"
do_extracpio_create() {
	mkdir -p ${CPIODIR}
	if ${@bb.utils.contains('DISTRO_FEATURES', 'dm-verity', bb.utils.contains('MACHINE_FEATURES', 'dm-verity-cpio-cmdline', 'true', 'false', d), 'false', d)}; then
		cat ${VERITY_INIT} ${VERITY_CMDLINE} > ${CPIODIR}/${CMDLINE_FILE}
	else
		cat ${NOVERITY_INIT} > ${CPIODIR}/${CMDLINE_FILE}
	fi
	cd ${CPIODIR} && ls ${CMDLINE_FILE} | cpio -ov --format=newc -F ${IMGDEPLOYDIR}/${PN}-cmdline.cpio
}

addtask do_extracpio_create after do_makesystem before do_makeboot
