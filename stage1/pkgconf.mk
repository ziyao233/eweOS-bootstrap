$W/stage1.pkgconf.extract: $W/PKGCONF.download
	tar xf $W/$(PKGCONF_FILE) -C $W
	$(call done)

$W/stage1.pkgconf: $W/stage1.pkgconf.extract $W/stage1.c-runtime
	cd $W/pkgconf-pkgconf-$(PKGCONF_V) && autoreconf -fiv

	cd $W/pkgconf-pkgconf-$(PKGCONF_V) && \
	$(call s1) ./configure --prefix=/usr \
		--build=$(CBUILDHOST)		\
		--host=$(CHOST)			\
		--with-system-libdir=/usr/lib	\
		--with-system-includedir=/usr/include

	+ $(call s1) make -C $W/pkgconf-pkgconf-$(PKGCONF_V)
	+ $(call s1) make -C $W/pkgconf-pkgconf-$(PKGCONF_V) install \
		DESTDIR="$O"

	ln -s pkgconf $O/usr/bin/pkg-config

	rm "$O"/usr/lib/libpkgconf.la

	$(call done)
