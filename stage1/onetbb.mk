$W/stage1.onetbb.extract: $W/ONETBB.download
	tar xf $W/$(ONETBB_FILE) -C $W
	$(call done)

$W/stage1.onetbb.patch: $W/stage1.onetbb.extract
	sed -e "s@#define MALLOC_UNIXLIKE_OVERLOAD_ENABLED __linux__@@" \
		-i $W/oneTBB-$(ONETBB_V)/src/tbbmalloc_proxy/proxy.h
	$(call done)

$W/stage1.onetbb: $W/stage1.onetbb.patch \
	$W/stage1.cxx-runtime $W/stage1.hwloc

	$(call s1) LDFLAGS="$(LDFLAGS) -Wl,--undefined-version" \
	cmake -S $W/oneTBB-$(ONETBB_V) \
		-B $W/onetbb-build				\
		-DCMAKE_BUILD_TYPE=None				\
		-DCMAKE_INSTALL_PREFIX=/usr			\
		-DCMAKE_TOOLCHAIN_FILE=$(AW)/cmake-conf.cmake	\
		-DTBB4PY_BUILD=OFF				\
		-DTBB_TEST=OFF					\
		-DTBB_STRICT=OFF

	+ $(call s1) cmake --build $W/onetbb-build
	+ $(call s1) DESTDIR="$O" cmake --install $W/onetbb-build

	$(call done)
