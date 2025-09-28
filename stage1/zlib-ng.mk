$W/stage1.zlib-ng.extract: $W/ZLIB_NG.download
	tar xf $W/$(ZLIB_NG_FILE) -C $W
	$(call done)

$W/stage1.zlib-ng: $W/stage1.zlib-ng.extract \
	 $W/stage1.c-runtime $W/cmake-conf.cmake

	$(call s1) cmake -S $W/zlib-ng-$(ZLIB_NG_V) \
		-B $W/zlib-ng-build				\
		-DCMAKE_BUILD_TYPE=Release			\
		-DCMAKE_INSTALL_PREFIX=/usr			\
		-DCMAKE_INSTALL_LIBDIR=lib			\
		-DCMAKE_TOOLCHAIN_FILE=$(AW)/cmake-conf.cmake	\
		-DWITH_GTEST=OFF				\
		-DWITH_RVV=OFF					\
		-DZLIB_COMPAT=ON

	+ $(call s1) cmake --build $W/zlib-ng-build

	+ $(call s1) DESTDIR="$O" cmake --install $W/zlib-ng-build

	$(call done)
