$W/stage1.libxcrypt.extract: $W/XCRYPT.download
	tar xf $W/$(XCRYPT_FILE) -C $W
	$(call done)

$W/stage1.libxcrypt: $W/stage1.libxcrypt.extract \
	$W/stage1.c-runtime $W/stage1.libucontext $W/stage1.linux-uapi-headers
	cd $W/libxcrypt-$(XCRYPT_V) && \
	$(call s1) ./configure --prefix=/usr \
		--build=$(CBUILDHOST)		\
		--host=$(CHOST)			\
		--disable-static		\
		--enable-hashes=strong,glibc	\
		--enable-obsolete-api=no	\
		--disable-failure-tokens	\
		--disable-symvers		\
		LIBS='-lucontext_posix'

	+ $(call s1) make -C $W/libxcrypt-$(XCRYPT_V)
	+ $(call s1) make -C $W/libxcrypt-$(XCRYPT_V) install DESTDIR="$O"

	$(call done)
