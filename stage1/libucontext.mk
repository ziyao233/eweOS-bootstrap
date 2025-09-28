$W/stage1.libucontext.extract: $W/UCONTEXT.download
	tar xf $W/$(UCONTEXT_FILE) -C $W
	$(call done)

$W/stage1.libucontext: $W/stage1.libucontext.extract $W/stage1.c-runtime
	+ $(call s1) make -C $W/libucontext-$(UCONTEXT_V) ARCH=$(CARCH)
	+ $(call s1) make -C $W/libucontext-$(UCONTEXT_V) ARCH=$(CARCH) \
		install DESTDIR="$O"

	$(call done)
