# Reconstructed build history

This record was reconstructed from the original October 9–14, 2026 Codex
setup chat, later n8n troubleshooting chats, the preserved build workspace,
and a read-only inventory of the running appliance on November 23, 2026.

## 1. The device was not Debian

The target identified itself as:

```text
AppleTV3,2
iPhone OS 8.4.4 (12H1006)
Darwin 14
iphoneos-arm
32-bit ARMv7
```

Adding ordinary Debian or NodeSource repositories would have installed
binary-incompatible packages and risked damaging `dpkg`. The compatible Cydia
base supplied Python 2.5.1, Git 2.8.1, Ruby 1.9.2, GNU Make 3.81, Nano 2.2.6,
rsync 3.0.5, SQLite, `ldid`, and later `socat`/Netatalk for optional services.

An added modern iOS Node repository was disabled because its package required
ARM64 and iOS 15. The device needs 32-bit `iphoneos-arm` binaries.

## 2. Node had to be cross-compiled

Historic Node 0.4/0.6 iOS ports were researched first, but they were far too old
for n8n. The successful base was Node.js for Mobile Apps v0.3.2, commit
`9d19d1e1710c87fa8f745b64b9ed00528df7842b`, which carries Node 12.19.0.

The build used an Apple Silicon Mac, the iPhoneOS SDK, an ARMv7 target, and an
iOS 8.0 deployment minimum. Node's generator required a host Python 2.7, so
Python 2.7.18 was built privately for the build host. Custom compiler wrappers
separated host-side V8 generators from target-side ARMv7 compilation.

Key configuration:

```text
--dest-os=ios
--dest-cpu=arm
--cross-compiling
--with-intl=none
--openssl-no-asm
--v8-options=--jitless
--without-node-code-cache
--without-node-snapshot
--without-snapshot
--without-inspector
```

The 17 source overrides in `source/node12-overrides/` handle old-iOS/ARMv7
platform assumptions, host generator compilation, pointer-width assertions,
V8 simulator casts, code/snapshot behavior, and unsupported facilities. The
result is a 32-bit ARMv7 Mach-O with `LC_VERSION_MIN_IPHONEOS 8.0`.

On the Apple TV the binary must be signed with `ldid -S` before execution.

Upstream references:

- <https://github.com/JaneaSystems/nodejs-mobile>
- <https://github.com/JaneaSystems/nodejs-mobile/blob/mobile-master/doc_mobile/CHANGELOG.md>

## 3. n8n and SQLite were staged off-device

n8n 0.110.0 was selected because it supports Node 12 and is small enough to be
practical on this hardware. Its npm dependency tree was resolved on the Mac,
then transferred as a ready runtime. n8n requested `sqlite3` through its
compatible `^5.0.1` range; the preserved lock resolved `sqlite3` 5.1.7. Its
native addon was cross-compiled for ARMv7/iOS and inserted into that tree.

The preserved dependency lock and native addon are part of the payload. The
n8n version can be verified in npm's historical version list:

- <https://www.npmjs.com/package/n8n?activeTab=versions>

Several old n8n database/migration files also needed compatibility fixes; the
resolved files are already present in the ready payload. Reinstalling from the
current npm registry is not equivalent to using this bundle because registry
resolution and transitive packages have changed over time.

## 4. Runtime stability required two independent fixes

The first launchd-started process crashed while the same binary was more stable
in the foreground. Crash inspection showed MobileSubstrate injected into the
daemon. The launch environment now sets `_MSSafeMode=1` and clears
`DYLD_INSERT_LIBRARIES`.

V8 also became unstable during large editor/node-catalog allocations when its
background garbage-collection workers ran on this old target. The launch script
therefore uses:

```text
--max-old-space-size=256
--single-threaded-gc
--no-concurrent-marking
--no-concurrent-sweeping
--no-parallel-marking
--no-parallel-scavenge
```

These flags are not performance tuning; they are reliability workarounds.

## 5. Storage and execution history were constrained

The final n8n runtime was roughly 485 MB. It was placed under
`/var/local/n8n-runtime`, not the 1.4 GB root partition. User data lives under
`/var/local/n8n-data`.

Frequent polling workflows can fill the device with execution records. The
supplied launch script disables successful execution payloads, retains errors
for a short period, and enables built-in pruning. A separate SQLite pruning job
runs daily as an additional guard.

## 6. Optional networking work

Bonjour named the device `n8n.local`. `socat` launch services forwarded port 80
and terminated self-signed TLS on port 443 before proxying to port 5678.

A custom Tailscale 1.22.2 ARMv7 build was later created with TS2021 control
protocol changes backported from 1.24.2 because the old registration protocol
was retired. It also required IPv4-only behavior and certificate compatibility
work. That port is documented for historical completeness in
`TAILSCALE-README.md`, but it is deliberately excluded from the automatic base
installation: it is experimental, old, and should not be treated as a current
security boundary.

## 7. Verified running state

The live device inventory on November 23, 2026 reported:

```text
Node v12.19.0
npm 6.14.8
n8n 0.110.0
Python 3.7.1 (optional custom runtime)
/var/local/n8n-runtime
```

The server was supervised by `com.n8n.server`, listened on port 5678, and used
the single-threaded GC flags above. Later production tests showed that starting
a second n8n CLI process beside the server could exhaust memory and cause
launchd to restart the main service; normal scheduled runs stay inside the
single server process.
