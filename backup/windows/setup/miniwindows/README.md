# MiniWindows Setup

Lightweight Windows 11 VM for Microsoft 365 apps, managed from Linux via `winapps-vm`.

## What's included

- Microsoft 365 (Word, Excel, PowerPoint, OneNote, Outlook)
- RDP optimization for fullscreen remote access
- VM performance tuning (disabled telemetry, hibernation, search indexer)

## How to use

### From Linux

```bash
# First-time setup
winapps-vm install

# Launch (auto-stops on disconnect)
winapps-vm launch

# Launch (keeps VM running)
winapps-vm launch -k

# Or use the convenience wrapper
winapps-launch

# Check status
winapps-vm status

# View logs
winapps-vm logs
winapps-vm logs -f  # follow
```

### Inside Windows (first boot)

1. Connect via `winapps-vm launch`
2. Open PowerShell inside the VM
3. Run:

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
C:\shared\setup-mini\run-all.ps1
```

## Shared folder

- Linux: `~/WinApps/shared/`
- Windows: `C:\shared\`

## Configuration

Edit `~/.config/winapps-vm/config.env` to change VM resources:

```env
WINAPPS_VM_RAM=16G
WINAPPS_VM_CPU_CORES=8
WINAPPS_VM_DISK_SIZE=64G
```

After changing config, run `winapps-vm remove` then `winapps-vm install` to recreate the VM.

## Reproducibility

Everything is managed via chezmoi dotfiles:

- Linux dependencies: `linux/setup/packaging/office/winapps-vm.sh`
- VM script: `~/.local/bin/winapps-vm`
- Windows setup: copied to `C:\shared\setup-mini\` on install
- Config template: `~/.config/winapps-vm/config.env`

After reinstalling CachyOS, run the chezmoi installer, then `winapps-vm install`.