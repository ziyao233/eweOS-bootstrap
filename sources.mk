MUSL_V		:= 1.2.5
MUSL_FILE	:= musl-$(MUSL_V).tar.gz
LINUX_V		:= 6.16.7
LINUX_FILE	:= linux-$(LINUX_V).tar.xz
LLVM_V		:= 20.1.8
LLVM_FILE	:= llvmorg-$(LLVM_V).tar.gz

MUSL_URL	:= http://www.etalabs.net/musl/releases/$(MUSL_FILE)
LINUX_URL	:= https://cdn.kernel.org/pub/linux/kernel/v6.x/$(LINUX_FILE)
LLVM_URL	:= https://github.com/llvm/llvm-project/archive/refs/tags/$(LLVM_FILE)

$W/%.download:
	curl -L $($(*F)_URL) -o $W/$($(*F)_FILE)
	$(call done)
