$W/stage1.llvm.extract: $W/stage0.llvm.extract
	$(call done)

$W/stage1.compiler-rt: \
	$W/stage1.llvm.extract $W/cmake-conf.cmake $W/stage1.musl-headers

	$(call s1) cmake -S $W/llvm-project-llvmorg-$(LLVM_V)/compiler-rt/ \
		-B $W/compiler-rt-build -G Ninja		\
		-DTEST_COMPILE_ONLY=ON				\
		-DCMAKE_INSTALL_PREFIX=/usr			\
		-DCMAKE_TOOLCHAIN_FILE=$(AW)/cmake-conf.cmake	\
		-DCMAKE_TRY_COMPILE_TARGET_TYPE=STATIC_LIBRARY	\
		-DLLVM_CONFIG=$(S0BIN)/llvm-config		\
		-DDEFAULT_COMPILER_RT_USE_BUILTINS_LIBRARY=ON	\
		-DCOMPILER_RT_BUILD_GWP_ASAN=OFF		\
		-DCOMPILER_RT_BUILD_XRAY=OFF			\
		-DCOMPILER_RT_BUILD_SANITIZERS=OFF		\
		-DCOMPILER_RT_BUILD_MEMPROF=OFF			\
		-DCOMPILER_RT_BUILD_CTX_PROFILE=OFF		\
		-DCOMPILER_RT_BUILD_LIBFUZZER=OFF		\
		-DCOMPILER_RT_BUILD_ORC=OFF			\
		-DCOMPILER_RT_BUILD_BUILTINS=ON			\
		-DCOMPILER_RT_CRT_USE_EH_FRAME_REGISTRY=OFF	\
		-DCOMPILER_RT_STANDALONE_BUILD=ON		\
		-DCOMPILER_RT_DEFAULT_TARGET_TRIPLE="$(CHOST)"	\
		-DCOMPILER_RT_DEFAULT_TARGET_ONLY=OFF

	+ $(call s1) cmake --build $W/compiler-rt-build

	DESTDIR="$W/compiler-rt-install" cmake --install $W/compiler-rt-build

	mkdir -p $O/usr/lib/clang/20/lib
	cp -rf $W/compiler-rt-install/usr/lib/linux \
		$O/usr/lib/clang/20/lib

	# This is a trick, we don't bother overriding Clang's resource-dir
	# when cross-compiling for target, so let's simply make a copy of
	# compiler-rt builtins.
	mkdir -p $(S0DIR)/lib/clang/20/lib
	cp -rf $W/compiler-rt-install/usr/lib/linux \
		$(S0DIR)/lib/clang/20/lib

	$(call done)
