#!/bin/sh

set -e
. "./env.sh"

if [ ! -d "$CLANG_DIR" ]; then
  error "ERROR: clang-$CLANG_PREBUILT is not installed. Use './setup-toolchain.sh'"
fi

wrapper="none"

if command -v ccache >/dev/null 2>&1; then
  echo "Using ccache ($(which ccache))"
  wrapper="ccache"
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

# Use reproducible variables for the build
if [ "$REPRODUCIBLE" = true ]; then
  SOURCES_DIR=$sources_dir . "./repro.sh"
fi

export PATH="$CLANG_DIR/bin/:$PATH"

tuxmake -C $sources_dir \
  --runtime null \
  --target-arch arm64 \
  --kconfig "config/$config_name" \
  --toolchain llvm-android \
  --wrapper $wrapper \
  --output-dir $OUTPUT_DIR \
  --jobs $(nproc) \
  -e LLVM="$CLANG_DIR/bin/" \
  -e LLVM_IAS=1 \
  -e KCFLAGS="$KCFLAGS" \
  -e KBUILD_BUILD_HOST="$KBUILD_BUILD_HOST" \
  -e KBUILD_BUILD_USER="$KBUILD_BUILD_USER" \
  -e KBUILD_BUILD_TIMESTAMP="$KBUILD_BUILD_TIMESTAMP" \
  kernel modules dtbs
