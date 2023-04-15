#!/bin/sh
set -eu

uid=$(stat -c '%u' .)
adduser -D -u "$uid" user
adduser user wireshark

exec su user -c "/curldump.sh $*"
