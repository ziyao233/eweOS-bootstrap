$W/stage1.xz.extract: $W/XZ.download
	tar xf $W/$(XZ_FILE) -C $W
	$(call done)

$W/stage1.xz: $W/stage1.xz.extract $W/stage1.c-runtime
	cd $W/xz-$(XZ_V)/ && \
	$(call s1) ./configure --prefix=/usr \
		--build=$(CBUILDHOST)		\
		--host=$(CHOST)

	+ $(call s1) make -C $W/xz-$(XZ_V)
	+ $(call s1) make -C $W/xz-$(XZ_V) install DESTDIR="$O"

	$(call done)
