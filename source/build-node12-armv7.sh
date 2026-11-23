#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/node12-mobile"
SDK_PATH="$(xcrun --sdk iphoneos --show-sdk-path)"

cd "$SOURCE_DIR"
export PATH="$SCRIPT_DIR/python2-host/bin:$PATH"
export IPHONEOS_DEPLOYMENT_TARGET=8.0
export CC="$SCRIPT_DIR/toolchain/target-cc -isysroot $SDK_PATH -miphoneos-version-min=8.0"
export CXX="$SCRIPT_DIR/toolchain/target-cxx -isysroot $SDK_PATH -miphoneos-version-min=8.0"
export CC_host="$SCRIPT_DIR/toolchain/host-cc"
export CXX_host="$SCRIPT_DIR/toolchain/host-cxx"
export LDFLAGS="-arch armv7 -isysroot $SDK_PATH -miphoneos-version-min=8.0"
export GYP_DEFINES="target_arch=arm host_arch=arm64 host_os=mac target_os=ios v8_enable_embedded_builtins=1"

./configure \
  --dest-os=ios \
  --dest-cpu=arm \
  --cross-compiling \
  --with-intl=none \
  --openssl-no-asm \
  --v8-options=--jitless \
  --without-node-code-cache \
  --without-node-snapshot \
  --without-snapshot \
  --without-inspector

make -j8

echo "Built: $SOURCE_DIR/out/Release/node"
file "$SOURCE_DIR/out/Release/node"
