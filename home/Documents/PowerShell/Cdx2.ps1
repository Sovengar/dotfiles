# ============================
# cdx2 - CD Interactivo
# Directory navigator with fd + fzf
# Default: fd finds DIRECTORIES from $PWD (fast cd)
# Ctrl+R:  toggle rg mode (find files in $HOME, cd to parent)
# Ctrl+A:  toggle include/exclude system folders
# Mode indicator via --header-lines=1 (updates on reload)
# ============================

function cdx2 {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, ValueFromRemainingArguments = $true)]
        [string[]]$QueryParts,
        [Alias('s')]
        [switch]$Search
    )

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

    # 4) Recursive directory finder
    if (-not (Get-Command fd -ErrorAction SilentlyContinue)) {
        Write-Host '[!] fd not found. Install: winget install sharkdp.fd' -ForegroundColor Red; return
    }

    $hasBat = Get-Command bat -ErrorAction SilentlyContinue

    # State file for toggle persistence
    $stateFile = Join-Path $env:TEMP 'cdx2_state.txt'
    Set-Content -Path $stateFile -Value '0' -Force -NoNewline

    # Generator script called by fzf reload
    $genScript = Join-Path $env:TEMP 'cdx2_gen.ps1'
    @'
param([string]$StateFile, [string]$Action)

$state = if (Test-Path $StateFile) { [int]((Get-Content $StateFile -Raw).Trim()) } else { 0 }
switch ($Action) {
    'toggle_rg'  { $state = $state -bxor 1 }
    'toggle_all' { $state = $state -bxor 2 }
}
Set-Content -Path $StateFile -Value $state -Force -NoNewline

$modeRg  = ($state -band 1) -ne 0
$modeAll = ($state -band 2) -ne 0

if ($modeRg) {
    if (-not (Get-Command rg -ErrorAction SilentlyContinue)) { Write-Error "[!] rg not found"; exit 1 }
    $modeLabel = if ($modeAll) { 'FILES (all)' } else { 'FILES (filtered)' }
    $rgArgs = @('--files', '--hidden', '--smart-case', '--no-ignore')
    if (-not $modeAll) {
        $rgArgs += '--glob', '!node_modules/**', '--glob', '!.git/**', '--glob', '!.cache/**', '--glob', '!vendor/**', '--glob', '!target/**', '--glob', '!build/**', '--glob', '!dist/**'
    }
    $results = & rg @rgArgs $HOME
    "MODE: $modeLabel | Ctrl+R=fd | Ctrl+A=toggle-filter"
    $results
} else {
    if (-not (Get-Command fd -ErrorAction SilentlyContinue)) { Write-Error "[!] fd not found"; exit 1 }
    $modeLabel = if ($modeAll) { 'DIRS (all)' } else { 'DIRS (filtered)' }
    $fdArgs = @('--type', 'd', '--hidden', '--no-ignore-vcs')
    if (-not $modeAll) {
        $fdArgs += '--exclude', 'node_modules', '--exclude', '.git', '--exclude', '.cache', '--exclude', 'vendor', '--exclude', 'target', '--exclude', 'build', '--exclude', 'dist'
    }
    $fdArgs += '.', (Get-Location).Path
    $results = & fd @fdArgs
    "MODE: $modeLabel | Ctrl+R=rg | Ctrl+A=toggle-filter"
    $results
}
'@ | Set-Content -Path $genScript -Force

    # Use pwsh as shell for fzf (avoids cmd.exe quoting issues)
    $oldShell = $env:SHELL
    $env:SHELL = 'pwsh'

    $previewCmd = if ($hasBat) {
        'bat --color=always --line-range :50 "{}" 2>$null'
    } else {
        'Get-Content -TotalCount 50 "{}" 2>$null'
    }

    $env:FZF_DEFAULT_OPTS = '--height=80% --layout=reverse --border --no-info'

    try {
        $initial = @(
            "MODE: DIRS (filtered) | Ctrl+R=rg | Ctrl+A=toggle-filter"
        ) + @(& fd --type d --hidden --no-ignore-vcs `
            --exclude node_modules --exclude .git --exclude .cache `
            --exclude vendor --exclude target --exclude build --exclude dist `
            '.' $PWD 2>$null)

        if ($initial.Count -le 1) {
            Write-Host '[i] No directories found.' -ForegroundColor Yellow; return
        }

        $selected = $initial | fzf `
            --header-lines 1 `
            --preview $previewCmd `
            --preview-window 'right:60%,border-rounded' `
            --bind "ctrl-r:reload(& '$genScript' -StateFile '$stateFile' -Action toggle_rg)" `
            --bind "ctrl-a:reload(& '$genScript' -StateFile '$stateFile' -Action toggle_all)" `
            2>$null
    } finally {
        $env:SHELL = $oldShell
        $env:FZF_DEFAULT_OPTS = ''
    }

    if (-not $selected) { return }

    if (Test-Path -PathType Container $selected) {
        Set-Location $selected
        Write-Host "[OK] cd $selected" -ForegroundColor Green
    } else {
        $parent = Split-Path $selected -Parent
        Set-Location $parent
        Write-Host "[OK] cd $parent" -ForegroundColor Green
    }
}
