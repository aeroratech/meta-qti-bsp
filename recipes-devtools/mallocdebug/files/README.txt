
libmallocdebug tools has 2 stages:

Stage1: (collecting alloc debug data on the device)
	Generate post processed log & collect map file
	Preload mallocdebug before running the binary that you want to track for allocations
        export MALLOCBT=Y
        export LD_PRELOAD=/usr/lib/libmallocdebug.so
	to generate log file :
	./<binary to be analysed> 2>/data/preload.log
	to collect map file :
	cat /proc/<PID of process to be analysed>/maps  > /data/maps.log

Stage2:
      genarate detail stack of the data collected in Step 1 above,
      env setup
      =========
      1. ensure to have proper build environment and same local build should be flashed on device.
      2. by default offline python tools will be present in below folder in local build environment.
         /tmp-glibc/sysroots-components/x86_64/mallocdebug-native/usr/bin/scripts/alloc-backtrace-parser.py & alloc-filter-mismatch
      3. aarch64-oe-linux-addr2line tool is available at tmp-glibc/sysroots-components/x86_64/binutils-cross-aarch64/usr/bin/aarch64-oe-linux/
         aarch64-oe-linux-addr2line.

     Commands to generate post processed logs
     ========================================
	1. python3 alloc-backtrace-parser.py --mode target-aarch64 --log-file <from step 1> --proc-map <map file from step one> --addr2line < path of aarch64-oe-linux-addr2line>  --dbgrootfs < path  of debug rotfs> (debug rootfs will be present at path ../build-qti-distro-xr-debug/tmp-glibc/work/sxrneo-oe-linux/qti-xreality2-image/1.0-r0/rootfs-dbg in local build env).
	2. python3 alloc-filter-mismatch.py  --log-file <outputfrom step #1>


build instructions:

by default mallocdebug build is not enabled, follow below steps for build:
1. setup the env
2. bitbake mallocdebug.
3. bitbake mallocdebug-native.
4. push generated ipk form path tmp-glibc\deploy\ipk\sxrneo\mallocdebug_1.0-r0_sxrneo.ipk to device /data folder.
5. install ipk "opkg install –-nodeps <ipk name>"