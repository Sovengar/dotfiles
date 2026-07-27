#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../helpers/all.sh"
fi

log "Setting up Elements drive mount..."

FSTAB_LINE="UUID=0C3693A836939176 /mnt/elements ntfs3 defaults,uid=1000,gid=1000,nofail,noauto,x-systemd.automount 0 2"
DEVICE="/dev/disk/by-uuid/0C3693A836939176"

_ensure_sudo

if [[ ! -d /mnt/elements ]]; then
  sudo mkdir -p /mnt/elements
  success "Created /mnt/elements"
fi

if grep -q "0C3693A836939176" /etc/fstab 2>/dev/null; then
  log "Elements mount already in /etc/fstab"
else
  # Remove any old bind mount lines pointing to /mnt/elements or /mnt/media
  sudo sed -i '/\/mnt\/elements/d; /\/mnt\/media/d' /etc/fstab
  echo "$FSTAB_LINE" | sudo tee -a /etc/fstab >/dev/null
  success "Added Elements UUID mount to /etc/fstab"
fi

if mountpoint -q /mnt/elements 2>/dev/null; then
  # Check it's actually the right device, not a stale tmpfs
  if grep -q "/dev/sda.* /mnt/elements" /proc/mounts 2>/dev/null; then
    log "Elements drive already mounted"
  else
    warn "/mnt/elements mounted but not the real drive — remounting"
    sudo umount /mnt/elements 2>/dev/null || true
  fi
fi

if ! mountpoint -q /mnt/elements 2>/dev/null; then
  if [[ -e $DEVICE ]]; then
    sudo mount /mnt/elements && success "Elements drive mounted" || warn "Elements mount failed"
  else
    warn "Elements drive not connected, skipping mount"
  fi
fi

success "Elements drive configured"
