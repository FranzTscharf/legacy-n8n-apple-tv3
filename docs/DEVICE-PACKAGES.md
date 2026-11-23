# Compatible packages found on the working device

This inventory was captured from the working Apple TV 3,2 on November 23,
2026. It is a reference for rebuilding the base jailbroken environment; the
ready runtime in this ZIP does not require npm to compile anything on-device.

| Package | Installed version | Purpose |
|---|---:|---|
| curl | 7.33.0-9 | HTTP checks and downloads |
| git | 2.8.1-5 | Source checkout and maintenance |
| ldid | 1:1.2.1 | Ad-hoc signing of the custom Node executable |
| make | 3.81-2p | Build tooling |
| nano | 2.2.6-6 | On-device configuration editing |
| netatalk | 2.0.4-7 | Optional AFP file sharing |
| openssl | 0.9.8zg-13 | Legacy TLS tooling |
| python | 2.5.1-5p | Cydia base Python; not the optional Python 3 payload |
| rsync | 3.0.5-3 | File transfer and backup |
| ruby | 1.9.2-p0-10 | Legacy scripting dependency |
| socat | 1.7.1.1-3 | Optional local HTTP/HTTPS forwarding |
| tar | 1.29-10 | Archive extraction |
| unzip | 5.52-6 | ZIP extraction |
| wget | 1.16-4 | Downloads |

The essential prerequisites for the supplied installer are SSH, launchd,
`ldid`, `curl`, `sqlite3`, standard shell utilities, and at least 700 MB free
under `/var`. The working device also had the Cydia SQLite command-line tool;
its exact package version was not recorded in the preserved inventory. Package
names and availability depend on the repositories configured for the
jailbreak. Do not add Debian repositories: this is an
`iphoneos-arm`/Cydia system, not Debian Linux.

The optional Python 3.7.1 and experimental Tailscale binaries are already
preserved under `payload/optional/`; neither is required for the base n8n
service.
