inherit core-image

#CORE_IMAGE_EXTRA_INSTALL += "csmhost"

RM_WORK_EXCLUDE += "${PN}"

CSMHOST_SW_TZ?= "${IMGDEPLOYDIR}/${IMAGE_BASENAME}/csmhost.tar.gz"
CSMHOST_SW?= "${DEPLOY_DIR_IMAGE}/csmhost"
CSMHOST_SW_BIN?= "${DEPLOY_DIR_IMAGE}/csm-host-bin"

do_makecsmhostsw_tz[dirs] = "${IMGDEPLOYDIR}/${IMAGE_BASENAME}"

do_makecsmhostsw_tz() {
     if [ -d ${CSMHOST_SW} ]; then
         tar -czvf ${CSMHOST_SW_TZ} ${CSMHOST_SW}
     fi
     if [ -d ${CSMHOST_SW_BIN} ]; then
         tar -czvf ${CSMHOST_SW_TZ} ${CSMHOST_SW_BIN}
     fi
}

addtask do_makecsmhostsw_tz after do_rootfs before do_image
