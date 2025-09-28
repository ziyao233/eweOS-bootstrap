$W/stage1.readline.extract: $W/READLINE.download
	tar xf $W/$(READLINE_FILE) -C $W
	$(call done)

$W/stage1.readline: $W/stage1.readline.extract \
	$W/stage1.c-runtime $W/stage1.ncurses

	cd $W/readline-$(READLINE_V) && \
	$(call s1) ./configure --prefix=/usr

	+ $(call s1) make -C $W/readline-$(READLINE_V) SHLIB_LIBS=-lncurses
	+ $(call s1) make -C $W/readline-$(READLINE_V) install DESTDIR="$O"

	install -Dm644 $(SRCDIR)/stage1/readline.inputrc "$O"/etc/inputrc

	$(call done)
