$homeDir = $env:USERPROFILE
$vars = @{
    "XDG_CONFIG_HOME"  = "$homeDir\.config"
    "XDG_CACHE_HOME"   = "$homeDir\.cache"
    "XDG_DATA_HOME"    = "$homeDir\.local\share"
    "XDG_STATE_HOME"   = "$homeDir\.local\state"
    "XDG_RUNTIME_DIR"  = "$homeDir\AppData\Local\Temp\run-$env:USERNAME"
    "EDITOR"           = "code --wait"
}

$xdgKeys = @("XDG_CONFIG_HOME", "XDG_CACHE_HOME", "XDG_DATA_HOME", "XDG_STATE_HOME", "XDG_RUNTIME_DIR")

foreach ($var in $vars.GetEnumerator()) {
    [System.Environment]::SetEnvironmentVariable($var.Key, $var.Value, "User")
    if ($var.Key -in $xdgKeys -and -not (Test-Path $var.Value)) {
        New-Item -ItemType Directory -Path $var.Value -Force | Out-Null
    }
    Write-Host "[OK] $($var.Key) = $($var.Value)" -ForegroundColor Green
}

# ── OpenCode Go quota (from sops-encrypted secrets) ────────────

$chezmoiSource = if ($env:CHEZMOI_SOURCE) { $env:CHEZMOI_SOURCE } else { "$env:USERPROFILE\.local\share\chezmoi" }
$sopsFile = "$chezmoiSource\secrets\opencode-quota.sops.yaml"

if (Test-Path $sopsFile) {
    try {
        $decrypted = sops -d $sopsFile 2>$null
        if ($decrypted) {
            $workspaceId = ($decrypted | Select-String '(?<=opencode_go_workspace_id: ).*').Matches.Value
            $authCookie  = ($decrypted | Select-String '(?<=opencode_go_auth_cookie: ).*').Matches.Value

            if ($workspaceId -and $authCookie) {
                [System.Environment]::SetEnvironmentVariable("OPENCODE_GO_WORKSPACE_ID", $workspaceId, "User")
                [System.Environment]::SetEnvironmentVariable("OPENCODE_GO_AUTH_COOKIE", $authCookie, "User")
                Write-Host "[OK] OPENCODE_GO_WORKSPACE_ID set from sops" -ForegroundColor Green
                Write-Host "[OK] OPENCODE_GO_AUTH_COOKIE set from sops" -ForegroundColor Green
            } else {
                Write-Host "[WARN] Could not extract opencode-go vars from sops" -ForegroundColor Yellow
            }
        }
    } catch {
        Write-Host "[WARN] Failed to decrypt opencode-quota secrets: $_" -ForegroundColor Yellow
    }
} else {
    Write-Host "[WARN] opencode-quota.sops.yaml not found at $sopsFile" -ForegroundColor Yellow
}
