# Security and support warning

This is a preservation/experimental build. It combines end-of-life software:

- iPhone OS 8.4.4;
- Node.js 12.19.0;
- npm 6.14.8;
- n8n 0.110.0;
- optional historical community packages.

It does not receive current security fixes. Do not publish port 5678, port 80,
SSH, AFP, or the editor directly to the public internet.

Minimum precautions:

1. Replace the default `root` password `alpine` immediately.
2. Restrict the device to a trusted LAN/VLAN and firewall it from untrusted
   clients.
3. If remote access is required, use a current, supported VPN gateway on
   another device. The historical custom Tailscale port described in the
   research notes is not part of the base installer and is not a modern
   security boundary.
4. Treat every workflow and community node as executable code.
5. Use least-privilege API credentials and rotate anything ever pasted into a
   terminal or chat.
6. Back up `/var/local/n8n-data` offline. It contains encrypted credentials;
   protect both the database and n8n's local encryption material.
7. Do not reuse the bundled examples with real repository/account identifiers
   until every placeholder and permission has been reviewed.

The ZIP intentionally excludes all device identities, device/user
certificates and private keys, databases, workflow credentials, access tokens,
and shell history. Third-party package source may contain upstream public
example or test strings; these are not credentials copied from the device.
