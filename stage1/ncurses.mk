$W/stage1.ncurses.extract: $W/NCURSES.download
	tar xf $W/$(NCURSES_FILE) -C $W

	$(call done)

$W/stage1.ncurses: $W/stage1.ncurses.extract $W/stage1.cxx-runtime
	cd $W/ncurses-$(NCURSES_V) && \
	$(call s1) ./configure --prefix=/usr		\
		--build=$(CBUILDHOST)			\
		--host=$(CHOST)				\
		--enable-widec				\
		--enable-pc-files			\
		--disable-debug				\
		--without-tests				\
		--with-cxx-binding			\
		--with-cxx-shared			\
		--with-shared				\
		--without-normal			\
		--with-xterm-kbs=del			\
		--enable-sigwinch			\
		--mandir=/usr/share/man			\
		--with-pkg-config-libdir=/usr/lib/pkgconfig

	+ $(call s1) make -C $W/ncurses-$(NCURSES_V)

	+ $(call s1) make -C $W/ncurses-$(NCURSES_V) install DESTDIR=$O

	ln -s ncursesw.pc	$O/usr/lib/pkgconfig/ncurses.pc
	ln -s ncurses++w.pc	$O/usr/lib/pkgconfig/ncurses++.pc

	ln -s libncursesw.so	$O/usr/lib/libncurses.so
	ln -s libncurses++w.so	$O/usr/lib/libncurses++.so

	$(call done)

