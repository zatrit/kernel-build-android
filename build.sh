#!/bin/sh

set -e
. "./env.sh"

if [ ! -d "$CLANG_DIR" ]; then
  error "ERROR: clang-$CLANG_PREBUILT is not installed. Use './setup-toolchain.sh'"
fi

USE_CCACHE=false

if command -v ccache >/dev/null 2>&1; then
  echo "Using ccache ($(which ccache))"
  USE_CCACHE=true
fi

config_name="$1"
sources_dir="$2"

if [ -z "$config_name" ] || [ -z "$sources_dir" ]; then
  error "Usage: $0 [config name] [sources dir]"
fi

if [ ! -d "$sources_dir" ]; then
  error "ERROR: kernel sources directory not found"
fi

cd "$sources_dir"

build_env="LLVM=$CLANG_DIR/bin/ LLVM_IAS=1 O=$OUTPUT_DIR ARCH=arm64"

if [ "$USE_CCACHE" = true ]; then
    build_env="$build_env CC='ccache $CLANG_DIR/bin/clang' CXX='ccache $CLANG_DIR/bin/clang++'"
fi

mkdir -p "$OUTPUT_DIR"
make $build_env mrproper

cp "$CONFIG_DIR/$config_name" "$OUTPUT_DIR/.config"

make $build_env olddefconfig
make $build_env
