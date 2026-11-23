#!/bin/sh
set -eu

BASE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
TARGET=/var/local/tailscale
PLIST=/Library/LaunchDaemons/com.tailscale.tailscaled.plist

if [ "${1:-}" != "--i-understand-experimental" ]; then
  echo "This is an unsupported historical Tailscale ARMv7 port." >&2
  echo "Read SECURITY.md and docs/TAILSCALE-README.md first." >&2
  echo "To proceed: $0 --i-understand-experimental" >&2
  exit 2
fi

[ "$(id -u)" = 0 ] || { echo "Run as root." >&2; exit 1; }
uname -a | grep -q 'AppleTV3,2' || { echo "AppleTV3,2 required." >&2; exit 1; }
command -v ldid >/dev/null 2>&1 || { echo "ldid is required." >&2; exit 1; }

launchctl unload "$PLIST" 2>/dev/null || true
if [ -d "$TARGET/bin" ]; then
  STAMP=$(date +%Y%m%d-%H%M%S)
  mv "$TARGET/bin" "$TARGET/bin.backup-$STAMP"
fi

mkdir -p "$TARGET" "$TARGET/state" /var/run/tailscale /usr/local/bin
cp -R "$BASE_DIR/payload/optional/tailscale/bin" "$TARGET/bin"
cp "$BASE_DIR/payload/optional/tailscale/README.md" "$TARGET/README.md"
cp "$BASE_DIR/config/tailscale-device" /usr/local/bin/tailscale-device
cp "$BASE_DIR/config/com.tailscale.tailscaled.plist" "$PLIST"
chmod 755 "$TARGET/bin/"* /usr/local/bin/tailscale-device
chmod 644 "$PLIST"
ldid -S "$TARGET/bin/tailscale"
ldid -S "$TARGET/bin/tailscaled"

launchctl load "$PLIST"
echo "Daemon installed. Run 'tailscale-device login' and approve the printed URL."
echo "Do not copy a tailscaled.state file from another device."
