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

if [ -z "$BUILD_DIR" ]; then
  BUILD_DIR=$(mktemp -d)
  remove_build_dir=1
fi

cleanup() {
  echo "Cleaning up..."
  [ "$remove_build_dir" = 1 ] && rm -rf "$BUILD_DIR"
}
trap cleanup EXIT

mkdir -p "$BUILD_DIR"
cp "config/$config_name" "$BUILD_DIR/.config"

cd $sources_dir

set -- "$@" \
  O="$BUILD_DIR" \
  INSTALL_MOD_PATH="$OUTPUT_DIR" \
  INSTALL_DTBS_PATH="$OUTPUT_DIR/dtbs" \
  ARCH="$ARCH" \
  LLVM=1 \
  KCFLAGS="$KCFLAGS" \
  KAFLAGS="$KAFLAGS" \
  SOURCE_DATE_EPOCH="$(git log -1 --format='%ct')" \
  KBUILD_BUILD_USER="$(git log -1 --format='%ce' | cut -d'@' -f1)" \
  KBUILD_BUILD_HOST="$(git log -1 --format='%ce' | cut -d'@' -f2)" \
  KBUILD_BUILD_TIMESTAMP="$(git log -1 --format='%ci')" \
  KBUILD_BUILD_VERSION=1 \
  ZERO_AR_DATE=1 \
  INSTALL_MOD_STRIP="-D --strip-debug"

if [ -n "$WRAPPER" ]; then
  set -- "$@" CC="$WRAPPER clang"
  set -- "$@" AS="$WRAPPER clang"
fi

make "$@" olddefconfig
make "$@" "$IMAGE" modules dtbs
make "$@" dtbs_install modules_install

# Remove source directories
rm -rf $OUTPUT_DIR/lib/modules/*/source
rm -rf $OUTPUT_DIR/lib/modules/*/build

cp "$BUILD_DIR/arch/$ARCH/boot/$IMAGE" "$OUTPUT_DIR/$IMAGE"
cp "$BUILD_DIR/.config" "$OUTPUT_DIR/config"
