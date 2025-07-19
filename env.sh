#!/bin/sh
# Environment configuration for Android kernel builder
# Sets platform-specific paths and variables

. "./builder.cfg"

error() {
  echo "$1" >&2
  exit 1
}

case "$(uname)" in
  Darwin*)
    PLATFORM="darwin-x86"
    ;;
  Linux*)
    PLATFORM="linux-x86"
    ;;
  *)
    error "ERROR: Unsupported platform: $(uname)"
    ;;
esac

OUTPUT_DIR="$PWD/out"
MODULES_DIR="$PWD/modules"
CONFIG_DIR="$PWD/config"
TOOLCHAIN_DIR="$PWD/toolchain/$PLATFORM"

CLANG_DIR="$TOOLCHAIN_DIR/clang-$CLANG_PREBUILT"
