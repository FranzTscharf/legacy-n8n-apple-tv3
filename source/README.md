# Rebuilding the custom Node binary

The ZIP already contains the tested binary in `payload/runtime/bin/node`. This
directory exists for auditability and rebuilding.

## Base source

Clone Node.js for Mobile Apps and check out the exact base commit:

```sh
git clone https://github.com/JaneaSystems/nodejs-mobile.git node12-mobile
git -C node12-mobile checkout 9d19d1e1710c87fa8f745b64b9ed00528df7842b
```

That release maps to Node 12.19.0. The project is historical and its original
maintainer states that it is no longer actively maintained.

## Host prerequisites

- macOS with Xcode and an iPhoneOS SDK that still accepts `armv7` output;
- GNU Make;
- a host Python 2.7.18 installation at `source/python2-host/bin/python2.7`;
- enough free space: the preserved full build tree reached roughly 23 GB.

The host Python build is not included because it is host-specific. Build it
from the official Python 2.7.18 source with a private prefix named
`source/python2-host`.

## Apply and build

From this directory:

```sh
chmod 755 apply-overrides.sh build-node12-armv7.sh toolchain/*
./apply-overrides.sh ./node12-mobile
./build-node12-armv7.sh
```

Expected output:

```text
node12-mobile/out/Release/node: Mach-O executable arm_v7
```

Inspect the minimum OS:

```sh
otool -l node12-mobile/out/Release/node | grep -A3 LC_VERSION_MIN_IPHONEOS
```

It should report iPhoneOS 8.0. Copy the binary to the device and sign it there:

```sh
ldid -S /var/local/n8n-runtime/bin/node
```

The override files are complete replacements relative to the base commit.
`apply-overrides.sh` refuses a different base commit so the files cannot be
silently applied to an incompatible source tree.
