#!/bin/sh
set -eu

BASE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
TARGET=/var/local/n8n-community
EXTENSIONS=$TARGET/extensions

[ "$(id -u)" = 0 ] || { echo "Run as root." >&2; exit 1; }
mkdir -p "$TARGET" "$EXTENSIONS"

tar -xzf "$BASE_DIR/payload/community/n8n-community-batch1.tar.gz" -C "$TARGET"
tar -xzf "$BASE_DIR/payload/community/n8n-community-batch2.tar.gz" -C "$TARGET"
tar -xzf "$BASE_DIR/payload/community/n8n-nodes-ai-compatible.tar.gz" -C "$EXTENSIONS"
tar -xzf "$BASE_DIR/payload/community/n8n-nodes-legacy-essentials.tar.gz" -C "$EXTENSIONS"

PLIST=/Library/LaunchDaemons/com.n8n.server.plist
launchctl unload "$PLIST" 2>/dev/null || true
launchctl load "$PLIST"
echo "Community nodes installed. Startup may take several minutes on the first scan."
