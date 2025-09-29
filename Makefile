W := build
AW := $(shell realpath $W)
O := $(AW)/../output
SRCDIR := $(PWD)

S0DIR := $(shell realpath $W)/opt
S0BIN := $(S0DIR)/bin

UNAMEARCH :=$(shell uname -m)

CARCH_x86_64		:= x86_64
CARCH_aarch64		:= aarch64
CARCH_riscv64		:= riscv64
CARCH_loongarch64	:= loongarch64

CBUILDARCH := $(CARCH_$(UNAMEARCH))
CBUILDHOST := $(CBUILDARCH)-ewe-linux-musl

CARCH := $(CBUILDARCH)
CHOST := $(CBUILDHOST)

include sources.mk

S1CFLAGS	:= -Os -pipe
S1LDFLAGS	:=

S1PREDEFINED	:= CFLAGS="$(S1CFLAGS)"
S1PREDEFINED	:= LDFLAGS="$(S1LDFLAGS)"
S1PREDEFINED	+= CC=clang CXX=clang++

done = touch $@
s1 = env PATH=$(S0BIN):$(PATH) $(S1PREDEFINED)

include stage0/*.mk
$W/stage0: $W/stage0.llvm
	$(call done)

include stage1/*.mk

ifeq ($(shell if test -d $O -a -d $W; then echo okay; fi),)
$(error Please create $O and $W)
endif
