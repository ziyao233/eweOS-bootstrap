$W/stage1.attr.extract: $W/ATTR.download
	tar xf $W/$(ATTR_FILE) -C $W
	$(call done)

$W/stage1.attr.patch: $W/stage1.attr.extract
	sed -i '1i #include<libgen.h>' $W/attr-$(ATTR_V)/tools/attr.c
	$(call done)

$W/stage1.attr: $W/stage1.attr.patch $W/stage1.c-runtime
	cd $W/attr-$(ATTR_V) && \
	$(call s1) ./configure --prefix=/usr \
		--build=$(CBUILDHOST)		\
		--host=$(CHOST)			\
		--libdir=/usr/lib		\
		--libexecdir=/usr/lib		\
		--sysconfdir=/etc

	+ $(call s1) make -C $W/attr-$(ATTR_V)
	+ $(call s1) make -C $W/attr-$(ATTR_V) install DESTDIR="$O"

	rm $O/usr/lib/libattr.la

	$(call done)
