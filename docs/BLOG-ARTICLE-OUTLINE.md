# Blog article outline

## Suggested title

**Running n8n on a 2013 Apple TV 3: a 32-bit ARMv7 preservation build**

## Suggested deck

How an old jailbroken Apple TV, an iOS cross-toolchain, a patched JITless Node
12 runtime, and aggressive memory safeguards became a small automation server.

## Narrative structure

1. **Start with the constraint, not the success.** The Apple TV 3 is a 32-bit
   ARMv7 iOS device with approximately 512 MB-class memory and a tiny root
   partition. It cannot use Docker, current Node packages, Debian binaries, or
   modern ARM64 iOS builds.
2. **The first wrong assumption.** The shell has APT, but it is Cydia's
   `iphoneos-arm` ecosystem—not Debian. Explain why adding normal Debian repos
   could brick package management.
3. **Why the repository route ended.** The discoverable iOS Node package
   required ARM64/iOS 15. Historic 0.4/0.6 ports ran on ARMv7 but could not run
   n8n.
4. **The build breakthrough.** A tiny ARMv7 test executable proved the Mac
   toolchain could produce code the Apple TV would execute. Node.js Mobile
   0.3.2 supplied a Node 12.19 base.
5. **Cross-compilation details.** Host Python 2.7, host/target compiler wrappers,
   iOS 8 minimum, ARMv7, JITless V8, no snapshots/inspector, 17 source
   overrides, and `ldid` signing.
6. **Native dependencies.** Cross-compile `sqlite3`, resolve n8n 0.110.0 on the
   Mac, and ship the known-good dependency tree instead of asking the Apple TV
   to compile or resolve npm packages.
7. **The bugs that only appeared as a daemon.** MobileSubstrate injection made
   launchd-started Node crash. `_MSSafeMode=1` fixed that difference.
8. **The bugs that appeared under UI load.** Background V8 GC was unstable while
   the editor loaded a large node catalog. Single-threaded GC flags traded
   speed for survival.
9. **Design for the filesystem.** Put the 485 MB runtime on `/var`, retain the
   database separately, and prune execution records aggressively.
10. **Networking without pretending it is modern.** Bonjour and a local proxy
    are convenient. The custom Tailscale backport is an interesting technical
    appendix, not a reason to expose unsupported software publicly.
11. **What actually worked.** n8n 0.110.0, Node 12.19.0, npm 6.14.8, SQLite,
    launchd restarts, real scheduled workflows, and multi-minute production
    exports.
12. **Honest conclusion.** This is a preservation and learning project. For
    production or internet-facing automation, use current supported hardware.

## Reproducibility box

Include these facts exactly:

```text
Hardware: Apple TV 3,2
OS: iPhone OS 8.4.4 / Darwin 14
Architecture: 32-bit ARMv7
Node: 12.19.0 (custom iOS/JITless build)
npm: 6.14.8
n8n: 0.110.0
Runtime path: /var/local/n8n-runtime
Data path: /var/local/n8n-data
```

Link readers to the ZIP's `README.md`, `SECURITY.md`,
`docs/BUILD-HISTORY.md`, and `source/README.md`. Do not publish the original
device IP, root password, tokens, certificates, databases, or Tailscale state.

## Screenshots worth adding

- `uname -a`, `sw_vers`, and `getconf LONG_BIT`.
- `file node` plus the iOS 8 minimum-load command.
- Successful `node --version`, `npm --version`, and `n8n --version`.
- launchd service list and an HTTP 200 health check.
- A workflow execution graph with private identifiers blurred.
- A small diagram: Mac cross-build → signed ARMv7 runtime → `/var/local` →
  launchd → n8n on port 5678.
