#!/bin/sh

set -e
. "./env.sh"

if [ ! -d "$CLANG_DIR" ]; then
  error "ERROR: clang-$CLANG_PREBUILT is not installed. Use './setup-toolchain.sh'"
fi

use_ccache=false

if command -v ccache >/dev/null 2>&1; then
  echo "Using ccache ($(which ccache))"
  use_ccache=true
fi

config_name="$1"
sources_dir="$2"

if [ -z "$config_name" ] || [ -z "$sources_dir" ]; then
  error "Usage: $0 [config name] [sources dir]"
fi

if [ ! -d "$sources_dir" ]; then
  error "ERROR: kernel sources directory not found"
fi

shift 2

cd "$sources_dir"

cc="$CLANG_DIR/bin/clang"
cxx="$CLANG_DIR/bin/clang++"

if [ "$use_ccache" = true ]; then
  cc="ccache $cc"
  cxx="ccache $cxx"
fi

build_env="O=$OUTPUT_DIR LLVM=$CLANG_DIR/bin/ LLVM_IAS=1 ARCH=arm64"

mkdir -p "$OUTPUT_DIR"
make $build_env mrproper

cp "$CONFIG_DIR/$config_name" "$OUTPUT_DIR/.config"

make $build_env olddefconfig
make $build_env CC="$cc" CXX="$cxx" KCFLAGS="$KCFLAGS" Image.gz modules $DTBS "$@"
make $build_env INSTALL_MOD_PATH="$MODULES_DIR" modules_install
