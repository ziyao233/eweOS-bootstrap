OPENSSL_ARCH_x86_64		:= linux-x86_64
OPENSSL_ARCH_aarch64		:= linux-aarch64
OPENSSL_ARCH_riscv64		:= linux64-riscv64
OPENSSL_ARCH_loongarch64	:= linux64-loongarch64
OPENSSL_ARCH := $(OPENSSL_ARCH_$(CARCH))

$W/stage1.openssl.extract: $W/OPENSSL.download
	tar xf $W/$(OPENSSL_FILE) -C $W
	$(call done)

$W/stage1.openssl: $W/stage1.openssl.extract \
	$W/stage1.c-runtime $W/stage1.linux-uapi-headers

	cd $W/openssl-$(OPENSSL_V) && \
	$(call s1) ./Configure --prefix=/usr \
		--openssldir=/etc/ssl		\
		--libdir=lib			\
		shared $(OPENSSL_ARCH)		\
		"-Wa,--noexecstack $(S1CFLAGS) $(S1LDFLAGS)"

	+ $(call s1) make -C $W/openssl-$(OPENSSL_V) \
		CC=clang CXX=clang++ depend

	+ $(call s1) make -C $W/openssl-$(OPENSSL_V) \
		CC=clang CXX=clang++

	+ $(call s1) make -C $W/openssl-$(OPENSSL_V) \
		CC=clang CXX=clang++			\
		DESTDIR="$O" install_sw install_ssldirs

	$(call done)
