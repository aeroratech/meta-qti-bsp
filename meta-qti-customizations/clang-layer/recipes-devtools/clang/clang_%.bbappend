TOOLCHAIN = "gcc"
LLVM_TARGETS_TO_BUILD = "ARM;AArch64"
LLVM_TARGETS_TO_BUILD_TARGET = "ARM;AArch64"
LLVM_EXPERIMENTAL_TARGETS_TO_BUILD = ""

EXTRA_OECMAKE += "-DLLVM_USE_LINKER=gold \
                  -DLLVM_PARALLEL_LINK_JOBS=1 \
                  -DLLVM_LINK_LLVM_DYLIB=true \
                  -DCMAKE_CXX_COMPILER=clang++ \
"
