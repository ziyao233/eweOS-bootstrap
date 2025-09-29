$W/stage1.hwloc.extract: $W/HWLOC.download
	tar xf $W/$(HWLOC_FILE) -C $W
	$(call done)

$W/stage1.hwloc.conf: $W/stage1.hwloc.extract
	cd $W/hwloc-$(HWLOC_V) && autoreconf -fiv
	$(call done)

$W/stage1.hwloc: $W/stage1.hwloc.conf $W/stage1.c-runtime

	cd $W/hwloc-$(HWLOC_V) && \
	$(call s1) ./configure --prefix=/usr \
		--build=$(CBUILDHOST)		\
		--host=$(CHOST)			\
		--sbindir=/usr/bin		\
		--sysconfdir=/etc		\
		--disable-plugins		\
		--disable-libudev
	+ $(call s1) make -C $W/hwloc-$(HWLOC_V)
	+ $(call s1) make -C $W/hwloc-$(HWLOC_V) install DESTDIR="$O"

	rm "$O"/usr/lib/libhwloc.la

	$(call done)
