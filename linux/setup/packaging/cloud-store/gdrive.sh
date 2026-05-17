#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Setting up Google Drive mount..."

detect_pkg_manager >/dev/null
_ensure_sudo

pkg_install rclone

MOUNT_POINT="$HOME/gdrive"
mkdir -p "$MOUNT_POINT"

# Check if remote already configured
if rclone listremotes 2>/dev/null | grep -q "^gdrive:"; then
  log "gdrive remote already configured"
else
  log "Configuring rclone gdrive remote (browser will open for OAuth)..."
  rclone config create gdrive drive scope=drive.file
  success "gdrive remote configured"
fi

# systemd user service for auto-mount
FUSERMOUNT_CMD="fusermount3"
if ! command -v fusermount3 &>/dev/null; then
  FUSERMOUNT_CMD="fusermount"
fi

SERVICE_DIR="$HOME/.config/systemd/user"
mkdir -p "$SERVICE_DIR"

cat > "$SERVICE_DIR/rclone-gdrive.service" <<EOF
[Unit]
Description=Rclone Google Drive mount
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
ExecStart=rclone mount gdrive: $MOUNT_POINT --vfs-cache-mode writes --dir-cache-time 30s
ExecStop=$FUSERMOUNT_CMD -u $MOUNT_POINT
Restart=on-failure
RestartSec=10

[Install]
WantedBy=default.target
EOF

if command -v systemctl &>/dev/null && systemctl --user daemon-reload 2>/dev/null; then
  systemctl --user enable --now rclone-gdrive.service 2>/dev/null || log "Could not start rclone-gdrive.service — mount manually: rclone mount gdrive: $MOUNT_POINT"
else
  log "systemctl not available (inside container?) — mount manually: rclone mount gdrive: $MOUNT_POINT"
fi

success "Google Drive mount configured at $MOUNT_POINT"
