#!/usr/bin/env bash
# usage: check-secrets.sh <path>...   prints suspicious lines and files; nothing if clean
set -uo pipefail
source "$HOME/.config/fedora-hardening.env" 2>/dev/null || true
[[ $# -gt 0 ]] || set -- .
host="$(hostname -s)"
patterns=(
  '([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}'
  '\b10\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\b'
  '\b192\.168\.[0-9]{1,3}\.[0-9]{1,3}\b'
  '\b172\.(1[6-9]|2[0-9]|3[01])\.[0-9]{1,3}\.[0-9]{1,3}\b'
  '\b100\.(6[4-9]|[7-9][0-9]|1[01][0-9]|12[0-7])\.[0-9]{1,3}\.[0-9]{1,3}\b'
  'fd7a:115c:a1e0:'
  '\$(y|6|5|2b)\$[^ :]{20,}'
  'PRIVATE KEY'
  'tskey-'
)
case "$host" in fedora|localhost*) ;; *) patterns+=("\\b${host}\\b") ;; esac
[[ -n "${EXTRA_REDACT:-}" ]] && patterns+=("$EXTRA_REDACT")
for p in "${patterns[@]}"; do
  grep -rInE --exclude-dir=.git --exclude=check-secrets.sh --exclude=redact.sh -- "$p" "$@" 2>/dev/null
done
find "$@" \( -iname '*.img' -o -iname '*luks*header*' -o -iname 'luksdump-full*' \) -print 2>/dev/null
exit 0
