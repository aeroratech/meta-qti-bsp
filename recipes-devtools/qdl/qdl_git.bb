# This file is derived from
# https://git.yoctoproject.org/cgit/cgit.cgi/meta-qcom/tree/recipes-devtools/qdl/qdl_git.bb?id=14164d9
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

SUMMARY = "QDL flasing tool"
HOMEPAGE = "https://github.com/abozhinov444/qdl.git"
SECTION = "devel"

LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://qdl.c;beginline=1;endline=31;md5=1c7d712d897368d3d3c161e5493efc6a"

DEPENDS = "libxml2"
DEPENDS_append_class-target = " udev "

inherit pkgconfig

SRCREV = "22234e6af33af1848e36d4d4bc63264087b97892"
SRC_URI = "git://github.com/abozhinov444/${BPN}.git;branch=sparse_image_format;protocol=https \
           file://0001-Makefile-Use-pkg-config-for-libxml2-detection.patch \
"

PV = "0.0+${SRCPV}"

S = "${WORKDIR}/git"

do_install () {
    oe_runmake install DESTDIR=${D} prefix=${prefix}
}

BBCLASSEXTEND = "native nativesdk"
