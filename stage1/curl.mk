$W/stage1.curl.extract: $W/CURL.download
	tar xf $W/$(CURL_FILE) -C $W
	$(call done)

$W/stage1.ca-certs: $W/stage1.curl.extract
	cd $W/curl-$(CURL_V) && ./scripts/mk-ca-bundle.pl

	install -d "$O"/etc/ssl/certs
	install -Dm644 $W/curl-$(CURL_V)/ca-bundle.crt \
		"$O"/etc/ssl/certs/ca-certificates.crt

	ln -s certs/ca-certificates.crt "$O"/etc/ssl/cert.pem
	ln -s certs/ca-certificates.crt "$O"/etc/ssl/ca-certs.pem

	$(call done)

$W/stage1.curl: $W/stage1.curl.extract \
	$W/stage1.c-runtime $W/stage1.zlib-ng $W/stage1.zstd $W/stage1.openssl

	# cURL must be built out-of-tree
	mkdir -p $W/build-curl

	cd $W/build-curl && \
	$(call s1) $(AW)/curl-$(CURL_V)/configure --prefix=/usr \
		--build=$(CBUILDHOST)		\
		--host=$(CHOST)			\
		--with-ssl			\
		--enable-ipv6			\
		--enable-threaded-resolver	\
		--without-libpsl		\
		--without-nghttp2		\
		--without-libidn2		\
		--with-ca-bundle=/etc/ssl/certs/ca-certificates.crt

	+ $(call s1) make -C $W/build-curl
	+ $(call s1) make -C $W/build-curl install DESTDIR="$O"

	$(call done)
