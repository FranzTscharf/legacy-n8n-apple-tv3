# Bundle manifest

## Ready runtime

| Component | Version / target | Source in this bundle |
|---|---|---|
| Node.js | 12.19.0, Mach-O ARMv7, iPhoneOS 8.0 minimum | `payload/runtime/bin/node` |
| npm | 6.14.8 | `payload/runtime/node_modules/npm` |
| n8n | 0.110.0 | `payload/runtime/node_modules/n8n` |
| sqlite3 | 5.1.7, Mach-O ARMv7 native addon | `payload/runtime/node_modules/sqlite3` |

The SQLite addon is an exact copy of the binary used by the verified working
device on November 23, 2026. The Node executable is the preserved unsigned
cross-build; `install.sh` signs it on the target with `ldid -S`.

## Configuration and installation

- `install.sh`: guarded base installation, backup, signing, launchd setup, and
  HTTP health wait.
- `verify.sh`: versions, services, disk, HTTP health, and recent-error check.
- `config/`: launchd services, low-memory start wrapper, execution pruning, and
  example site configuration.
- `install-community-nodes.sh`: optional tested community-node archives.

## Reproducibility and writing material

- `source/`: exact Node Mobile base commit instructions, 17 source overrides,
  compiler wrappers, build script, and dependency lock.
- `docs/BUILD-HISTORY.md`: reconstructed technical history and failure modes.
- `docs/DEVICE-PACKAGES.md`: compatible Cydia package inventory.
- `docs/BLOG-ARTICLE-OUTLINE.md`: article structure and reproducibility box.
- `examples/`: sanitized, inactive workflows containing placeholders only.

## Optional payloads

- `payload/optional/python3`: verified Python 3.7.1 ARMv7 runtime.
- `payload/optional/tailscale`: historical custom Tailscale 1.22.2 ARMv7 port;
  deliberately excluded from the base installation.

`SHA256SUMS` records every regular file in the extracted bundle. Validate it
from the bundle directory with `shasum -a 256 -c SHA256SUMS` on macOS.
