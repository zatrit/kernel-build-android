#!/bin/sh
# Environment configuration for Android kernel builder
# Sets platform-specific paths and variables

. "./builder.cfg"

error() {
  echo "$1" >&2
  exit 1
}

OUTPUT_DIR="$PWD/out"
CONFIG_DIR="$PWD/config"
TOOLCHAIN_DIR="$PWD/toolchain/"
LLVM_NAME="llvm-$LLVM_VER-$(uname -m)"
LLVM_DIR="$TOOLCHAIN_DIR/$LLVM_NAME"

if [ -d "$LLVM_DIR/bin/" ]; then
  export PATH="$LLVM_DIR/bin/:$PATH"
fi
