#!/bin/sh

set -e
. "./env.sh"

if [ ! -d "$LLVM_DIR" ]; then
  error "ERROR: toolchain is not installed. Use './setup-toolchain.sh'"
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
extra_args="$build_dir $@"

# Obtain the commit info
cd $sources_dir
KBUILD_BUILD_USER=$(git log -1 --format='%ce' | cut -d'@' -f1)
KBUILD_BUILD_HOST=$(git log -1 --format='%ce' | cut -d'@' -f2)
KBUILD_BUILD_TIMESTAMP=$(git log -1 --format='%ci')
SOURCE_DATE_EPOCH=$(git log -1 --format='%ct')
cd - >/dev/null

# https://tuxmake.org/cli/
export TUXMAKE="
  -C '$sources_dir'
  --runtime null
  --target-arch arm64
  --toolchain korg-llvm
  --compression-type none
  --kconfig 'config/$config_name'
  --output-dir '$OUTPUT_DIR'
  --jobs $(nproc)
  -e ZERO_AR_DATE=1
  -e LC_ALL=C
  -e LC_TIME=C
  -e TZ=UTC
  -e KCFLAGS='$KCFLAGS'
  -e KAFLAGS='$KAFLAGS'
  -e KBUILD_BUILD_HOST='$KBUILD_BUILD_HOST'
  -e KBUILD_BUILD_USER='$KBUILD_BUILD_USER'
  -e KBUILD_BUILD_TIMESTAMP='$KBUILD_BUILD_TIMESTAMP'
  -e SOURCE_DATE_EPOCH='$SOURCE_DATE_EPOCH'
  -e KBUILD_BUILD_VERSION=1
  $extra_args"

tuxmake kernel modules dtbs
