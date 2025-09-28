$W/stage1.make.extract: $W/MAKE.download
	tar xf $W/$(MAKE_FILE) -C $W
	$(call done)

$W/stage1.make: $W/stage1.make.extract $W/stage1.c-runtime
	cd $W/make-$(MAKE_V) && \
	$(call s1) ./configure --prefix=/usr \
		--build=$(CBUILDHOST)		\
		--host=$(CHOST)			\
		--disable-nls

	+ $(call s1) make -C $W/make-$(MAKE_V)
	+ $(call s1) make -C $W/make-$(MAKE_V) install DESTDIR="$O"

	$(call done)
