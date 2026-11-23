# Tailscale on this device

This Apple TV 3,2 runs a custom ARMv7 build of the Tailscale daemon because
current official Apple TV releases require much newer tvOS hardware/software.

## Quick commands

```sh
tailscale-device status
tailscale-device login
tailscale-device reauth
tailscale-device netcheck
tailscale-device logs
```

`login` prints a device-specific `https://login.tailscale.com/a/...` URL. Open
that exact URL in a browser, sign in, and approve the device. Merely opening
the Machines page in the Tailscale admin console does not approve a pending
login request.

After approval, this command must show `Running` and one or more addresses:

```sh
tailscale-device status
```

Current addresses and n8n URLs:

- Tailscale IPv4: `TAILSCALE_IP`
- MagicDNS: `DEVICE_NAME.YOUR_TAILNET.ts.net`
- Dashboard: `http://TAILSCALE_IP/`
- Dashboard through MagicDNS: `http://DEVICE_NAME.YOUR_TAILNET.ts.net/`

The device is configured with `--accept-dns=false`. This old tvOS release
cannot install Tailscale DNS settings, but other tailnet devices can still
resolve its MagicDNS name normally.

## Login and reauthentication

Normal login:

```sh
tailscale-device login
```

Force a new authorization URL after a key expires or the device is removed:

```sh
tailscale-device reauth
```

An auth key can also be used, but entering it as an argument may save it in
shell history. Prefer an ephemeral, tagged, pre-authorized key and remove the
history entry afterward:

```sh
tailscale-device authkey tskey-auth-REPLACE_ME
```

## Service management

The daemon starts at boot through:

`/Library/LaunchDaemons/com.tailscale.tailscaled.plist`

Restart it with:

```sh
tailscale-device restart
```

Implementation paths:

- Daemon and CLI: `/var/local/tailscale/bin/`
- Persistent identity/state: `/var/local/tailscale/state/tailscaled.state`
- Socket: `/var/run/tailscale/tailscaled.sock`
- Main log: `/var/local/tailscale/tailscaled.log`
- Error log: `/var/local/tailscale/tailscaled-error.log`
- Tunnel interface: `utun0`

Do not delete `tailscaled.state` unless intentionally creating a new device
identity. Back it up securely; anyone obtaining it may be able to impersonate
this node until it is expired or removed from the tailnet.

## Compatibility and security

The installed client reports `1.22.2-date.20220107` and is a custom Go 1.14
ARMv7 build with the TS2021/Noise control protocol backported from Tailscale
1.24.2. The legacy Apple TV networking tools cannot configure Tailscale IPv6,
so this build intentionally installs only IPv4 tunnel addresses and routes.

This port is experimental and no longer covered by current Tailscale security
support. Keep it behind the LAN firewall, use restrictive tailnet grants/ACLs,
do not expose it as an exit node, and do not enable public internet ingress.
If the control plane eventually rejects this compatibility client, the
practical replacement is newer supported hardware or OS.

The `n8n` machine currently has key expiry disabled in the Tailscale console.
That keeps the device signed in until it is logged out, deleted, or its node
identity is otherwise revoked; no auth key can itself be valid forever.
