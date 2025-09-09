#!/bin/sh

[ -z "${1}" ] && {
  printf '{"error":"Missing IP (pass IP as first arg)"}\n' >&2
  exit 1
}

count=0

until [ "$count" -ge 30 ]; do
  token=$(
    ssh \
      -o "UserKnownHostsFile=/dev/null" \
      -o "StrictHostKeyChecking=no" \
      "${1}" \
      'sudo -u rootless sh -c "journalctl --user -u pangolin_app_1 -n 300"' | \
    awk -F'Token: ' '/Token:/ {print $2}' | \
    tail -n1)
  
  [ -n "$token" ] && {
    printf '{"token":"%s"}\n' "$token"
    exit 0
  }

  count=$((count + 1))
  sleep 10
done

printf '{"error":"Token not found"}\n'
exit 1
