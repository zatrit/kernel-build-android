#!/bin/sh

set -eu
. "./env.sh"

tmp_dir=$(mktemp -d)

# Cleanup function to remove temp directory
cleanup() {
  echo "Cleaning up..."
  rm -rf "$tmp_dir"
}

# Download and extract the kernel.org LLVM toolchain
download_llvm() {
  echo "Downloading $LLVM_NAME to $tmp_dir"
  prebuilt_url="https://mirrors.edge.kernel.org/pub/tools/llvm/files/$LLVM_NAME.tar.xz"
  curl -Lf "$prebuilt_url" | tar xJf - -C "$tmp_dir" "$LLVM_NAME"
  mv "$tmp_dir/$LLVM_NAME" "$LLVM_DIR"
}

trap cleanup EXIT

mkdir -p "$TOOLCHAIN_DIR"

if [ ! -d "$LLVM_DIR" ]; then
  download_llvm
  echo "$LLVM_NAME installed to $LLVM_DIR"
else
  echo "$LLVM_NAME already exists at $LLVM_DIR"
fi
