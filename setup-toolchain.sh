#!/bin/sh

set -e
. "./env.sh"

tmp_dir=$(mktemp -d)
clang_name="clang-$CLANG_PREBUILT"

if [ "$CLANG_PREBUILT" = "stable" ]; then
  echo "WARNING: Please do not set CLANG_PREBUILT to 'stable', this will break the guarantee that the toolchain is installed according to 'builder.cfg'" >&2
fi

# Cleanup function to remove temp directory
cleanup() {
  echo "Cleaning up..."
  rm -rf "$tmp_dir"
}

# Download and extract Clang toolchain
download_clang() {
  echo "Downloading $clang_name to $tmp_dir"
  prebuilt_url="https://android.googlesource.com/platform/prebuilts/clang/host/$PLATFORM/+archive/refs/heads/$AOSP_BRANCH.tar.gz"
  curl -Lf $prebuilt_url | tar xzf - -C "$tmp_dir" "$clang_name"
  mv "$tmp_dir/$clang_name" "$CLANG_DIR"
}

trap cleanup EXIT

mkdir -p "$TOOLCHAIN_DIR"
if [ ! -d "$CLANG_DIR" ]; then
  download_clang
  echo "$clang_name installed to $CLANG_DIR"
else
  echo "$clang_name already exists at $CLANG_DIR"
fi
