# Loaded from ~/.bashrc. Provides: lab, cap, shot, publish.
source "$HOME/.config/fedora-hardening.env"

# lab 01   jump to that module's folder in the vault
lab() {
  local -a d
  shopt -s nullglob; d=("$VAULT_DIR/$1"-*/); shopt -u nullglob
  [[ ${#d[@]} -eq 1 ]] || { echo "usage: lab <01-08>"; return 1; }
  cd "${d[0]}" && echo "== $(basename "$PWD") =="
}

# cap outputs/x.txt <command...>   run, show, and save. Redacted before it touches the disk.
# For pipes, wrap in bash -c:  cap outputs/x.txt bash -c 'ss -tulpn | grep LISTEN'
cap() {
  local out="$1"; shift
  mkdir -p "$(dirname "$out")"
  { printf '$ %s\n# captured %s\n\n' "$*" "$(date -Is)"; "$@" 2>&1; } \
    | "$REPO_DIR/scripts/redact.sh" | tee "$out"
}

# shot 01-lsblk   drag a box; saved as screenshots/01-lsblk.png in the current module
shot() {
  local name="${1#screenshots/}"; name="${name%.png}"
  mkdir -p screenshots
  grim -g "$(slurp)" "screenshots/$name.png" && echo "saved screenshots/$name.png"
}

publish() { "$REPO_DIR/scripts/publish.sh" "$@"; }
