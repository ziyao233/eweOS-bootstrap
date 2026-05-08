#!/usr/bin/env bash

msg() {
	echo "$1" 2>&1
}

if [ -t 1 ]; then
	red_msg() {
		echo -ne "\033[31m"
		msg "$1"
		echo -ne "\033[39m"
	}

	blue_msg() {
		echo -ne "\033[34m"
		msg "$1"
		echo -ne "\033[39m"
	}
else
	red_msg() {
		msg "$1"
	}

	blue_msg() {
		msg "$1"
	}
fi

info() {
	blue_msg "$1"
}

progress() {
	blue_msg "$(date '+%C%y/%m/%d %H:%M:%S'): $1"
}

error() {
	red_msg "$1"
	exit 1
}

buildarch="$(uname -m)"
hostarch="$1"
case "$hostarch" in
x86_64|aarch64|loongarch64)
	;;
riscv64)
	hostarch="riscv64gc" ;;
*)
	error "Invalid hostarch \"$hostarch\"" ;;
esac

rustver="$2"

patchdir="$(realpath $(dirname $0))"/patches/"$rustver"
[ -d "$patchdir" ] || error "Invalid Rust version \"$rustver\""

rootfs="$(realpath "$3")"
[ "-d" "$rootfs" ] || error "Invalid rootfs \"$rootfs\""

JOBS=${JOBS:-$(nproc)}

progress "Cross-compiling Rust on $buildarch for $hostarch"
msg	"Rust version:	$rustver"
msg	"Rootfs:	$rootfs"
msg	""

progress "Downloading Rust source package version $rustver"

curl -C - -o "rust-$rustver.tar.gz" -L \
	"https://static.rust-lang.org/dist/rustc-$rustver-src.tar.gz" || exit 1

progress "Uncompressing Rust source"
tar xf "rust-$rustver.tar.gz"

progress "Applying patches"
for p in `find "$patchdir" -name '*.patch'`; do
	info "Applying $p"
	patch -p1 -d "rustc-$rustver-src" < "$p" || exit 1
done

progress "Generating Clang wrappers for host rootfs"
cat <<EOF > clang-host
#!/usr/bin/env bash
exec clang --sysroot "$rootfs" 				\
	-target $hostarch-unknown-linux-musl		\
	-resource-dir="$rootfs/$(clang -print-resource-dir)" "\$@"
EOF

cat <<EOF > clangxx-host
#!/usr/bin/env bash
exec clang++ --sysroot "$rootfs" 				\
	-target $hostarch-unknown-linux-musl			\
	-nostdinc++ -isystem "$rootfs/usr/include/c++/v1"	\
	-resource-dir="$rootfs/$(clang -print-resource-dir)" "\$@"
EOF

chmod +x clang-host clangxx-host

arch2qemu() {
	case "$1" in
	x86_64)
		echo "qemu-x86_64" ;;
	aarch64)
		echo "qemu-aarch64" ;;
	riscv64)
		echo "qemu-riscv64" ;;
	loongarch64)
		echo "qemu-loongarch64" ;;
	esac
}

progress "Generate llvm-config wrappers for host LLVM"

cat <<EOF > llvm-config-host
#!/usr/bin/env bash

hostconfig="$(arch2qemu "$hostarch") -L $rootfs $rootfs/usr/bin/llvm-config"
\$hostconfig "\$@"
EOF

chmod +x llvm-config-host

arch2llvm() {
	case "$1" in
	x86_64)
		echo "X86" ;;
	aarch64)
		echo "AArch64" ;;
	riscv64)
		echo "RISCV" ;;
	loongarch64)
		echo "LoongArch" ;;
	esac
}

buildllvmarch="$(arch2llvm $buildarch)"
hostllvmarch="$(arch2llvm $hostarch)"

progress "Generating Rust config.toml configuration"

#	LLVM is devendored for both host and target, have tried,
#
#	## Devendor LLVM for build target only
#
#	Don't work. In opposite to obtaining flags correctly through host's
#	llvm-config, Rustc instead insanely takes flags from BUILD's llvm-config
#	and applies them for the HOST's LLVM, and states
#
#		This only really works if the host LLVM and target LLVM are
#		compiled the same way, but for us that's typically the case.
#
#	in compiler/rustc_llvm/build.rs of Rust 1.94.1. Correct me if I'm wrong.
#
#	Unluckily the statement is wrong. Flags like "-I/usr/include" may be
#	carried in llvm-config --cxxflags which pollutes header namespace and
#	breaks build. They're common if Rust is built against a system LLVM
#	installed to /usr, where -I{includedir} just expands to "/usr/include".
#
#	## Devendor LLVM for both build and host target (current way)
#
#	Works in a horrible way. LLVM could only be discovered by llvm-config
#	or CMake configuration files, and Rust only looks for the former.
#	However, llvm-config is an executable binary, not a script, making it
#	extremely unsuitable for cross-compilation purpose.
#
#	In this bootstrapping process, we require qemu-user for the target
#	architecture for configuring LLVM parameters.
#
#	See also https://github.com/llvm/llvm-project/issues/9777
#
#	Dawn. Good luck for anyone trying to fix it up. I always fall into this
#	rabbit hole.
cat <<EOF > config.toml
profile = "user"

[llvm]
link-shared = true
static-libstdcpp = false
use-libcxx = true
targets = "$buildllvmarch;$hostllvmarch"
experimental-targets = ""

[build]
build = "$buildarch-unknown-linux-musl"
host = ["$hostarch-unknown-linux-musl"]
target = ["$hostarch-unknown-linux-musl"]
cargo = "$(which cargo)"
rustc = "$(which rustc)"
rustfmt = "$(which rustfmt)"
locked-deps = true
vendor = true
tools = ["cargo"]
sanitizers = false
profiler = false
docs = false
description = "eweOS rust bootstrap"

[install]
prefix = "/usr"

[rust]
debuginfo-level-std = 2
channel = "stable"
rpath = false
backtrace-on-ice = true
remap-debuginfo = true
jemalloc = false
llvm-libunwind = "system"
codegen-units-std = 256
deny-warnings = false
lld = false
musl-root = "/usr"
llvm-tools = false

[target.$buildarch-unknown-linux-musl]
crt-static = false
llvm-config = "$(which llvm-config)"

[target.$hostarch-unknown-linux-musl]
crt-static = false
cc="$PWD/clang-host"
cxx="$PWD/clangxx-host"
linker="$PWD/clang-host"
musl-root="$rootfs"
musl-libdir="$rootfs/usr/lib"
llvm-config = "$PWD/llvm-config-host"
EOF

progress "Building Rust"
env \
	RUST_BACKTRACE=1				\
	PKG_CONFIG_PATH="$rootfs/usr/lib/pkgconfig"	\
	PKG_CONFIG_SYSROOT_DIR="$rootfs"		\
python "rustc-$rustver-src"/x.py build -j$JOBS || exit 1


progress "Installing Rust toolchain files"
DESTDIR="$PWD/install" python "$rustc-$rustver-src"/x.py install -j$JOBS ||
	exit 1

progress "Collecting toolchain tarball"
tar --uid 0 --gid 0 --zstd -cf "rustc-$rustver-$hostarch.tar.zst" \
	-C install . || exit 1

ls -lh *.tar.zst
