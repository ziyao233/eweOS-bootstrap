$W/stage1.bash.extract: $W/BASH.download
	tar xf $W/$(BASH_FILE) -C $W
	$(call done)

BASH_EXTRA_CFLAGS := -DDEFAULT_PATH_VALUE=\"/usr/local/sbin:/usr/local/bin:/usr/bin\"
BASH_EXTRA_CFLAGS += -DSTANDARD_UTILS_PATH=\"/usr/bin\"
BASH_EXTRA_CFLAGS += -DSYS_BASHRC=\"/etc/bashrc\"
BASH_EXTRA_CFLAGS += -DNON_INTERACTIVE_LOGIN_SHELLS

$W/stage1.bash: $W/stage1.bash.extract \
	$W/stage1.c-runtime $W/stage1.ncurses $W/stage1.readline

	cd $W/bash-$(BASH_V) && \
	$(call s1) env CFLAGS='$(S1CFLAGS) $(BASH_EXTRA_CFLAGS)' \
	./configure --prefix=/usr \
		--build=$(CBUILDHOST)		\
		--host=$(CHOST)			\
		--mandir=/usr/share/man		\
		--without-bash-malloc		\
		--with-installed-readline	\
		--with-curses

	+ $(call s1) make -C $W/bash-$(BASH_V)
	+ $(call s1) make -C $W/bash-$(BASH_V) install DESTDIR="$O"

	ln -s bash $O/usr/bin/sh

	$(call done)
