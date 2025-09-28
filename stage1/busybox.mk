$W/stage1.busybox.extract: $W/BUSYBOX.download
	tar xf $W/$(BUSYBOX_FILE) -C $W

	$(call done)

$W/stage1.busybox: $W/stage1.busybox.extract $(SRCDIR)/stage1/busybox.config \
	$W/stage1.c-runtime $W/stage1.linux-uapi-headers
	sed -e "s|@PREFIX@|$O/usr|" $(SRCDIR)/stage1/busybox.config \
		> $W/busybox-$(BUSYBOX_V)/.config

	+ $(call s1) make -C $W/busybox-$(BUSYBOX_V) CC=clang HOSTCC=clang V=1

	+ $(call s1) make -C $W/busybox-$(BUSYBOX_V) CC=clang HOSTCC=clang \
		V=1 install

	mv $O/usr/sbin/* $O/usr/bin
	rmdir $O/usr/sbin

	$(call done)
