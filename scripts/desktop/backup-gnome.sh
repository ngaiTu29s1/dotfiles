#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
GNOME_DIR="$REPO_ROOT/desktop/gnome"

mkdir -p "$GNOME_DIR/dconf" "$GNOME_DIR/extensions"

echo "==> Cleaning old extension backup"
find "$GNOME_DIR/extensions" -mindepth 1 -maxdepth 1 ! -name 'list.txt' -exec rm -rf {} + 2>/dev/null || true

echo "==> Backing up dconf"
dconf dump / > "$GNOME_DIR/dconf/user.conf"

echo "==> Backing up extension UUID list"
gnome-extensions list > "$GNOME_DIR/extensions/list.txt"

echo "==> Backing up user-installed extensions only"
EXT_SRC="$HOME/.local/share/gnome-shell/extensions"
if [ -d "$EXT_SRC" ]; then
  shopt -s nullglob
  for ext in "$EXT_SRC"/*; do
    [ -d "$ext" ] || continue
    cp -r "$ext" "$GNOME_DIR/extensions/"
  done
  shopt -u nullglob
fi

echo "==> Done"
