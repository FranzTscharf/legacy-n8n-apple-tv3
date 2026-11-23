#!/bin/sh
set -eu

HERE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
TARGET=${1:-$HERE/node12-mobile}

[ -d "$TARGET/.git" ] || { echo "Usage: $0 /path/to/nodejs-mobile" >&2; exit 1; }
EXPECTED=9d19d1e1710c87fa8f745b64b9ed00528df7842b
ACTUAL=$(git -C "$TARGET" rev-parse HEAD)
[ "$ACTUAL" = "$EXPECTED" ] || {
  echo "Expected base commit $EXPECTED, found $ACTUAL" >&2
  exit 1
}

cp -R "$HERE/node12-overrides/." "$TARGET/"
echo "Applied Apple TV ARMv7/iOS 8 overrides to $TARGET"
