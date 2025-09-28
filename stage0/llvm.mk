LLVMTARGET_x86_64	:= X86
LLVMTARGET_aarch64	:= AArch64
LLVMTARGET_riscv64	:= RISCV
LLVMTARGET_loongarch64	:= LoongArch
LLVMTARGET := $(LLVMTARGET_$(CARCH))

$W/stage0.llvm.extract: $W/LLVM.download
	tar xf $W/$(LLVM_FILE) -C $W
	$(call done)

$W/stage0.llvm: $W/stage0.llvm.extract
	cmake -S $W/llvm-project-llvmorg-$(LLVM_V)/llvm \
		-B $W/llvm-build -G Ninja			\
		-DCMAKE_BUILD_TYPE=Release			\
		-DCMAKE_INSTALL_PREFIX=/opt			\
		-DCMAKE_INSTALL_LIBEXECDIR=bin			\
		-DCMAKE_CXX_FLAGS='-D_LARGEFILE64_SOURCE'	\
		-DLLVM_DEFAULT_TARGET_TRIPLE=$(CHOST)		\
		-DLLVM_HOST_TRIPLE=$(CHOST)			\
		-DCLANG_DEFAULT_CXX_STDLIB='libc++'		\
		-DCLANG_DEFAULT_RTLIB='compiler-rt'		\
		-DCLANG_DEFAULT_LINKER='lld'			\
		-DLLVM_INSTALL_UTILS=ON				\
		-DLLVM_ENABLE_LIBCXX=ON				\
		-DLLVM_ENABLE_RTTI=ON				\
		-DLLVM_INSTALL_BINUTILS_SYMLINKS=ON		\
		-DLLVM_BUILD_LLVM_DYLIB=ON			\
		-DLLVM_LINK_LLVM_DYLIB=ON			\
		-DLLVM_INCLUDE_BENCHMARKS=OFF			\
		-DLLVM_TARGETS_TO_BUILD=$(LLVMTARGET)		\
		-DLLVM_ENABLE_PER_TARGET_RUNTIME_DIR=OFF	\
		-DLLVM_ENABLE_PROJECTS="clang;lld"		\
		-DDEFAULT_SYSROOT=$O

	+ cmake --build $W/llvm-build
	DESTDIR="$W" cmake --install $W/llvm-build

	$(call done)
