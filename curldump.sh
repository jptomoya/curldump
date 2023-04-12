#!/bin/sh

usage() {
  echo "Usage: $0 <pcapng file> <curl options...>" 1>&2
  exit 1
}

if [ ! -f /.dockerenv ]; then
  echo "This script must be run in a Docker container." 1>&2
  exit 1
elif [ $# -lt 2 ]; then
  usage
fi

outfile=$1
dumpcap -q -w "$outfile" &
pid_tshark=$!
while :
do
  if (lsof | grep -E ^$pid_tshark | grep -q "$PWD"); then
    break
  fi
  sleep 0.1
done 
shift
SSLKEYLOGFILE="/tmp/sslkey.log" curl "$@" &
pid_curl=$!
wait $pid_curl

sleep 3	# HACK: wait for the dumpcap buffer to be filled
kill -INT $pid_tshark
wait $pid_tshark
editcap --inject-secrets tls,/tmp/sslkey.log "$outfile" "/work/$outfile"
