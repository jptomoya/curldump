#!/bin/sh
set -eu

uid=$(ls -an | grep -E " \.$" | awk '{print $3}')
adduser -D -u "$uid" user
adduser user wireshark

exec su user -c "/curldump.sh $*"
