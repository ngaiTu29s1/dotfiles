#!/bin/bash

# Di chuyển vào đúng thư mục chứa script
cd "$(dirname "$0")" || exit 1

# Danh sách service: key = tên file, value = slug trên simpleicons.org
declare -A services=(
  ["portainer"]="portainer"
  ["netdata"]="netdata"
  ["uptime-kuma"]="uptimekuma"  
  ["homer"]="homeassistant"  
  ["linkding"]="pinboard"
  ["adguard"]="adguard"
)

echo "📥 Fetching logos into $(pwd)..."

for name in "${!services[@]}"; do
  slug="${services[$name]}"
  file="${name}-logo.svg"

  # Nếu file đã tồn tại và có nội dung → bỏ qua
  if [[ -s "$file" ]]; then
    echo "  ⏭️  Skipped $file (already exists)"
    continue
  fi

  echo "  → Downloading $file from simpleicons [$slug]"
  curl -sL "https://cdn.simpleicons.org/${slug}" -o "$file"

  # Kiểm tra nếu tải lỗi
  if [[ ! -s "$file" ]]; then
    echo "    ❌ Failed or file is empty. Removing $file"
    rm -f "$file"
  else
    echo "    ✅ Saved: $file"
  fi
done

echo "🎉 All done!"
