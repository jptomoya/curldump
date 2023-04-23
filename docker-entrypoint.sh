#!/bin/sh
set -eu

uid=$(stat -c '%u' .)
su_user="user"

if ! cut -d: -f3 /etc/passwd | grep -x -q "$uid"; then
  adduser -D -u "$uid" $su_user
else
  su_user=$(awk -F: "\$3==$uid {print \$1}" /etc/passwd)
fi
adduser "$su_user" wireshark

exec su -s /bin/sh "$su_user" -c "/curldump.sh $*"
