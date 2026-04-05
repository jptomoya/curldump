#!/bin/sh
set -eu

# Temporary workaround for trust stores missing the Comodo AAA root.
# Remove this once the upstream certificate chain issue is no longer relevant.
cert=/usr/share/ca-certificates/mozilla/Comodo_AAA_Services_root.crt
url=https://dl-cdn.alpinelinux.org/alpine/v3.18/main/x86_64/ca-certificates-20241121-r1.apk
dst=/usr/local/share/ca-certificates/Comodo_AAA_Services_root.crt

[ -e "$cert" ] && exit 0

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

apk="$tmpdir/ca-certificates.apk"
wget -q -O "$apk" "$url"
tar -xzf "$apk" -C "$tmpdir"
mkdir -p /usr/local/share/ca-certificates
cp "$tmpdir/usr/share/ca-certificates/mozilla/Comodo_AAA_Services_root.crt" "$dst"
update-ca-certificates
