$W/stage1.libarchive.extract: $W/LIBARCHIVE.download
	tar xf $W/$(LIBARCHIVE_FILE) -C $W
	$(call done)

$W/stage1.libarchive: $W/stage1.libarchive.extract \
	$W/stage1.c-runtime $W/stage1.zlib-ng $W/stage1.xz $W/stage1.openssl \
	$W/stage1.zstd $W/stage1.acl

	cd $W/libarchive-$(LIBARCHIVE_V) && \
	$(call s1) ./configure --prefix=/usr \
		--build=$(CBUILDHOST)		\
		--host=$(CHOST)			\
		--without-xml2			\
		--without-lz4			\
		--without-bz2lib		\
		--without-expat			\
		--with-sysroot=$O

	+ $(call s1) make -C $W/libarchive-$(LIBARCHIVE_V)
	+ $(call s1) make -C $W/libarchive-$(LIBARCHIVE_V) install DESTDIR="$O"

	ln -s bsdtar "$O"/usr/bin/tar
	rm "$O"/usr/lib/libarchive.la

	$(call done)
