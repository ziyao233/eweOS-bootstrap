$W/stage1.acl.extract: $W/ACL.download
	tar xf $W/$(ACL_FILE) -C $W
	$(call done)

$W/stage1.acl: $W/stage1.acl.extract $W/stage1.c-runtime $W/stage1.attr
	cd $W/acl-$(ACL_V) && \
	$(call s1) CFLAGS="$(CFLAGS) -D_LARGEFILE64_SOURCE" \
	./configure --prefix=/usr \
		--build=$(CBUILDHOST)	\
		--host=$(CHOST)		\
		--libdir=/usr/lib	\
		--libexecdir=/usr/lib

	+ $(call s1) make -C $W/acl-$(ACL_V)
	+ $(call s1) make -C $W/acl-$(ACL_V) install DESTDIR="$O"

	rm $O/usr/lib/libacl.la

	$(call done)
