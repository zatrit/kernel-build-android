#!/bin/sh

set -e
. "./env.sh"

if [ ! -d "$CLANG_DIR" ]; then
  error "ERROR: clang-$CLANG_PREBUILT is not installed. Use './setup-toolchain.sh'"
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

if [ -n "$BUILD_DIR" ]; then
  build_dir=--build-dir="$BUILD_DIR"
fi

SOURCES_DIR=$sources_dir . "./repro.sh"
export PATH="$CLANG_DIR/bin/:$PATH"

extra_args="$build_dir $@"

tuxmake -C $sources_dir \
  --runtime null \
  --target-arch arm64 \
  --toolchain llvm-android \
  --compression-type none \
  --kconfig "config/$config_name" \
  --output-dir $OUTPUT_DIR \
  --jobs $(nproc) \
  -e LLVM=1 \
  -e LLVM_IAS=1 \
  -e KCFLAGS="$KCFLAGS" \
  -e KBUILD_BUILD_HOST="$KBUILD_BUILD_HOST" \
  -e KBUILD_BUILD_USER="$KBUILD_BUILD_USER" \
  -e KBUILD_BUILD_TIMESTAMP="$KBUILD_BUILD_TIMESTAMP" \
  -e KBUILD_BUILD_VERSION=1 \
  $extra_args \
  kernel modules dtbs
