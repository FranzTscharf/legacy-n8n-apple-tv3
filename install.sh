#!/bin/sh
set -eu

BASE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
RUNTIME=/var/local/n8n-runtime
DATA=/var/local/n8n-data
CONFIG=/var/local/n8n-config
PLIST=/Library/LaunchDaemons/com.n8n.server.plist

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

[ "$(id -u)" = 0 ] || fail "Run this installer as root on the Apple TV."
uname -a | grep -q 'AppleTV3,2' || fail "This bundle targets AppleTV3,2 only."
[ "$(getconf LONG_BIT 2>/dev/null || echo 0)" = 32 ] || fail "A 32-bit userspace is required."
[ -x "$BASE_DIR/payload/runtime/bin/node" ] || fail "Runtime payload is incomplete."
command -v launchctl >/dev/null 2>&1 || fail "launchctl is required."
command -v ldid >/dev/null 2>&1 || fail "ldid is required; install the compatible Cydia package first."
command -v curl >/dev/null 2>&1 || fail "curl is required; install the compatible Cydia package first."
command -v sqlite3 >/dev/null 2>&1 || fail "sqlite3 is required for n8n and execution pruning."

FREE_KB=$(df -k /var | awk 'NR==2 {print $4}')
[ "${FREE_KB:-0}" -ge 700000 ] || fail "At least 700 MB free under /var is required."

STAMP=$(date +%Y%m%d-%H%M%S)
if [ -f "$PLIST" ]; then
  launchctl unload "$PLIST" 2>/dev/null || true
  cp "$PLIST" "$PLIST.backup-$STAMP"
fi
if [ -d "$RUNTIME" ]; then
  mv "$RUNTIME" "$RUNTIME.backup-$STAMP"
  echo "Previous runtime moved to $RUNTIME.backup-$STAMP"
fi

mkdir -p /var/local "$DATA/.n8n" "$CONFIG" /usr/local/bin
cp -R "$BASE_DIR/payload/runtime" "$RUNTIME"
cp "$BASE_DIR/config/n8n-start" "$RUNTIME/bin/n8n-start"
cp "$BASE_DIR/config/n8n-execution-prune" "$RUNTIME/bin/n8n-execution-prune"
chmod 755 "$RUNTIME/bin/node" "$RUNTIME/bin/n8n-start" "$RUNTIME/bin/n8n-execution-prune"

ln -sf ../node_modules/npm/bin/npm-cli.js "$RUNTIME/bin/npm"
ln -sf ../node_modules/npm/bin/npx-cli.js "$RUNTIME/bin/npx"
ln -sf ../node_modules/n8n/bin/n8n "$RUNTIME/bin/n8n"
ln -sf "$RUNTIME/bin/node" /usr/local/bin/node
ln -sf "$RUNTIME/bin/npm" /usr/local/bin/npm
ln -sf "$RUNTIME/bin/npx" /usr/local/bin/npx
ln -sf "$RUNTIME/bin/n8n" /usr/local/bin/n8n

ldid -S "$RUNTIME/bin/node"

if [ ! -f "$CONFIG/env.sh" ]; then
  cp "$BASE_DIR/config/env.example" "$CONFIG/env.sh"
  chmod 600 "$CONFIG/env.sh"
fi

cp "$BASE_DIR/config/com.n8n.server.plist" "$PLIST"
cp "$BASE_DIR/config/com.n8n.execution-prune.plist" /Library/LaunchDaemons/com.n8n.execution-prune.plist
chown root:wheel "$PLIST" /Library/LaunchDaemons/com.n8n.execution-prune.plist 2>/dev/null || true
chmod 644 "$PLIST" /Library/LaunchDaemons/com.n8n.execution-prune.plist

"$RUNTIME/bin/node" --version
"$RUNTIME/bin/npm" --version
"$RUNTIME/bin/n8n" --version

launchctl load "$PLIST"
launchctl load /Library/LaunchDaemons/com.n8n.execution-prune.plist 2>/dev/null || true

echo "Waiting for n8n; first startup can take more than a minute..."
attempt=0
while [ "$attempt" -lt 36 ]; do
  if curl --connect-timeout 2 --max-time 5 -fsS http://127.0.0.1:5678/healthz >/dev/null 2>&1; then
    echo "n8n is ready at http://DEVICE-IP:5678/"
    echo "Logs: $DATA/n8n.log and $DATA/n8n-error.log"
    exit 0
  fi
  attempt=$((attempt + 1))
  sleep 5
done

echo "n8n did not become ready within 180 seconds." >&2
tail -80 "$DATA/n8n-error.log" 2>/dev/null || true
exit 1
