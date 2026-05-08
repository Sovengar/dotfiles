<#
.SYNOPSIS
    Quick command popup for WezTerm.
    Client script — signals the persistent daemon to show the popup.
#>

try {
    $show = [System.Threading.EventWaitHandle]::OpenExisting("QuickCmdShow")
    $show.Set()
    exit
}
catch {
    # Daemon not running — start it
    $daemon = Join-Path $env:USERPROFILE ".config\wezterm\quickcmd_daemon.ps1"
    Start-Process powershell.exe -WindowStyle Hidden -ArgumentList @(
        "-ExecutionPolicy", "Bypass",
        "-NoProfile",
        "-File", $daemon
    )

    for ($i = 0; $i -lt 30; $i++) {
        Start-Sleep -Milliseconds 200
        try {
            $show = [System.Threading.EventWaitHandle]::OpenExisting("QuickCmdShow")
            $show.Set()
            exit
        } catch {}
    }

    # Fallback: start a fresh popup directly (no daemon)
    Start-Process powershell.exe -WindowStyle Hidden -ArgumentList @(
        "-ExecutionPolicy", "Bypass",
        "-NoProfile",
        "-File", "$env:USERPROFILE\.config\wezterm\quickcmd_daemon.ps1"
    )
    Start-Sleep 1
    try {
        $show = [System.Threading.EventWaitHandle]::OpenExisting("QuickCmdShow")
        $show.Set()
    } catch {}
}
