#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
GNOME_DIR="$REPO_ROOT/desktop/gnome"
WORKDIR="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles-theme"

ICON_REPO="https://github.com/vinceliuice/MacTahoe-icon-theme.git"
GTK_REPO="https://github.com/vinceliuice/MacTahoe-gtk-theme.git"

GTK_THEME="MacTahoe-Dark-solid-green"
ICON_THEME="MacTahoe-dark"
CURSOR_THEME="MacTahoe"
SHELL_THEME="MacTahoe-Dark-solid-green"

echo "==> Installing required packages"
sudo apt update
sudo apt install -y \
  git curl wget \
  dconf-cli \
  gnome-shell-extensions \
  gnome-tweaks \
  sassc libglib2.0-dev-bin imagemagick

echo "==> Preparing workspace"
rm -rf "$WORKDIR"
mkdir -p "$WORKDIR"

echo "==> Cloning MacTahoe icon theme"
git clone --depth 1 "$ICON_REPO" "$WORKDIR/MacTahoe-icon-theme"

echo "==> Installing MacTahoe icon theme"
cd "$WORKDIR/MacTahoe-icon-theme"
./install.sh

echo "==> Cloning MacTahoe GTK theme"
git clone --depth 1 "$GTK_REPO" "$WORKDIR/MacTahoe-gtk-theme"

echo "==> Installing MacTahoe GTK theme"
cd "$WORKDIR/MacTahoe-gtk-theme"
./install.sh

echo "==> Creating target directories"
mkdir -p "$HOME/.local/share/gnome-shell/extensions"

echo "==> Restoring user-installed extensions"
if [ -d "$GNOME_DIR/extensions" ]; then
  shopt -s nullglob
  for ext in "$GNOME_DIR/extensions"/*; do
    base="$(basename "$ext")"
    [ "$base" = "list.txt" ] && continue
    [ -d "$ext" ] || continue
    rm -rf "$HOME/.local/share/gnome-shell/extensions/$base"
    cp -r "$ext" "$HOME/.local/share/gnome-shell/extensions/"
  done
  shopt -u nullglob
fi

echo "==> Restoring dconf"
dconf load / < "$GNOME_DIR/dconf/user.conf"

echo "==> Applying GTK/Icon/Cursor theme explicitly"
gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME" || true
gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME" || true
gsettings set org.gnome.desktop.interface cursor-theme "$CURSOR_THEME" || true

echo "==> Enabling User Themes extension"
gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com 2>/dev/null || true

echo "==> Applying GNOME Shell theme if schema exists"
if gsettings writable org.gnome.shell.extensions.user-theme name >/dev/null 2>&1; then
  gsettings set org.gnome.shell.extensions.user-theme name "$SHELL_THEME" || true
fi

echo
echo "==> Restore complete"
echo "Recommended: logout/login once to fully apply GNOME Shell settings."
