MUSL_V		:= 1.2.5
MUSL_FILE	:= musl-$(MUSL_V).tar.gz
LLVM_V		:= 20.1.8
LLVM_FILE	:= llvmorg-$(LLVM_V).tar.gz

MUSL_URL	:= http://www.etalabs.net/musl/releases/$(MUSL_FILE)
LLVM_URL	:= https://github.com/llvm/llvm-project/archive/refs/tags/$(LLVM_FILE)

$W/%.download:
	curl -L $($(*F)_URL) -o $W/$($(*F)_FILE)
	$(call done)
