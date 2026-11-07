#!/usr/bin/env bash
# Uses both apps the way your browser would through the SSH tunnel, from the
# host itself: Homepage's page and API, and Uptime Kuma's page and socket.io.
# CI runs it inside the host container:
#   podman exec -i circuit-mini-homelab bash -s < check.sh
# TITLE is the title the circuit was applied with; main.tf sets "My homelab".
set -euo pipefail
title=${TITLE:-My homelab}

# The apps take a while to answer after a first start or a restart, so each
# check gets a minute and a half before it counts as failed.
retry() {
  for _ in $(seq 45); do
    "$@" >/dev/null 2>&1 && return 0
    sleep 2
  done
  echo "Failed: $*" >&2
  "$@"
}

get() { curl -sSf --max-time 10 "http://127.0.0.1:$1$2"; }

# The Debian and Ubuntu test images come without curl.
command -v curl >/dev/null || if command -v apt-get >/dev/null; then
  apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get install -y -qq curl >/dev/null
else
  dnf -y -q install curl
fi

echo "The login message says what runs here."
for line in "$title, set up by Conn3x." "Homepage     http://127.0.0.1:3000" "Uptime Kuma  http://127.0.0.1:3001"; do
  grep -qF "$line" /etc/motd || { echo "/etc/motd lacks: $line" >&2; cat /etc/motd >&2; exit 1; }
done

echo "Homepage loads, titled, with the Apps and Links groups."
homepage_up() { get 3000 / | grep -q "<title[^>]*>$title</title>"; }
retry homepage_up
services=$(get 3000 /api/services)
for want in '"Apps"' '"Uptime Kuma"' '"Links"' '"Conn3x docs"' '"https://docs.conn3x.org"'; do
  grep -qF "$want" <<<"$services" || { echo "Homepage's services lack $want: $services" >&2; exit 1; }
done

# Homepage's status dot: it checks Uptime Kuma's port from the host.
kuma_dot() { get 3000 '/api/siteMonitor?groupName=Apps&serviceName=Uptime%20Kuma' | grep -q '"status":200'; }
retry kuma_dot

echo "Uptime Kuma answers, socket.io included, which its whole UI runs on."
kuma_up() { get 3001 /dashboard | grep -q '<title>Uptime Kuma'; }
retry kuma_up
get 3001 '/socket.io/?EIO=4&transport=polling' | grep -q '"sid"'

echo "All good."
