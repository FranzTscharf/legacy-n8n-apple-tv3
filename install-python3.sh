#!/bin/sh
set -eu

BASE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
TARGET=/var/local/python3

[ "$(id -u)" = 0 ] || { echo "Run as root." >&2; exit 1; }
uname -a | grep -q 'AppleTV3,2' || { echo "AppleTV3,2 required." >&2; exit 1; }

if [ -d "$TARGET" ]; then
  STAMP=$(date +%Y%m%d-%H%M%S)
  mv "$TARGET" "$TARGET.backup-$STAMP"
fi

mkdir -p /var/local /usr/local/bin
cp -R "$BASE_DIR/payload/optional/python3" "$TARGET"
chmod 755 "$TARGET/bin/python3.7"
command -v ldid >/dev/null 2>&1 && ldid -S "$TARGET/bin/python3.7"

cp "$BASE_DIR/config/python3-wrapper" /usr/local/bin/python3
chmod 755 /usr/local/bin/python3
/usr/local/bin/python3 --version
echo "Optional Python 3 runtime installed at $TARGET"
