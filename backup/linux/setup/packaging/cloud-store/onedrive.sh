#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${_GUARDS_LOADED:-}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../../helpers/all.sh"
fi

log "Setting up OneDrive mount..."

detect_pkg_manager >/dev/null
_ensure_sudo

pkg_install rclone

MOUNT_POINT="$HOME/onedrive"
mkdir -p "$MOUNT_POINT"

# Check if remote already configured
if rclone listremotes 2>/dev/null | grep -q "^onedrive:"; then
  log "onedrive remote already configured"
else
  log "Configuring rclone onedrive remote (browser will open for OAuth)..."
  rclone config create onedrive onedrive
  success "onedrive remote configured"
fi

# systemd user service for auto-mount
FUSERMOUNT_CMD="fusermount3"
if ! command -v fusermount3 &>/dev/null; then
  FUSERMOUNT_CMD="fusermount"
fi

SERVICE_DIR="$HOME/.config/systemd/user"
mkdir -p "$SERVICE_DIR"

cat > "$SERVICE_DIR/rclone-onedrive.service" <<EOF
[Unit]
Description=Rclone OneDrive mount
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
ExecStart=rclone mount onedrive: $MOUNT_POINT --vfs-cache-mode writes --dir-cache-time 30s
ExecStop=$FUSERMOUNT_CMD -u $MOUNT_POINT
Restart=on-failure
RestartSec=10

[Install]
WantedBy=default.target
EOF

if command -v systemctl &>/dev/null && systemctl --user daemon-reload 2>/dev/null; then
  systemctl --user enable --now rclone-onedrive.service 2>/dev/null || log "Could not start rclone-onedrive.service — mount manually: rclone mount onedrive: $MOUNT_POINT"
else
  log "systemctl not available — mount manually: rclone mount onedrive: $MOUNT_POINT"
fi

success "OneDrive mount configured at $MOUNT_POINT"
