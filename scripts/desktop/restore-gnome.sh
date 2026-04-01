#!/usr/bin/env bash
set -euo pipefail
sudo -v

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
  gnome-shell-extension-manager \
  gnome-tweaks \
  sassc libglib2.0-dev-bin imagemagick

echo "==> Preparing workspace"
mkdir -p "$WORKDIR"

if [ ! -d "$WORKDIR/MacTahoe-icon-theme/.git" ]; then
  echo "==> Cloning MacTahoe icon theme"
  git clone --depth 1 "$ICON_REPO" "$WORKDIR/MacTahoe-icon-theme"
else
  echo "==> Icon theme repo exists, skipping clone"
fi

if [ ! -d "$HOME/.icons/$ICON_THEME" ] && [ ! -d "$HOME/.local/share/icons/$ICON_THEME" ] && [ ! -d "/usr/share/icons/$ICON_THEME" ]; then
  echo "==> Installing MacTahoe icon theme"
  cd "$WORKDIR/MacTahoe-icon-theme"
  ./install.sh
else
  echo "==> Icon theme already installed, skipping"
fi

if [ ! -d "$WORKDIR/MacTahoe-gtk-theme/.git" ]; then
  echo "==> Cloning MacTahoe GTK theme"
  git clone --depth 1 "$GTK_REPO" "$WORKDIR/MacTahoe-gtk-theme"
else
  echo "==> GTK theme repo exists, skipping clone"
fi

if [ ! -d "$HOME/.themes/$GTK_THEME" ] && [ ! -d "$HOME/.local/share/themes/$GTK_THEME" ] && [ ! -d "/usr/share/themes/$GTK_THEME" ]; then
  echo "==> Installing MacTahoe GTK theme"
  cd "$WORKDIR/MacTahoe-gtk-theme"
  ./install.sh
else
  echo "==> GTK theme already installed, skipping"
fi

echo "==> Restoring dconf"
dconf load / < "$GNOME_DIR/dconf/user.conf"

echo "==> Applying GTK/Icon/Cursor theme explicitly"
gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME" || true
gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME" || true
gsettings set org.gnome.desktop.interface cursor-theme "$CURSOR_THEME" || true

echo "==> Enabling User Themes"
gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com 2>/dev/null || true

echo "==> Applying shell theme if schema exists"
if gsettings writable org.gnome.shell.extensions.user-theme name >/dev/null 2>&1; then
  gsettings set org.gnome.shell.extensions.user-theme name "$SHELL_THEME" || true
fi

echo "==> Restoring right-side window buttons"
gsettings set org.gnome.desktop.wm.preferences button-layout ':minimize,maximize,close'

echo
echo "==> Done. Logout/login once."
