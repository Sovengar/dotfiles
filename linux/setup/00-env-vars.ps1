$homeDir = $env:HOME
$vars = @{
    "XDG_CONFIG_HOME" = "$homeDir/.config"
    "XDG_CACHE_HOME"  = "$homeDir/.cache"
    "XDG_DATA_HOME"   = "$homeDir/.local/share"
    "XDG_STATE_HOME"  = "$homeDir/.local/state"
}

foreach ($var in $vars.GetEnumerator()) {
    [System.Environment]::SetEnvironmentVariable($var.Key, $var.Value, "User")
    if (-not (Test-Path $var.Value)) {
        New-Item -ItemType Directory -Path $var.Value -Force | Out-Null
    }
    Write-Host "[OK] $($var.Key) = $($var.Value)" -ForegroundColor Green
}

[System.Environment]::SetEnvironmentVariable("XDG_DATA_DIRS", "/usr/local/share:/usr/share", "User")
[System.Environment]::SetEnvironmentVariable("XDG_CONFIG_DIRS", "/etc/xdg", "User")
Write-Host "[OK] XDG system dirs set" -ForegroundColor Green
