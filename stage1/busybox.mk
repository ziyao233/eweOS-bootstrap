$W/stage1.busybox.extract: $W/BUSYBOX.download
	tar xf $W/$(BUSYBOX_FILE) -C $W

	$(call done)

$W/stage1.busybox.patch: $W/stage1.busybox.extract
	patch -p1 -d $W/busybox-$(BUSYBOX_V) < \
		$(SRCDIR)/stage1/busybox-0001-fix-missing-sha1_process_block64_shaNI.patch

	$(call done)

# Depends on filesystem-layout to ensure /usr/sbin has been installed as a
# symlink before busybox installation
$W/stage1.busybox: $W/stage1.busybox.patch $(SRCDIR)/stage1/busybox.config \
	$W/stage1.c-runtime $W/stage1.linux-uapi-headers		\
	$W/stage1.filesystem-layout
	sed -e "s|@PREFIX@|$O/usr|" $(SRCDIR)/stage1/busybox.config \
		> $W/busybox-$(BUSYBOX_V)/.config

	+ $(call s1) make -C $W/busybox-$(BUSYBOX_V) CC=clang HOSTCC=clang V=1

	+ $(call s1) make -C $W/busybox-$(BUSYBOX_V) CC=clang HOSTCC=clang \
		V=1 install

	$(call done)
