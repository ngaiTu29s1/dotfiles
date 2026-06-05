#!/usr/bin/env bash
# ==============================================================================
# 📂 Backup & Symlink Script
# Moves active system config files into dotfiles repo and creates symlinks back.
# ==============================================================================

set -euo pipefail

# --- Colors ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo -e "${BLUE}🔍 Starting backup and symlink migration...${NC}"
echo -e "Repository root: ${GREEN}${REPO_ROOT}${NC}"
echo

# Helper function to migrate a file
# Arguments:
#   $1: Path to the active config file (e.g. ~/.bashrc)
#   $2: Path relative to repo root (e.g. bash/.bashrc)
migrate_file() {
  local active_path="${1/#\~/$HOME}" # Expand tilde if present
  local repo_rel_path="$2"
  local repo_path="$REPO_ROOT/$repo_rel_path"

  # 1. Check if active config file exists
  if [ ! -e "$active_path" ] && [ ! -L "$active_path" ]; then
    echo -e "${YELLOW}ℹ Skipping: $active_path (does not exist)${NC}"
    return 0
  fi

  # 2. Check if already symlinked
  if [ -L "$active_path" ]; then
    local dest
    dest="$(readlink -f "$active_path")"
    if [ "$dest" = "$repo_path" ]; then
      echo -e "${GREEN}✓ Already managed: $active_path -> $repo_rel_path${NC}"
      return 0
    fi
  fi

  echo -e "📦 Migrating ${BLUE}$active_path${NC} to ${GREEN}$repo_rel_path${NC}..."

  # 3. Create target directory in repo
  local repo_dir
  repo_dir="$(dirname "$repo_path")"
  mkdir -p "$repo_dir"

  # 4. Remove empty placeholders or old files in repo if they exist and are different
  if [ -f "$repo_path" ]; then
    # If it is empty (like bash/.bashrc placeholder), remove it
    if [ ! -s "$repo_path" ]; then
      rm -f "$repo_path"
    else
      # Backup the existing repo file just in case
      mv "$repo_path" "${repo_path}.bak"
      echo -e "${YELLOW}⚠️  Existing file in repo renamed to ${repo_rel_path}.bak${NC}"
    fi
  fi

  # 5. Move active file to repo
  mv "$active_path" "$repo_path"

  # 6. Create symlink pointing to repo
  mkdir -p "$(dirname "$active_path")"
  ln -sf "$repo_path" "$active_path"
  echo -e "${GREEN}✓ Done: $active_path linked to $repo_rel_path${NC}"
}

# --- Define migrations ---
# Format: migrate_file "<active_path>" "<repo_relative_path>"

# 1. Shell profiles
migrate_file "~/.bashrc" "bash/.bashrc"
migrate_file "~/.profile" "bash/.profile"

# 2. MangoHud
migrate_file "~/.config/MangoHud/MangoHud.conf" "mangohud/MangoHud.conf"

# 3. Tiling Assistant
migrate_file "~/.config/tiling-assistant/layouts.json" "tiling-assistant/layouts.json"
migrate_file "~/.config/tiling-assistant/tiledSessionRestore.json" "tiling-assistant/tiledSessionRestore.json"

# 4. VS Code
migrate_file "~/.config/Code/User/settings.json" "vscode/settings.json"

# 5. Fish conf
migrate_file "~/.config/fish/conf.d/uv.env.fish" "fish/conf.d/uv.env.fish"

# 6. GTK Bookmarks
migrate_file "~/.config/gtk-3.0/bookmarks" "gtk/bookmarks"

# 7. Ulauncher configurations (excluding cache/database files)
migrate_file "~/.config/ulauncher/settings.json" "ulauncher/settings.json"
migrate_file "~/.config/ulauncher/shortcuts.json" "ulauncher/shortcuts.json"
migrate_file "~/.config/ulauncher/extensions.json" "ulauncher/extensions.json"

# 8. Htop configuration
migrate_file "~/.config/htop/htoprc" "htop/htoprc"

# 9. FSearch configuration
migrate_file "~/.config/fsearch/fsearch.conf" "fsearch/fsearch.conf"

# 10. Autostart applications
migrate_file "~/.config/autostart/ulauncher.desktop" "autostart/ulauncher.desktop"
migrate_file "~/.config/autostart/win11-clipboard-history.desktop" "autostart/win11-clipboard-history.desktop"

echo
echo -e "${GREEN}🎉 All backups and symlinks processed successfully!${NC}"
