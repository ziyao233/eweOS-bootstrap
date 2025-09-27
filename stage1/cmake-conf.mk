CMAKE_PROCESSOR_x86_64		:= x86_64
CMAKE_PROCESSOR_arm64		:= aarch64
CMAKE_PROCESSOR_riscv64		:= riscv64
CMAKE_PROCESSOR_loongarch64	:= loongarch64
CMAKE_PROCESSOR			:= $(CMAKE_PROCESSOR_$(CARCH))

$W/cmake-conf.cmake:
	sed -e "s/%CHOST%/$(CHOST)/" $(SRCDIR)/stage1/cmake-conf.cmake \
		> $W/cmake-conf.cmake
