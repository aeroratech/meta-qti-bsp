DEPENDS += " linux-platform"

do_compile_kernelmodules () {
       :
}

addtask compile_kernelmodules after do_compile before do_install
