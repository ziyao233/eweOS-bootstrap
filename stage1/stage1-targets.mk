$W/stage1.c-runtime: \
	$W/stage1.musl-lib $W/stage1.musl-headers $W/stage1.compiler-rt
	$(call done)

$W/stage1: $W/stage1.c-runtime $W/stage1.cxx-runtime			\
	$W/stage1.filesystem-layout					\
	$W/stage1.bash $W/stage1.busybox $W/stage1.filesystem-layout	\
	$W/stage1.make $W/stage1.pkgconf $W/stage1.mold $W/stage1.llvm	\
	$W/stage1.ca-certs $W/stage1.curl $W/stage1.libarchive

	$(call done)
