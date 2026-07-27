#!/usr/bin/env bash
set -euo pipefail
if [[ -z "${_GUARDS_LOADED:-}" ]]; then SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "$SCRIPT_DIR/../helpers/all.sh"; fi
log "Ensuring hicolor icon theme directories are discoverable..."

local_icons="$HOME/.local/share/icons/hicolor"
if [[ ! -d "$local_icons" ]]; then
  success "no local icons dir — nothing to fix"
  exit 0
fi

# Find all subdirs with .png/.svg icons under apps/
existing=()
while IFS= read -r dir; do
  res_dir="${dir#"$local_icons/"}"
  existing+=("$res_dir")
done < <(find "$local_icons" -type d -name apps -exec sh -c 'ls "$1"/*.png "$1"/*.svg 2>/dev/null' _ {} \; -print 2>/dev/null | grep -v '\.png\|\.svg' | sort -u || true)

if [[ ${#existing[@]} -eq 0 ]]; then
  success "no icon directories with apps found — nothing to fix"
  exit 0
fi

# Ensure index.theme exists
if [[ ! -f "$local_icons/index.theme" ]]; then
  cat > "$local_icons/index.theme" <<EOF
[Icon Theme]
Name=Hicolor
Comment=Default icon theme
Directories=${existing[*]}
EOF
else
  # Append missing directories to Directories= line
  current_dirs=$(grep "^Directories=" "$local_icons/index.theme" 2>/dev/null | cut -d= -f2- || true)
  for res_dir in "${existing[@]}"; do
    if ! echo ",$current_dirs," | grep -q ",$res_dir," 2>/dev/null; then
      sed -i "/^Directories=/ s|$|,$res_dir|" "$local_icons/index.theme"
      if ! grep -q "^\[$res_dir\]" "$local_icons/index.theme" 2>/dev/null; then
        size="${res_dir%/*}"
        size="${size%%x*}"
        printf "\n[%s]\nSize=%s\nContext=Applications\nType=Threshold\n" "$res_dir" "$size" >> "$local_icons/index.theme"
      fi
    fi
  done
  # Fix scalable type
  if grep -q "^\[scalable/" "$local_icons/index.theme" 2>/dev/null; then
    sed -i '/^\[scalable/,/^\[/s/^Type=Threshold$/Type=Scalable/' "$local_icons/index.theme"
    sed -i '/^\[scalable/,/^\[/s/^Type=Fixed$/Type=Scalable/' "$local_icons/index.theme"
  fi
fi

gtk-update-icon-cache "$local_icons" 2>/dev/null || true
success "hicolor icon theme updated"
