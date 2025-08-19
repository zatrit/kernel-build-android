#!/bin/sh
# Environment configuration for Android kernel builder
# Sets platform-specific paths and variables

. "./builder.cfg"

error() {
  echo "$1" >&2
  exit 1
}

OUT_DIR="$PWD/out"
CONFIG_DIR="$PWD/config"
TOOLCHAIN_DIR="$PWD/toolchain/"
LLVM_NAME="llvm-$LLVM_VER-$(uname -m)"
LLVM_DIR=${LLVM_DIR:-"$TOOLCHAIN_DIR/$LLVM_NAME"}

export PATH="$LLVM_DIR/bin/:$PATH"
