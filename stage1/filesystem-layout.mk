$W/stage1.filesystem-layout:
	ln -s /usr/bin		$O/bin
	ln -s /usr/lib		$O/lib
	ln -s /usr/bin		$O/sbin
	ln -s bin		$O/usr/sbin

	install -dm 755 "$O"/{home,mnt,srv,run,opt}
	install -dm 750 "$O"/root
	install -dm 555 "$O"/{proc,sys}
	install -dm 1777 "$O"/tmp

	$(call done)
