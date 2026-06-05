#!/usr/bin/env bash
# ==============================================================================
# 🚀 MacOS Tahoe Desktop customization - All-in-One Setup Script
# Emulates the macOS Tahoe style UI on Ubuntu GNOME.
# ==============================================================================

set -euo pipefail

# --- Color & Style Variables ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

echo -e "${CYAN}${BOLD}========================================================"
echo -e "🍏  Welcome to macOS Tahoe Customization Installer  🍏"
echo -e "========================================================${NC}"
echo

# 1. Acquire sudo privileges early
echo -e "${YELLOW}🔒 Requiring sudo privileges to install packages...${NC}"
sudo -v
# Keep-alive sudo until script finishes
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKDIR="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles-theme"
GNOME_DIR="$REPO_ROOT/desktop/gnome"

# Theme Configuration
GTK_THEME="MacTahoe-Dark-solid-green"
ICON_THEME="MacTahoe-dark"
CURSOR_THEME="MacTahoe"
SHELL_THEME="MacTahoe-Dark-solid-green"

# 2. Install required packages
echo -e "${BLUE}📦 [1/7] Installing system dependencies...${NC}"
sudo apt update
sudo apt install -y \
  git curl wget \
  dconf-cli \
  gnome-shell-extensions \
  gnome-shell-extension-manager \
  gnome-tweaks \
  sassc libglib2.0-dev-bin imagemagick \
  x11-xserver-utils

# 3. Setup Ulauncher and Liquid Glass theme
echo -e "${BLUE}📦 [2/7] Installing Ulauncher & applying theme...${NC}"
if ! command -v ulauncher >/dev/null 2>&1; then
  echo -e "${YELLOW}Adding Ulauncher PPA...${NC}"
  sudo add-apt-repository ppa:agornostal/ulauncher -y
  sudo apt update
  sudo apt install -y ulauncher
fi

# Run Ulauncher theme installer
if [ -f "$REPO_ROOT/ulauncher-liquid-glass/install.sh" ]; then
  chmod +x "$REPO_ROOT/ulauncher-liquid-glass/install.sh"
  "$REPO_ROOT/ulauncher-liquid-glass/install.sh"
fi

# 4. Clone and install macOS Tahoe GTK and Icon Themes
echo -e "${BLUE}📦 [3/7] Downloading and installing MacTahoe Themes...${NC}"
mkdir -p "$WORKDIR"

ICON_REPO="https://github.com/vinceliuice/MacTahoe-icon-theme.git"
GTK_REPO="https://github.com/vinceliuice/MacTahoe-gtk-theme.git"

# Install Icon theme
if [ ! -d "$WORKDIR/MacTahoe-icon-theme/.git" ]; then
  echo -e "${CYAN}Cloning MacTahoe icon theme...${NC}"
  git clone --depth 1 "$ICON_REPO" "$WORKDIR/MacTahoe-icon-theme"
fi
echo -e "${CYAN}Installing MacTahoe icons...${NC}"
cd "$WORKDIR/MacTahoe-icon-theme"
./install.sh

# Install GTK theme
if [ ! -d "$WORKDIR/MacTahoe-gtk-theme/.git" ]; then
  echo -e "${CYAN}Cloning MacTahoe GTK theme...${NC}"
  git clone --depth 1 "$GTK_REPO" "$WORKDIR/MacTahoe-gtk-theme"
fi
echo -e "${CYAN}Installing MacTahoe GTK layout (Libadwaita + Blur)...${NC}"
cd "$WORKDIR/MacTahoe-gtk-theme"
# -l for libadwaita support, -b for blur support
./install.sh -l -b

# Install Wallpapers to system folder
echo -e "${CYAN}Installing macOS Tahoe wallpapers...${NC}"
sudo mkdir -p /usr/share/backgrounds/MacTahoe
sudo cp -r "$WORKDIR/MacTahoe-gtk-theme/wallpaper/"* /usr/share/backgrounds/MacTahoe/ 2>/dev/null || true

# Return to repo root
cd "$REPO_ROOT"

# 5. Restore GNOME Extensions
echo -e "${BLUE}📦 [4/7] Restoring GNOME extensions from repository...${NC}"
EXT_DEST="$HOME/.local/share/gnome-shell/extensions"
mkdir -p "$EXT_DEST"

# Copy extensions to local user extensions dir
if [ -d "$GNOME_DIR/extensions" ]; then
  shopt -s nullglob
  for ext in "$GNOME_DIR/extensions"/*; do
    [ -d "$ext" ] || continue
    uuid="$(basename "$ext")"
    echo -e "Restoring extension: ${CYAN}${uuid}${NC}"
    rm -rf "$EXT_DEST/$uuid"
    cp -r "$ext" "$EXT_DEST/"
  done
  shopt -u nullglob
fi

# 6. Apply settings using dconf
echo -e "${BLUE}📦 [5/7] Importing dconf configuration...${NC}"
if [ -f "$GNOME_DIR/dconf/user.conf" ]; then
  dconf load / < "$GNOME_DIR/dconf/user.conf"
  echo -e "${GREEN}✓ dconf configuration loaded successfully.${NC}"
else
  echo -e "${RED}⚠️  No dconf backup file found at $GNOME_DIR/dconf/user.conf${NC}"
fi

# 7. Explicitly enable themes & wallpaper settings
echo -e "${BLUE}📦 [6/7] Applying specific theme values & wallpaper...${NC}"
gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME" || true
gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME" || true
gsettings set org.gnome.desktop.interface cursor-theme "$CURSOR_THEME" || true

# Enable User Themes extension
gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com 2>/dev/null || true

# Apply shell theme
if gsettings writable org.gnome.shell.extensions.user-theme name >/dev/null 2>&1; then
  gsettings set org.gnome.shell.extensions.user-theme name "$SHELL_THEME" || true
fi

# Restore window buttons layout
gsettings set org.gnome.desktop.wm.preferences button-layout ':minimize,maximize,close'

# Apply official wallpapers to desktop
gsettings set org.gnome.desktop.background picture-uri 'file:///usr/share/backgrounds/MacTahoe/MacTahoe-day.jpeg' || true
gsettings set org.gnome.desktop.background picture-uri-dark 'file:///usr/share/backgrounds/MacTahoe/MacTahoe-night.jpeg' || true

# Enable all extensions from list.txt
if [ -f "$GNOME_DIR/extensions/list.txt" ]; then
  echo -e "${BLUE}📦 [7/7] Enabling extensions...${NC}"
  while IFS= read -r uuid || [ -n "$uuid" ]; do
    [ -z "$uuid" ] && continue
    echo -e "Enabling extension: ${CYAN}$uuid${NC}"
    gnome-extensions enable "$uuid" 2>/dev/null || true
  done < "$GNOME_DIR/extensions/list.txt"
fi

echo
echo -e "${GREEN}${BOLD}🎉 Installation complete!${NC}"
echo -e "${YELLOW}💡 Please log out and log back in to fully apply the theme, extensions, and settings.${NC}"
echo -e "${YELLOW}💡 Open Ulauncher Preferences (Ctrl+Space) to choose the Liquid Glass theme.${NC}"
