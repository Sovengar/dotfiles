# ============================
# cdx2 - CD Interactivo
# Directory finder with fd + fzf
# Finds directories recursively from current path
# Enter = cd into selection, Esc = cd.., Doble Esc = exit
# Ctrl+R: toggle [x]/[✓] search inside files
# Ctrl+A: toggle show/hide hidden folders
# ============================

function cdx2 {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, ValueFromRemainingArguments = $true)]
        [string[]]$QueryParts,
        [Alias('s')]
        [switch]$Search
    )

    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $Query = $QueryParts -join ' '

    # 1) Direct path
    if ($Query -and (Test-Path $Query) -and -not $Search) {
        Set-Location $Query; return
    }

    # 2) -Search flag (delegate to Cdx.ps1)
    if ($Search) {
        if (-not (Get-Command Invoke-CdxSearch -ErrorAction SilentlyContinue)) {
            Write-Host '[!] Invoke-CdxSearch not found. Is Cdx.ps1 loaded?' -ForegroundColor Red; return
        }
        Invoke-CdxSearch -Query $Query; return
    }

    # 3) Zoxide fallback
    if ($Query -and -not (Test-Path $Query)) {
        $hasZoxide = Get-Command zoxide -ErrorAction SilentlyContinue
        if ($hasZoxide) {
            $result = zoxide query $Query 2>$null
            if ($result) { Set-Location $result; return }
        }
    }

    # Check fd
    if (-not (Get-Command fd -ErrorAction SilentlyContinue)) {
        Write-Host '[!] fd not found. Install: winget install sharkdp.fd' -ForegroundColor Red; return
    }

    # 4) Interactive browser with fd
    $hasBat = Get-Command bat -ErrorAction SilentlyContinue
    $hasEza = Get-Command eza -ErrorAction SilentlyContinue
    $stateFile = Join-Path $env:TEMP 'cdx2_state.txt'
    Set-Content -Path $stateFile -Value '0' -Force -NoNewline

    # Track double-esc timing
    $escFile = Join-Path $env:TEMP 'cdx2_esc.txt'
    Set-Content -Path $escFile -Value '0' -Force -NoNewline
    $doubleEscMs = 500

    function Get-Labels {
        param([int]$State)
        $rgOn = ($State -band 1) -ne 0
        $hiddenOn = ($State -band 2) -ne 0
        $rgLabel = if ($rgOn) { '[✓] search inside files' } else { '[x] search inside files' }
        $hiddenLabel = if ($hiddenOn) { 'show hidden' } else { 'hide hidden' }
        return $rgLabel, $hiddenLabel
    }

    function Format-DisplayPath {
        param([string]$Path)
        if ($Path.StartsWith($env:USERPROFILE)) {
            return "~" + $Path.Substring($env:USERPROFILE.Length).Replace('\', '/')
        }
        return $Path.Replace('\', '/')
    }

    # Toggle scripts
    $toggleRgPs1 = Join-Path $env:TEMP 'cdx2_toggle_rg.ps1'
    $toggleHiddenPs1 = Join-Path $env:TEMP 'cdx2_toggle_hidden.ps1'

    @'
$s = [int](Get-Content $env:TEMP\cdx2_state.txt -Raw).Trim()
$s = $s -bxor 1
Set-Content -Path $env:TEMP\cdx2_state.txt -Value $s -Force -NoNewline
'@ | Set-Content -Path $toggleRgPs1 -Force

    @'
$s = [int](Get-Content $env:TEMP\cdx2_state.txt -Raw).Trim()
$s = $s -bxor 2
Set-Content -Path $env:TEMP\cdx2_state.txt -Value $s -Force -NoNewline
'@ | Set-Content -Path $toggleHiddenPs1 -Force

    while ($true) {
        $currentPath = (Get-Location).Path
        $displayPath = Format-DisplayPath -Path $currentPath
        $state = [int]((Get-Content $stateFile -Raw).Trim())
        $showHidden = ($state -band 2) -ne 0

        # Build fd args
        $fdArgs = @('--type', 'd')
        if ($showHidden) { $fdArgs += '--hidden' }
        $fdArgs += '--exclude', 'node_modules'
        $fdArgs += '--exclude', '.git'
        $fdArgs += '--exclude', '.cache'
        $fdArgs += '--exclude', 'vendor'
        $fdArgs += '--exclude', 'target'
        $fdArgs += '--exclude', 'build'
        $fdArgs += '--exclude', 'dist'
        $fdArgs += '.'
        $fdArgs += $currentPath

        # Get directories via fd (returns paths relative to $currentPath)
        $dirs = & fd @fdArgs 2>$null | ForEach-Object { $_.Replace('\', '/') }

        if (-not $dirs) {
            if ($hasEza) {
                Write-Host "`n$displayPath" -ForegroundColor Cyan
                eza --icons --group-directories-first
            } else {
                Write-Host "`n$displayPath" -ForegroundColor Cyan
                Get-ChildItem -Force | Format-Table
            }
            return
        }

        # Header with labels and legend
        $rgLabel, $hiddenLabel = Get-Labels -State $state
        $headerLine1 = "$displayPath | $rgLabel | $hiddenLabel"
        $headerLine2 = "Enter=cd │ Esc=up │ DobleEsc=exit │ Ctrl+R=search │ Ctrl+A=$hiddenLabel"
        $header = "$headerLine1`n$headerLine2"

        # Preview - resolve relative path to absolute
        $preview = if ($hasBat) {
            'bat --color=always --line-range :50 "' + $currentPath + '\{}"'
        } else {
            'Get-Content -TotalCount 50 "' + $currentPath + '\{}"'
        }

        $env:FZF_DEFAULT_OPTS = '--height=80% --layout=reverse --border'

        # Run fzf with toggle bindings
        try {
            $selected = @($dirs) | fzf `
                --header="$header" `
                --preview="$preview" `
                --preview-window='right:60%,border-rounded' `
                --bind="ctrl-r:execute(pwsh -File $toggleRgPs1)" `
                --bind="ctrl-a:execute(pwsh -File $toggleHiddenPs1)" `
                2>$null
        } finally {
            $env:FZF_DEFAULT_OPTS = ''
        }

        # Esc or empty = cd.. (go up) or exit on double-esc
        if (-not $selected) {
            $lastEsc = [long](Get-Content $escFile -Raw).Trim()
            $now = [DateTimeOffset]::Now.ToUnixTimeMilliseconds()
            $elapsed = $now - $lastEsc

            if ($lastEsc -ne 0 -and $elapsed -lt $doubleEscMs) {
                # Double Esc detected - exit
                if ($hasEza) {
                    Write-Host "`n$displayPath" -ForegroundColor Cyan
                    eza --icons --group-directories-first
                } else {
                    Write-Host "`n$displayPath" -ForegroundColor Cyan
                    Get-ChildItem -Force | Format-Table
                }
                return
            }

            # Single Esc - go up and record time
            Set-Content -Path $escFile -Value $now -Force -NoNewline
            $parent = Split-Path $currentPath -Parent
            if ($parent -and $parent -ne $currentPath) {
                Set-Location $parent
                continue
            } else {
                # At root - exit
                if ($hasEza) {
                    Write-Host "`n$displayPath" -ForegroundColor Cyan
                    eza --icons --group-directories-first
                } else {
                    Write-Host "`n$displayPath" -ForegroundColor Cyan
                    Get-ChildItem -Force | Format-Table
                }
                return
            }
        }

        # cd into selected directory
        # selected is relative path from fd (e.g., "dev/work/vSocial")
        $targetPath = Join-Path $currentPath $selected
        Set-Location $targetPath
        # Reset esc timer when navigating into folder
        Set-Content -Path $escFile -Value '0' -Force -NoNewline
    }
}