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

