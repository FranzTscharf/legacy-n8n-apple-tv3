# Legacy n8n appliance for Apple TV 3

This bundle reproduces the working n8n installation built for an Apple TV 3,2
running jailbroken iPhone OS 8.4.4 (Darwin 14, 32-bit ARMv7).

## Hardware

![Apple TV 3 connected by Ethernet and HDMI](docs/images/apple-tv3-hardware.jpg)

*The Apple TV 3 used for the legacy n8n appliance, connected by Ethernet and HDMI.*

## n8n interface

![n8n 0.110.0 workflow editor running on the legacy Apple TV 3](docs/images/n8n-legacy-editor.png)

*The legacy n8n workflow editor running locally on the Apple TV 3.*

It contains a ready-to-install runtime, not just instructions:

- custom ARMv7/iOS 8 Node.js 12.19.0 binary;
- npm 6.14.8;
- n8n 0.110.0 with its resolved dependency tree;
- native ARMv7 `sqlite3` addon;
- launchd service and low-memory V8 settings;
- execution-history pruning for the small device;
- optional compatible community nodes;
- the patched source files and build toolchain wrappers needed to reproduce
  the Node binary;
- installation, verification, security, and blog-research notes.

No passwords, OAuth tokens, GitHub tokens, Tailscale identity files, n8n
credentials, databases, device/user private keys, or personal workflows are
included. Third-party packages may contain their upstream public example or
test strings.

## Supported target

Use this binary bundle only when all of these are true:

- `uname -a` contains `AppleTV3,2`;
- `sw_vers` reports iPhone OS 8.4.4 / build 12H1006 or a demonstrably
  compatible build;
- `getconf LONG_BIT` reports `32`;
- the device is jailbroken and has SSH, launchd, `ldid`, and at least 700 MB
  free under `/var`.

The installer refuses other hardware and 64-bit systems.

## Fast installation

1. Change the device's default root password before doing anything else:

   ```sh
   ssh -oHostKeyAlgorithms=+ssh-dss root@DEVICE_IP passwd
   ```

2. Unzip this bundle on a Mac. Copy the extracted directory to the device.
   The old SSH server may require legacy host-key negotiation and old-style
   SCP mode:

   ```sh
   scp -O -r -oHostKeyAlgorithms=+ssh-dss \
     legacy-n8n-apple-tv3 root@DEVICE_IP:/var/tmp/
   ```

3. Connect and run the installer:

   ```sh
   ssh -oHostKeyAlgorithms=+ssh-dss root@DEVICE_IP
   cd /var/tmp/legacy-n8n-apple-tv3
   chmod 755 install.sh verify.sh install-community-nodes.sh
   ./install.sh
   ./verify.sh
   ```

4. Open `http://DEVICE_IP:5678/`. The first start can take more than one
   minute while n8n scans its node catalog.

5. Optional: install the tested community-node set:

   ```sh
   ./install-community-nodes.sh
   ```

   This makes startup slower and increases memory use. Install it only if the
   included nodes are needed.

6. Optional Python 3.7.1 for the custom Code node:

   ```sh
   ./install-python3.sh
   ```

7. The ZIP also preserves the custom ARMv7 Tailscale binaries. They are not
   installed by default. Read `SECURITY.md` and `docs/TAILSCALE-README.md`; the
   guarded installer is `install-tailscale-experimental.sh`.

## Configuration

The first installation creates `/var/local/n8n-config/env.sh`. Edit it to
change the public host or webhook URL, then restart:

```sh
launchctl unload /Library/LaunchDaemons/com.n8n.server.plist
launchctl load /Library/LaunchDaemons/com.n8n.server.plist
```

The default webhook base is `http://n8n.local:5678/`. Change it only if you
install a separate trusted reverse proxy.

Important paths:

| Purpose | Path |
|---|---|
| Runtime | `/var/local/n8n-runtime` |
| Database and user data | `/var/local/n8n-data/.n8n` |
| Local configuration | `/var/local/n8n-config/env.sh` |
| Community nodes | `/var/local/n8n-community` |
| Service | `/Library/LaunchDaemons/com.n8n.server.plist` |
| Logs | `/var/local/n8n-data/n8n.log` and `n8n-error.log` |

The runtime is intentionally stored under `/var`: the root filesystem is only
about 1.4 GB, while the data partition has materially more room.

## Before importing workflows

- Create credentials again in the new n8n instance. Never copy secrets from
  another user's database.
- Back up `/var/local/n8n-data` after initial setup and before changes.
- Keep execution history short. The supplied service saves failures, skips
  successful execution payloads, and runs an additional pruning job.
- Do not start a second n8n CLI process while the server is running. On this
  512 MB-class device, loading two n8n processes can trigger memory pressure
  and a launchd restart.

Read [SECURITY.md](SECURITY.md) before exposing the service to any network.
The technical reconstruction is in [docs/BUILD-HISTORY.md](docs/BUILD-HISTORY.md),
the compatible device packages are catalogued in
[docs/DEVICE-PACKAGES.md](docs/DEVICE-PACKAGES.md), and a blog-ready outline is
in [docs/BLOG-ARTICLE-OUTLINE.md](docs/BLOG-ARTICLE-OUTLINE.md).
