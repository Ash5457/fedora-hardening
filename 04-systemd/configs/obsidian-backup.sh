#!/usr/bin/env bash
set -euo pipefail
VAULT="$HOME/Documents/vault"   # change me
DEST="$HOME/Backups/obsidian"
tar --zstd -cf "$DEST/vault_$(date +%F_%H%M).tar.zst" -C "$(dirname "$VAULT")" "$(basename "$VAULT")"
ls -1t "$DEST"/vault_*.tar.zst | tail -n +15 | xargs -r rm --   # keep newest 14
echo "backup done: $(ls -1 "$DEST" | wc -l) kept"
