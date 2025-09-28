LINUXARCH_x86_64	:= x86_64
LINUXARCH_aarch64	:= aarch64
LINUXARCH_riscv64	:= riscv
LINUXARCH_loongarch64	:= loongarch

LINUXARCH := $(LINUXARCH_$(CARCH))

$W/stage1.linux-uapi-headers.extract: $W/stage0 $W/LINUX.download
	tar xf $W/$(LINUX_FILE) -C $W

	$(call done)

$W/stage1.linux-uapi-headers: \
	$W/stage1.linux-uapi-headers.extract $W/stage1.c-runtime
	$(call s1) make -C $W/linux-$(LINUX_V) headers_install \
		LLVM=1 LLVM_IAS=1 ARCH=$(LINUXARCH)		\
		INSTALL_HDR_PATH=$O/usr

	$(call done)
