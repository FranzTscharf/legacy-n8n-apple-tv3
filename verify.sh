#!/bin/sh
set -eu

echo "Hardware: $(uname -a)"
echo "Disk:"
df -h / /var
echo "Versions:"
/var/local/n8n-runtime/bin/node --version
/var/local/n8n-runtime/bin/npm --version
/var/local/n8n-runtime/bin/n8n --version
echo "Services:"
launchctl list | grep -E 'com\.n8n\.(server|execution-prune)' || true
echo "HTTP:"
curl --connect-timeout 3 --max-time 15 -i http://127.0.0.1:5678/healthz
echo "Recent errors:"
tail -40 /var/local/n8n-data/n8n-error.log 2>/dev/null || true
