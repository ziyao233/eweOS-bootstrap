$W/stage1.zstd.extract: $W/ZSTD.download
	tar xf $W/$(ZSTD_FILE) -C $W
	$(call done)

$W/stage1.zstd: $W/stage1.zstd.extract \
	$W/stage1.zlib-ng $W/stage1.cxx-runtime $W/cmake-conf.cmake
	$(call s1) cmake -S $W/zstd-$(ZSTD_V)/build/cmake \
		 -B $W/zstd-build -G Ninja			\
		-DCMAKE_BUILD_TYPE=None				\
		-DCMAKE_INSTALL_PREFIX=/usr			\
		-DCMAKE_INSTALL_LIBDIR=lib			\
		-DCMAKE_TOOLCHAIN_FILE=$(AW)/cmake-conf.cmake	\
		-DZSTD_ZLIB_SUPPORT=ON				\
		-DZSTD_LZMA_SUPPORT=OFF				\
		-DZSTD_LZ4_SUPPORT=OFF				\
		-DZSTD_BUILD_STATIC=OFF				\
		-DZSTD_BUILD_TESTS=OFF				\
		-DZSTD_BUILD_CONTRIB=OFF			\
		-DZSTD_PROGRAMS_LINK_SHARED=ON
	+ $(call s1) cmake --build $W/zstd-build
	+ $(call s1) DESTDIR="$O" cmake --install $W/zstd-build

	$(call done)
