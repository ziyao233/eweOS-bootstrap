W := build
OUTPUTDIR := output
UNAMEARCH :=$(shell uname -m)

CARCH_x86_64		:= x86_64
CARCH_aarch64		:= aarch64
CARCH_riscv64		:= riscv64
CARCH_loongarch64	:= loongarch64

CBUILDARCH := $(CARCH_$(UNAMEARCH))
CBUILDHOST := $(CBUILDARCH)-unknown-linux-musl

CARCH := $(CBUILDARCH)
CHOST := $(CBUILDHOST)

include sources.mk

done = touch $@

include stage0/*.mk
