$W/stage1.mold.extract: $W/MOLD.download
	tar xf $W/$(MOLD_FILE) -C $W
	$(call done)

$W/stage1.mold: $W/stage1.mold.extract \
	$W/stage1.cxx-runtime $W/stage1.zlib-ng $W/stage1.zstd \
	$W/stage1.onetbb

	$(call s1) LDFLAGS="$(LDFLAGS) -Wl,-z,stack-size=1048576" \
	cmake -S $W/mold-$(MOLD_V) \
		-B $W/mold-build				\
		-DCMAKE_BUILD_TYPE=None				\
		-DCMAKE_INSTALL_PREFIX=/usr			\
		-DCMAKE_INSTALL_LIBDIR=lib			\
		-DCMAKE_INSTALL_LIBEXECDIR=lib			\
		-DCMAKE_TOOLCHAIN_FILE=$(AW)/cmake-conf.cmake	\
		-DMOLD_USE_SYSTEM_MIMALLOC=OFF			\
		-DMOLD_USE_MIMALLOC=OFF				\
		-DMOLD_USE_SYSTEM_TBB=ON			\
		-DMOLD_USE_MOLD=OFF
	+ $(call s1) cmake --build $W/mold-build
	+ $(call s1) DESTDIR="$O" cmake --install $W/mold-build

	$(call done)
