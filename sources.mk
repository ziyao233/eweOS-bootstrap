BASH_V		:= 5.2.37
BASH_FILE	:= bash-$(BASH_V).tar.gz
BUSYBOX_V	:= 1.37.0
BUSYBOX_FILE	:= busybox-$(BUSYBOX_V).tar.bz2
LINUX_V		:= 6.16.7
LINUX_FILE	:= linux-$(LINUX_V).tar.xz
LLVM_V		:= 20.1.8
LLVM_FILE	:= llvmorg-$(LLVM_V).tar.gz
MAKE_V		:= 4.4.1
MAKE_FILE	:= make-$(MAKE_V).tar.gz
MUSL_V		:= 1.2.5
MUSL_FILE	:= musl-$(MUSL_V).tar.gz
NCURSES_V	:= 6.5
NCURSES_FILE	:= ncurses-$(NCURSES_V).tar.gz
PKGCONF_V	:= 2.5.1
PKGCONF_FILE	:= pkgconf-$(PKGCONF_V).tar.gz
READLINE_V	:= 8.3
READLINE_FILE	:= readline-$(READLINE_V).tar.gz
UCONTEXT_V	:= 1.3.2
UCONTEXT_FILE	:= libucontext-$(UCONTEXT_V).tar.xz
ZLIB_NG_V	:= 2.2.5
ZLIB_NG_FILE	:= zlib-ng-$(ZLIB_NG_V).tar.gz

BASH_URL	:= http://ftpmirror.gnu.org/gnu/bash/$(BASH_FILE)
BUSYBOX_URL	:= https://www.busybox.net/downloads/$(BUSYBOX_FILE)
LINUX_URL	:= https://cdn.kernel.org/pub/linux/kernel/v6.x/$(LINUX_FILE)
LLVM_URL	:= https://github.com/llvm/llvm-project/archive/refs/tags/$(LLVM_FILE)
MAKE_URL	:= http://ftpmirror.gnu.org/gnu/make/$(MAKE_FILE)
MUSL_URL	:= http://www.etalabs.net/musl/releases/$(MUSL_FILE)
NCURSES_URL	:= http://ftpmirror.gnu.org/gnu/ncurses/$(NCURSES_FILE)
PKGCONF_URL	:= https://github.com/pkgconf/pkgconf/archive/refs/tags/$(PKGCONF_FILE)
READLINE_URL	:= http://ftpmirror.gnu.org/gnu/readline/$(READLINE_FILE)
UCONTEXT_URL	:= https://distfiles.dereferenced.org/libucontext/$(UCONTEXT_FILE)
ZLIB_NG_URL	:= https://github.com/zlib-ng/zlib-ng/archive/refs/tags/$(ZLIB_NG_V).tar.gz

$W/%.download:
	curl -L $($(*F)_URL) -o $W/$($(*F)_FILE)
	$(call done)
