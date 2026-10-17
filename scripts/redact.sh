#!/usr/bin/env bash
# redact.sh            filter: stdin to stdout (unbuffered, safe for live output)
# redact.sh FILE...    edit files in place
set -euo pipefail
source "$HOME/.config/fedora-hardening.env" 2>/dev/null || true
host="$(hostname -s)"
args=(-E
  -e 's/([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}/XX:XX:XX:XX:XX:XX/g'
  -e 's/\b10\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\b/<private-ip>/g'
  -e 's/\b192\.168\.[0-9]{1,3}\.[0-9]{1,3}\b/<private-ip>/g'
  -e 's/\b172\.(1[6-9]|2[0-9]|3[01])\.[0-9]{1,3}\.[0-9]{1,3}\b/<private-ip>/g'
  -e 's/\b100\.(6[4-9]|[7-9][0-9]|1[01][0-9]|12[0-7])\.[0-9]{1,3}\.[0-9]{1,3}\b/<tailnet-ip>/g'
  -e 's/\bfd7a:115c:a1e0:[0-9a-fA-F:]+/<tailnet-ipv6>/g'
  -e 's/\bfe80::[0-9a-fA-F:]+/<link-local-ipv6>/g'
)
# A generic hostname like "fedora" would wreck repo names in the output, so skip it.
case "$host" in fedora|localhost*) ;; *) args+=(-e "s/\\b${host}\\b/<hostname>/g") ;; esac
[[ -n "${EXTRA_REDACT:-}" ]] && args+=(-e "s/(${EXTRA_REDACT})/<redacted>/g")
if [[ $# -eq 0 ]]; then sed -u "${args[@]}"; else sed -i "${args[@]}" "$@"; fi
