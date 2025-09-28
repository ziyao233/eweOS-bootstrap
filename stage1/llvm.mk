LLVMTARGET_x86_64	:= X86
LLVMTARGET_aarch64	:= AArch64
LLVMTARGET_riscv64	:= RISCV
LLVMTARGET_loongarch64	:= LoongArch
LLVMTARGET := $(LLVMTARGET_$(CARCH))

$W/stage1.binutils.extract: $W/BINUTILS.download
	tar xf $W/$(BINUTILS_FILE) -C $W
	$(call done)

$W/stage1.llvm: $W/stage1.llvm.extract $W/stage1.binutils.extract \
	$W/stage1.cxx-runtime
	$(call s1) cmake -S $W/llvm-project-llvmorg-$(LLVM_V)/llvm \
		-B $W/llvm-stage1-build -G Ninja		\
		-DCMAKE_BUILD_TYPE=Release			\
		-DCMAKE_INSTALL_PREFIX=/usr			\
		-DCMAKE_INSTALL_LIBEXECDIR=bin			\
		-DCMAKE_CXX_FLAGS='-D_LARGEFILE64_SOURCE'	\
		-DCMAKE_TOOLCHAIN_FILE=$(AW)/cmake-conf.cmake	\
		-DLLVM_DEFAULT_TARGET_TRIPLE=$(CHOST)		\
		-DLLVM_HOST_TRIPLE=$(CHOST)			\
		-DCLANG_DEFAULT_CXX_STDLIB='libc++'		\
		-DCLANG_DEFAULT_RTLIB='compiler-rt'		\
		-DCLANG_DEFAULT_LINKER='lld'			\
		-DCLANG_CONFIG_FILE_SYSTEM_DIR=/etc/clang	\
		-DLLVM_INSTALL_UTILS=ON				\
		-DLLVM_ENABLE_LIBCXX=ON				\
		-DLLVM_ENABLE_RTTI=ON				\
		-DLLVM_ENABLE_LIBXML2=OFF			\
		-DLLVM_INSTALL_BINUTILS_SYMLINKS=ON		\
		-DLLVM_BUILD_LLVM_DYLIB=ON			\
		-DLLVM_LINK_LLVM_DYLIB=ON			\
		-DLLVM_INCLUDE_BENCHMARKS=OFF			\
		-DLLVM_TARGETS_TO_BUILD=$(LLVMTARGET)		\
		-DLLVM_ENABLE_PER_TARGET_RUNTIME_DIR=OFF	\
		-DLLVM_ENABLE_PROJECTS="clang;lld"		\
		-DLLVM_BINUTILS_INCDIR="$(AW)/binutils-$(BINUTILS_V)/include"

	+ $(call s1) cmake --build $W/llvm-stage1-build
	+ $(call s1) DESTDIR="$O" cmake --install $W/llvm-stage1-build

	$(call done)
