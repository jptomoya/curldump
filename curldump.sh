#!/bin/sh
set -eu

usage() {
  echo "Usage: $0 <curl options...>" 1>&2
  exit 1
}

wait_until_tcp_fin_wait_dismissed() {
  while ss -t -n | grep -F -q 'FIN-WAIT'
  do
    sleep 0.1
  done
}

if [ ! -f /.dockerenv ]; then
  echo "Note: This script is intended to run within a Docker container." 1>&2
  echo "The resulting capture file may contain packets unrelated to the curl command." 1>&2
fi
if [ $# -lt 1 ]; then
  usage
fi

cap_file="$(mktemp -u curldump_XXXXXX)"".pcapng"
dumpcap -q -p -w "/tmp/$cap_file" &
pid_dumpcap=$!
while :
do
  if [ ! -d /proc/$pid_dumpcap ]; then
    echo "Error: dumpcap command exited before creating capture file." 1>&2
    exit 1
  fi
  if [ -e "/tmp/$cap_file" ]; then
    break
  fi
  sleep 0.1
done 
sslkeylog_file="$(mktemp -u sslkeylog_XXXXXX)"
SSLKEYLOGFILE="/tmp/$sslkeylog_file" curl "$@" &
pid_curl=$!
wait $pid_curl
wait_until_tcp_fin_wait_dismissed
base_cap_size=$(stat -c '%s' "/tmp/$cap_file")
timeout 10 sh -c "
while :
do
  cap_size=\$(stat -c '%s' \"/tmp/$cap_file\")
  if [ \"\$cap_size\" -ne $base_cap_size ]; then
    break
  fi
  sleep 0.1
done"
kill -INT $pid_dumpcap
wait $pid_dumpcap
editcap --inject-secrets tls,"/tmp/$sslkeylog_file" "/tmp/$cap_file" "${OUTFILE:-$cap_file}"
