# Optional Python 3.7.1 port

Python is not required for n8n itself. It was later added so the custom Code
node could run Python transformations.

The original build used CPython 3.7.1, a host-side Python 3.7 interpreter for
cross-build generators, and the same ARMv7 iPhoneOS compiler wrappers as Node.
The standard configure script did not recognize `armv7-apple-darwin` as a
supported cross target, so the Darwin target case was added. Unsupported old
iOS functions were cached off, including `getentropy`, `getrandom`, and
`sendfile`; IPv6 and `ensurepip` were disabled. Modules required by the Code
node were linked into the target runtime.

The installed prefix is `/var/local/python3`. The bundle contains the exact
18 MB runtime copied from the working device and a guarded installer. It does
not contain the large temporary source/build tree, which was created under
`/tmp` and was not retained after deployment.

Verified version on the appliance: `Python 3.7.1`.
