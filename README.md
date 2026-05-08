# Bootstrap facilities for eweOS

This set of scripts aim to provide automatic bootstrap facilities for eweOS.

## Packages need to be bootstrapped

- `base` and `base-devel`: Supported
- `python` packages: TODO
- `rust`: Cross-compilation only
- `ghc`: TODO
- `golang`: TODO
- ... and more?

### Overview of base/base-devel bootstrap

The process is split into four stages,

- `stage0`: Cross-compiled. Compile tools to run on `build` platform. Currently
  an eweOS-like system is assumed, thus the only target in `stage0` is a LLVM
  toolchain without runtime libraries.
- `stage1`: Cross-compiled. Compile C/C++ libraries, native toolchain, and
  basic POSIX-compilant environment to run on `host` platform.
- `stage2`: Compile natively in rootfs produced by `stage1`, artifacts are
  installed directly into the rootfs. Compile base/base-devel components which
  aren't covered by `stage1`, to produce a rootfs fully equivalent to
  `base`/`base-devel`.
- `stage3`: Compile natively in rootfs produced by `stage1` with additional
  packages produced by `stage2`. Compile all base/base-devel packages from
  eweOS mainline, artifacts are in pacman format (`*.pkg.tar.*`).

`stage1` and `stage2` are intentionally separated to minimize
cross-compilation for easier maintanence.

The first three stages are driven by GNU Makefiles, to build them, run

```shell
# There's no need to manually build stage0, stage1 targets claim dependencies
# to it.
make build/stage1
```

or

```shell
make build/stage2
```

`stage3` build is driven by `stage3/build.sh`, which pulls `PKGBUILD` from
[eweOS mainline repository](https://github.com/eweOS/packages.git) and run
`makepkg` on them.

A list of packages in `base` and `base-devel` is available at `stage3/packages`.
To build all of them, run

```shell
mkdir stage3-built
cd stage3-buil

while read pkg; do
	../stage3/build.sh https://github.com/eweOS/packages.git "$pkg" ||
		break
done < ../stage3/packages
```

`stage3/build.sh` applies `stage3/<PKGNAME>.patch` if it exists when building
a package, which is useful if patching mainline build scripts is necessary for
breaking dependency loops or minimizing dependencies.


### Overview of Rust bootstrap

It's separated into three stages,

1. Bootstrapping rustc with help of mrustc, which is a Rust compiler written in
   C++. This step would probably be only maintained for x86_64. TODO.
2. Cross-compiling Rustc from one architecture to another. Available.
3. Automatically lifting Rust versions. TODO.

Related scripts are located in `rust/`.

#### Cross-compiling Rustc

`rust/cross-build.sh` serves for the purpose, which accepts three arguments,

```
# Provide absolute path for <TARGET_ROOTFS>
./cross-build.sh <TARGET_ARCH> <RUSTC_VERSION> <TARGET_ROOTFS>
```

and respects `JOBS` environment variable.

This script automatically downloads rustc sources, wraps `clang` as a C/C++
compiler on `<TARGET_ROOTFS>`, generates `config.toml` bootstrapping
configuration for rustc, and builds it. Patches (ended with `.patch`) in
`rust/patches/<RUSTC_VERSION>` will be applied to rustc source before building.

The following packages must be available on the build side,

- `rustc`: Please note that rustc could only be bootstrapped with compiler
	   exactly one version earlier or with the same version.
- `qemu-user` for `<TARGET_ARCH>`: Required for wrapping target `llvm-config`.
- `zstd`
- `curl`
- `llvm`

The following packages must be available on the build/target rootfs,

- `llvm`
