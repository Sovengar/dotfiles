# ============================
# cdx - CD Vitaminado
# Jump Mode:  cdx <name>       (zoxide frecency jump)
# Search Mode: cdx -s <query>  (ripgrep + fzf search in $HOME)
# ============================

function cdx {
    [CmdletBinding(DefaultParameterSetName='Jump')]
    param(
        [Parameter(Position=0, Mandatory=$true, ValueFromRemainingArguments=$true)]
        [string[]]$QueryParts,

        [Parameter(ParameterSetName='Search')]
        [Alias('s')]
        [switch]$Search
    )

    $Query = $QueryParts -join ' '

    # Direct path: go there immediately
    if (Test-Path $Query) {
        Set-Location $Query
        return
    }

    if ($Search) {
        Invoke-CdxSearch -Query $Query
        return
    }

    # Jump Mode: try zoxide if installed
    $hasZoxide = Get-Command zoxide -ErrorAction SilentlyContinue
    if ($hasZoxide) {
        $result = zoxide query $Query 2>$null
        if ($result) {
            Set-Location $result
            return
        }
    }

    # Fallback: auto-search if zoxide not installed or no match
    if (-not $hasZoxide) {
        Write-Host "[i] zoxide not installed. Searching with rg+fzf... (install zoxide: winget install ajeetdsouza.zoxide)" -ForegroundColor Cyan
    }
    Invoke-CdxSearch -Query $Query
}

function Invoke-CdxSearch {
    param([string]$Query)

    # Validate dependencies
    if (-not (Get-Command rg.exe -ErrorAction SilentlyContinue)) {
        Write-Host "[!] ripgrep not found. Install: winget install BurntSushi.ripgrep.MSVC" -ForegroundColor Red
        return
    }
    if (-not (Get-Command fzf.exe -ErrorAction SilentlyContinue)) {
        Write-Host "[!] fzf not found. Install: winget install junegunn.fzf" -ForegroundColor Red
        return
    }

    $priorityRoots = @(
        (Join-Path $HOME 'dev'),
        (Join-Path $HOME '.config')
    )
    $maxPriorityDepth = 6
    $maxSecondaryDepth = 5

    $excludeGlobs = @(
        '--glob', '!node_modules',
        '--glob', '!.git',
        '--glob', '!AppData',
        '--glob', '!.cache',
        '--glob', '!vendor',
        '--glob', '!target',
        '--glob', '!build',
        '--glob', '!dist'
    )

    Write-Host "[i] Searching for '$Query'..." -ForegroundColor Cyan

    # --- Phase 1: Content matches (rg --files-with-matches) ---
    $contentMatches = @()
    foreach ($root in $priorityRoots) {
        if (Test-Path $root) {
            $contentMatches += & rg --files-with-matches --smart-case --hidden --max-depth $maxPriorityDepth $Query $root 2>$null
        }
    }
    $contentMatches += & rg --files-with-matches --smart-case --hidden --max-depth $maxSecondaryDepth `
        @excludeGlobs $Query $HOME 2>$null

    # --- Phase 2: File name matches (rg --files | rg $Query) ---
    $nameMatches = @()
    foreach ($root in $priorityRoots) {
        if (Test-Path $root) {
            $results = & rg --files --hidden --max-depth $maxPriorityDepth $root 2>$null
            if ($results) {
                $nameMatches += $results | & rg --smart-case $Query 2>$null
            }
        }
    }
    $results = & rg --files --hidden --max-depth $maxSecondaryDepth @excludeGlobs $HOME 2>$null
    if ($results) {
        $nameMatches += $results | & rg --smart-case $Query 2>$null
    }

    # --- Phase 3: Directory name matches (Get-ChildItem) ---
    $dirMatches = @()
    foreach ($root in $priorityRoots) {
        if (Test-Path $root) {
            $dirMatches += Get-ChildItem $root -Directory -Recurse -Depth $maxPriorityDepth -Force -ErrorAction SilentlyContinue |
                Where-Object { $_.FullName -like "*$Query*" } |
                Select-Object -ExpandProperty FullName
        }
    }
    $excludeDirNames = @('node_modules', '.git', 'AppData', '.cache', 'vendor', 'target', 'build', 'dist')
    $dirMatches += Get-ChildItem $HOME -Directory -Recurse -Depth $maxSecondaryDepth -Force -ErrorAction SilentlyContinue |
        Where-Object { ($_.FullName -like "*$Query*") -and ($excludeDirNames -notcontains $_.Name) } |
        Select-Object -ExpandProperty FullName

    # --- Combine & deduplicate ---
    $allResults = @($contentMatches) + @($nameMatches) + @($dirMatches) |
        Where-Object { $_ } |
        Select-Object -Unique

    if ((-not $allResults) -or ($allResults.Count -eq 0)) {
        Write-Host "[i] No matches found for '$Query'" -ForegroundColor Yellow
        return
    }

    Write-Host "[i] Found $($allResults.Count) matches. Select with fzf..." -ForegroundColor Cyan

    # Escape double quotes in query for preview command
    $safeQuery = $Query -replace '"', '""'

    # --- fzf selection ---
    $env:FZF_DEFAULT_OPTS = "--height=60% --layout=reverse --border --preview-window=up:50%"
    $selected = $allResults | fzf `
        --header="cdx search: Enter=navigate, Esc=cancel" `
        --preview "rg --context=3 --color=always --max-columns=200 `"$safeQuery`" {} 2>nul"

    if (-not $selected) { return }

    Resolve-CdxDestination -Path $selected
}

function Resolve-CdxDestination {
    param([string]$Path)

    if (-not (Test-Path $Path)) {
        Write-Host "[!] Path no longer exists: $Path" -ForegroundColor Red
        return
    }

    if (Test-Path -PathType Container $Path) {
        Write-Host "[OK] cd $Path" -ForegroundColor Green
        Set-Location $Path
        return
    }

    # It's a file: go to parent first, then try git root
    $parent = Split-Path $Path -Parent
    Set-Location $parent

    if (Get-Command git -ErrorAction SilentlyContinue) {
        $gitRoot = & git -C $parent rev-parse --show-toplevel 2>$null
        if ($gitRoot) {
            Set-Location $gitRoot
            Write-Host "[OK] cd $gitRoot (git root)" -ForegroundColor Green
            return
        }
    }

    Write-Host "[OK] cd $parent" -ForegroundColor Green
}
