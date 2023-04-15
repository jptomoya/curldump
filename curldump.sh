#!/bin/sh
set -eu

usage() {
  echo "Usage: $0 <curl options...>" 1>&2
  exit 1
}

if [ ! -f /.dockerenv ]; then
  echo "Note: This script is intended to run within a Docker container." 1>&2
  echo "The resulting capture file may contain packets unrelated to the curl command." 1>&2
fi
if [ $# -lt 1 ]; then
  usage
fi

dumpcap -q &
pid_dumpcap=$!
while :
do
  capfile=$(lsof 2> /dev/null | grep -E "\<$pid_dumpcap\>" | grep -o -E "[^[:space:]]+\.pcapng$") && :
  if [ -n "$capfile" ]; then
    break
  fi
  if [ ! -d /proc/$pid_dumpcap ]; then
    echo "Error: dumpcap command exited before creating capture file." 1>&2
    exit 1
  fi
  sleep 0.1
done 
SSLKEYLOGFILE="/tmp/sslkey.log" curl "$@" &
pid_curl=$!
wait $pid_curl

sleep 3	# HACK: wait for the dumpcap buffer to be filled
kill -INT $pid_dumpcap
wait $pid_dumpcap
editcap --inject-secrets tls,/tmp/sslkey.log "$capfile" "${OUTFILE:-capture.pcapng}"
