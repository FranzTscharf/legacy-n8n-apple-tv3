# n8n Apple TV device guide

## Device summary

- Hardware: Apple TV 3,2 (ARMv7)
- OS kernel: Darwin 14 / iPhone OS 8.4.4 generation
- Hostname: `n8n`
- LAN address at installation: `DEVICE_LAN_IP`
- Bonjour name: `n8n.local`
- SSH account: `root`

Change the default `alpine` root password with `passwd` if this has not already
been done. The AFP root share and SSH account provide administrative access.

## n8n

- Dashboard: `http://n8n.local/`
- Direct backend: `http://n8n.local:5678/`
- HTTPS proxy: `https://n8n.local/` (locally generated certificate)
- Version: n8n 0.110.0 on Node.js 12.19.0
- Runtime: `/var/local/n8n-runtime`
- User data/database: `/var/local/n8n-data`
- Community nodes: `/var/local/n8n-community/extensions`
- Startup script: `/var/local/n8n-runtime/bin/n8n-start`
- Service: `/Library/LaunchDaemons/com.n8n.server.plist`
- Logs: `/var/local/n8n-data/n8n.log` and `n8n-error.log`

Restart n8n:

```sh
launchctl unload /Library/LaunchDaemons/com.n8n.server.plist
launchctl load /Library/LaunchDaemons/com.n8n.server.plist
```

The first start can take more than a minute while the old CPU scans community
nodes. Confirm readiness with:

```sh
curl --connect-timeout 3 --max-time 10 -I http://127.0.0.1:5678/
```

The Node/V8 flags in `n8n-start` are intentional stability workarounds for the
legacy ARMv7 platform. Do not remove them casually.

## HTTP and HTTPS forwarding

Port 80 and port 443 are forwarded to the n8n backend on port 5678 by `socat`:

- `/Library/LaunchDaemons/com.n8n.proxy.http.plist`
- `/Library/LaunchDaemons/com.n8n.proxy.https.plist`
- TLS files: `/var/local/n8n-proxy/`

The HTTPS certificate is local/self-signed, so browsers may not trust it until
its certificate is installed or explicitly trusted.

## Bonjour and Finder file access

Bonjour advertises the AFP service as `n8n Root Files`. In Finder use:

```text
afp://n8n.local
```

The share exposes `/` as `Root`, permits the `root` user, and is currently
limited to LAN clients in `192.168.1.0/24`. Configuration:

- `/etc/netatalk/AppleVolumes.default`
- `/Library/LaunchDaemons/com.n8n.afpd.plist`
- `/Library/LaunchDaemons/com.n8n.afpd.bonjour.plist`

This is highly privileged access. Do not forward AFP to the internet or expose
it through broad Tailscale grants.

## Tailscale

See `/var/local/tailscale/README.md`. Common commands:

```sh
tailscale-device status
tailscale-device login
tailscale-device reauth
```

The working remote dashboard endpoints are:

- `http://TAILSCALE_IP/`
- `http://DEVICE_NAME.YOUR_TAILNET.ts.net/`

The custom client is `1.22.2-date.20220107` with TS2021 control support. It
starts automatically through launchd, uses IPv4 on this legacy tvOS release,
and has device key expiry disabled in the Tailscale admin console.

## Python and custom code

- Python 3.7.1: `/var/local/python3`
- Convenience command: `/usr/local/bin/python3`
- The custom n8n Code node supports JavaScript and Python transformations.

Python 3.7, Node.js 12, and n8n 0.110 are end-of-life. Treat workflows and
community packages as trusted code and avoid installing arbitrary packages.

## Backup

The most important paths are:

```text
/var/local/n8n-data
/var/local/n8n-community
/var/local/tailscale/state/tailscaled.state
/Library/LaunchDaemons/com.n8n.*.plist
/Library/LaunchDaemons/com.tailscale.tailscaled.plist
/etc/netatalk/AppleVolumes.default
```

Stop n8n before copying its database to get a consistent backup. Protect the
Tailscale state file like a credential.

## Health checks

```sh
launchctl list | grep -E 'n8n|tailscale'
curl --connect-timeout 3 --max-time 10 -I http://127.0.0.1:5678/
tailscale-device status
df -h / /var
tail -100 /var/local/n8n-data/n8n-error.log
tail -100 /var/local/tailscale/tailscaled-error.log
```

At the time this guide was written, `/private/var` had about 4.6 GB free. Keep
large runtimes, logs, and backups under `/var`, not the 1.4 GB root filesystem.
