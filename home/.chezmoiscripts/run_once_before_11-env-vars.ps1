# run_once_after_10-env-vars.ps1
# Creates XDG_* environment variables

$homeDir = $env:USERPROFILE

$vars = @{
    "XDG_CONFIG_HOME" = "$homeDir\.config"
    "XDG_CACHE_HOME" = "$homeDir\.cache"
    "XDG_DATA_HOME" = "$homeDir\.local\share"
    "XDG_STATE_HOME" = "$homeDir\.local\state"
    "XDG_RUNTIME_DIR" = "$homeDir\AppData\Local\Temp\run-$env:USERNAME"
}

foreach ($var in $vars.GetEnumerator()) {
    [System.Environment]::SetEnvironmentVariable($var.Key, $var.Value, "User")
    if (-not (Test-Path $var.Value)) {
        New-Item -ItemType Directory -Path $var.Value -Force | Out-Null
    }
    Write-Host "[OK] $($var.Key) = $($var.Value)" -ForegroundColor Green
}

# System-level
[System.Environment]::SetEnvironmentVariable("XDG_DATA_DIRS", "/usr/local/share:/usr/share", "Machine")
[System.Environment]::SetEnvironmentVariable("XDG_CONFIG_DIRS", "/etc/xdg", "Machine")
