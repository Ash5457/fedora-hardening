#!/usr/bin/env bash
# usage: publish <00|01..08|final> "commit message"
# Copies a module from the vault to the public repo, re-redacts, scans, shows you
# exactly what will go up, then commits and pushes after you confirm.
set -euo pipefail
source "$HOME/.config/fedora-hardening.env"
mod="${1:-}"; msg="${2:-}"
[[ -n "$mod" && -n "$msg" ]] || { echo 'usage: publish <00|01-08|final> "commit message"'; exit 1; }
cd "$REPO_DIR"

case "$mod" in
  00)    paths=(.gitignore README.md scripts) ;;
  final) cp "$VAULT_DIR/REPO-README.md" README.md; paths=(README.md) ;;
  *)
    shopt -s nullglob; src=("$VAULT_DIR/$mod"-*/); shopt -u nullglob
    [[ ${#src[@]} -eq 1 ]] || { echo "No module folder for $mod in $VAULT_DIR"; exit 1; }
    name="$(basename "${src[0]}")"
    find "${src[0]}" -name '*.txt' -exec "$REPO_DIR/scripts/redact.sh" {} +
    rsync -a --delete "${src[0]}" "$REPO_DIR/$name/"
    paths=("$name" scripts)
    ;;
esac

report="$("$REPO_DIR/scripts/check-secrets.sh" "${paths[@]}")"
if [[ -n "$report" ]]; then
  printf '%s\n' "$report"
  read -rp "Possible private data above. Publish anyway? [y/N] " ok
  [[ "$ok" == [yY] ]] || { echo "Stopped. Nothing committed. Fix it in the vault copy and run publish again."; exit 1; }
fi

git add -A -- "${paths[@]}"
if git diff --cached --quiet; then echo "Nothing new to publish."; exit 0; fi
echo "--- going public:"; git status --short
echo "Screenshots cannot be scanned. Glance at any new .png above before confirming."
read -rp "Commit and push? [Y/n] " go
[[ "$go" != [nN] ]] || { git reset -q; echo "Cancelled. Nothing committed."; exit 1; }
git commit -q -m "$msg"
git push -q -u origin main
echo "Published $(git log -1 --format=%h): https://github.com/Ash5457/fedora-hardening"
