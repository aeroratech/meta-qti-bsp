# Copyright (c) 2022 Qualcomm Innovation Center, Inc. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted (subject to the limitations in the
# disclaimer below) provided that the following conditions are met:
#
#    * Redistributions of source code must retain the above copyright
#      notice, this list of conditions and the following disclaimer.
#
#    * Redistributions in binary form must reproduce the above
#      copyright notice, this list of conditions and the following
#      disclaimer in the documentation and/or other materials provided
#       with the distribution.
#
#    * Neither the name of Qualcomm Innovation Center, Inc. nor the names of its
#      contributors may be used to endorse or promote products derived
#           from this software without specific prior written permission.
#
# NO EXPRESS OR IMPLIED LICENSES TO ANY PARTY'S PATENT RIGHTS ARE
# GRANTED BY THIS LICENSE. THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT
# HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
# GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
# IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
# IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

## Generate dtbo.img
MKDTUTIL = '${@oe.utils.conditional("PREFERRED_PROVIDER_virtual/mkdtimg-native", "mkdtimg-gki-native", "mkdtboimg/bin/mkdtboimg.py", "mkdtimg", d)}'
DTBODEPLOYDIR = "${WORKDIR}/deploy-${PN}-dtboimage-complete"

# Create dtbo.img if DTBO support is enabled
python do_makedtbo () {
    import subprocess

    mkdtimg_bin_path = d.getVar('STAGING_BINDIR_NATIVE', True) + "/" + d.getVar('MKDTUTIL')
    dtbodeploydir = d.getVar('DEPLOY_DIR_IMAGE', True) + "/" + "DTOverlays"
    pagesize = d.getVar("PAGE_SIZE")
    output          = d.getVar('DTBOIMAGE_TARGET', True)
    # cmd to make dtbo.img
    cmd = mkdtimg_bin_path + " create "+ output +" --page_size="+ pagesize +" "+ dtbodeploydir + "/*.dtbo"
    bb.debug(1, "do_makedtbo cmd: %s" % (cmd))
    try:
        ret = subprocess.check_output(cmd, shell=True)
    except RuntimeError as e:
        bb.error("cmd: %s failed with error %s" % (cmd, str(e)))
}
addtask do_makedtbo after do_rootfs before do_image

do_makedtbo[dirs]      = "${DTBODEPLOYDIR}/${IMAGE_BASENAME}"
# Make sure dtb files ready to create dtbo.img
do_makedtbo[depends] += "virtual/kernel:do_deploy virtual/mkdtimg-native:do_populate_sysroot"
SSTATETASKS += "do_makedtbo"
SSTATE_SKIP_CREATION_task-makedtbo = '1'
do_makedtbo[sstate-inputdirs] = "${DTBODEPLOYDIR}"
do_makedtbo[sstate-outputdirs] = "${DEPLOY_DIR_IMAGE}"
do_makedtbo[stamp-extra-info] = "${MACHINE_ARCH}"

python do_makedtbo_setscene () {
    sstate_setscene(d)
}
