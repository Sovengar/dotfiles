# ============================
# cdx — CD Interactivo Unificado
# Jump:    cdx <name>       → cd directo → zoxide → TUI con query
# Browse:  cdx              → TUI fd (carpetas)
# Search:  cdx -g <query>   → ripgrep búsqueda de contenido
# TUI:     fd/rg toggle Ctrl+R | hidden toggle Ctrl+A | home Ctrl+H
# ============================

function cdx {
    [CmdletBinding()]
    param(
        [Parameter(Position=0, ValueFromRemainingArguments=$true)]
        [string[]]$QueryParts,
        [Alias('g')]
        [switch]$Grep
    )

    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $Query = $QueryParts -join ' '

    # 1) -g → búsqueda de contenido con ripgrep
    if ($Grep) {
        Invoke-CdxSearch -Query $Query
        return
    }

    # 2) Sin args → TUI de navegación
    if (-not $Query) {
        Invoke-CdxTui
        return
    }

    # 3) Con query → cd directo → zoxide → TUI con query pre-llenada
    if (Test-Path $Query) {
        Set-Location $Query
        return
    }

    $hasZoxide = Get-Command zoxide -ErrorAction SilentlyContinue
    if ($hasZoxide) {
        $result = zoxide query $Query 2>$null
        if ($result) {
            Set-Location $result
            return
        }
    }

    # Fallback: TUI con query pre-llenada
    Invoke-CdxTui -InitialQuery $Query
}

# ============================
# Invoke-CdxTui — TUI fd/rg
# ============================
function Invoke-CdxTui {
    param([string]$InitialQuery = '')

    # Check fd
    if (-not (Get-Command fd -ErrorAction SilentlyContinue)) {
        Write-Host '[!] fd not found. Install: winget install sharkdp.fd' -ForegroundColor Red
        return
    }

    # 1) Cache zoxide list ONCE
    $script:zoxideCache = @()
    $hasZoxide = Get-Command zoxide -ErrorAction SilentlyContinue
    if ($hasZoxide) {
        $script:zoxideCache = zoxide query --list 2>$null
    }

    # 2) State init
    $hasEza = Get-Command eza -ErrorAction SilentlyContinue
    $hasBat = Get-Command bat -ErrorAction SilentlyContinue
    $stateFile = Join-Path $env:TEMP 'cdx_state.txt'
    Set-Content -Path $stateFile -Value '0' -Force -NoNewline

    $escFile = Join-Path $env:TEMP 'cdx_esc.txt'
    Set-Content -Path $escFile -Value '0' -Force -NoNewline
    $lastEscPathFile = Join-Path $env:TEMP 'cdx_esc_path.txt'
    $doubleEscMs = 500

    function Get-Labels {
        param([int]$State)
        $rgOn = ($State -band 1) -ne 0
        $hiddenOn = ($State -band 2) -ne 0
        $rgLabel = if ($rgOn) { '[✓] files (rg)' } else { '[x] dirs (fd)' }
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
    $toggleRgPs1 = Join-Path $env:TEMP 'cdx_toggle_rg.ps1'
    $toggleHiddenPs1 = Join-Path $env:TEMP 'cdx_toggle_hidden.ps1'

    @'
$s = [int](Get-Content $env:TEMP\cdx_state.txt -Raw).Trim()
$s = $s -bxor 1
Set-Content -Path $env:TEMP\cdx_state.txt -Value $s -Force -NoNewline
'@ | Set-Content -Path $toggleRgPs1 -Force

    @'
$s = [int](Get-Content $env:TEMP\cdx_state.txt -Raw).Trim()
$s = $s -bxor 2
Set-Content -Path $env:TEMP\cdx_state.txt -Value $s -Force -NoNewline
'@ | Set-Content -Path $toggleHiddenPs1 -Force

    while ($true) {
        $currentPath = (Get-Location).Path
        $displayPath = Format-DisplayPath -Path $currentPath
        $state = [int]((Get-Content $stateFile -Raw).Trim())
        $rgMode = ($state -band 1) -ne 0
        $showHidden = ($state -band 2) -ne 0

        if ($rgMode) {
            # ===== MODO RG: listar ARCHIVOS =====
            $rgArgs = @('--files', '--smart-case')
            if ($showHidden) { $rgArgs += '--hidden' }
            $rgArgs += '--glob', '!node_modules'
            $rgArgs += '--glob', '!.git'
            $rgArgs += '--glob', '!.cache'
            $rgArgs += '--glob', '!vendor'
            $rgArgs += '--glob', '!target'
            $rgArgs += '--glob', '!build'
            $rgArgs += '--glob', '!dist'
            $rgArgs += $currentPath

            $items = & rg @rgArgs 2>$null | ForEach-Object { $_.Replace('\', '/') }

            # Preview: bat con highlight del query de fzf
            if ($hasBat) {
                $preview = "bat --color=always --line-range :50 --highlight-line {q} {}"
            } else {
                $preview = "Get-Content {} -TotalCount 50"
            }
        } else {
            # ===== MODO FD: listar CARPETAS =====
            $isRoot = ($currentPath -eq [System.IO.Path]::GetPathRoot($currentPath))

            if ($isRoot) {
                # At drive root (C:\): show children only (97K+ dirs via fd is slow)
                $fdDirs = if ($showHidden) {
                    Get-ChildItem -Directory -Path $currentPath -Force -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name
                } else {
                    Get-ChildItem -Directory -Path $currentPath -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name
                }
            } else {
                # Normal dir: recursive fd
                $fdArgs = @('--base-directory', $currentPath, '--type', 'd')
                if ($showHidden) { $fdArgs += '--hidden' }
                $fdArgs += '--exclude', 'node_modules'
                $fdArgs += '--exclude', '.git'
                $fdArgs += '--exclude', '.cache'
                $fdArgs += '--exclude', 'vendor'
                $fdArgs += '--exclude', 'target'
                $fdArgs += '--exclude', 'build'
                $fdArgs += '--exclude', 'dist'
                $fdArgs += '.'
                $fdDirs = & fd @fdArgs 2>$null | ForEach-Object { $_.Replace('\', '/').TrimEnd('/') }
            }

            # Zoxide merge
            $zoxideMap = @{}
            $zoxideDirs = @()
            foreach ($z in $script:zoxideCache) {
                if ($z -eq $currentPath) { continue }
                $prefix = $currentPath.TrimEnd('\') + '\'
                if ($z.StartsWith($prefix)) {
                    $rel = $z.Substring($currentPath.Length).TrimStart('\').Replace('\', '/').TrimEnd('/')
                    if ($rel -and -not $zoxideMap.ContainsKey($rel)) {
                        $zoxideMap[$rel] = $true
                        $zoxideDirs += $rel
                    }
                }
            }

            $items = @()
            foreach ($z in $zoxideDirs) { $items += "★ $z" }
            foreach ($d in $fdDirs) {
                if (-not $zoxideMap.ContainsKey($d)) { $items += $d }
            }

            # Preview script para dirs
            $previewScript = Join-Path $env:TEMP 'cdx_preview.ps1'
            @"
param([string]`$Path)
`$Path = `$Path.Trim('"', "'")
`$Path = `$Path -replace '^★ ', ''
`$basePath = `$env:CDX_PREVIEW_BASE
if (-not `$basePath) { `$basePath = Get-Location }
`$fullPath = Join-Path `$basePath `$Path
if (Test-Path `$fullPath -PathType Container) {
    if (Get-Command eza -ErrorAction SilentlyContinue) {
        eza --icons --group-directories-first --color=always `$fullPath
    } else {
        Get-ChildItem `$fullPath | Format-Table Name,Mode,LastWriteTime
    }
} elseif (Test-Path `$fullPath) {
    if (Get-Command bat -ErrorAction SilentlyContinue) {
        bat --color=always --line-range :50 `$fullPath
    } else {
        Get-Content `$fullPath -TotalCount 50
    }
}
"@ | Set-Content -Path $previewScript -Force
            $env:CDX_PREVIEW_BASE = $currentPath
            $preview = "pwsh -NoProfile -File `"$previewScript`" {}"
        }

        if (-not $items) {
            if ($hasEza) {
                Write-Host "`n$displayPath" -ForegroundColor Cyan
                eza --icons --group-directories-first
            } else {
                Write-Host "`n$displayPath" -ForegroundColor Cyan
                Get-ChildItem -Force | Format-Table
            }
            return
        }

        # Header
        $rgLabel, $hiddenLabel = Get-Labels -State $state
        $headerLine1 = "$displayPath | $rgLabel | $hiddenLabel"
        if ($rgMode) {
            $headerLine2 = "Enter=open │ Esc=up │ DobleEsc=exit │ Ctrl+H=home │ Ctrl+R=dirs │ Ctrl+A=$hiddenLabel"
        } else {
            $headerLine2 = "Enter=cd │ Esc=up │ DobleEsc=exit │ Ctrl+H=home │ Ctrl+R=files │ Ctrl+A=$hiddenLabel"
        }
        $header = "$headerLine1`n$headerLine2"

        $env:FZF_DEFAULT_OPTS = '--height=80% --layout=reverse --border'

        # Build fzf args array
        $fzfArgs = @(
            "--header=$header",
            "--preview=$preview",
            '--preview-window=right:60%,border-rounded',
            "--bind=ctrl-r:execute(pwsh -File `"$toggleRgPs1`")",
            "--bind=ctrl-a:execute(pwsh -File `"$toggleHiddenPs1`")",
            '--bind=ctrl-h:become(echo __GOTO_HOME__)'
        )
        if ($InitialQuery) {
            $fzfArgs += "--query=$InitialQuery"
            $InitialQuery = ''  # Solo usar en primera iteración
        }

        # Run fzf
        try {
            $selected = @($items) | fzf @fzfArgs 2>$null
        } finally {
            $env:FZF_DEFAULT_OPTS = ''
        }

        # Esc or empty
        if (-not $selected) {
            $lastEsc = [long]((Get-Content $escFile -Raw).Trim())
            $now = [DateTimeOffset]::Now.ToUnixTimeMilliseconds()
            $elapsed = $now - $lastEsc

            $currentPath = (Get-Location).Path
            $displayPath = Format-DisplayPath -Path $currentPath

            if ($lastEsc -ne 0 -and $elapsed -lt $doubleEscMs) {
                $restorePath = if (Test-Path $lastEscPathFile) { (Get-Content $lastEscPathFile -Raw).Trim() } else { '' }
                if ($restorePath -and (Test-Path $restorePath)) {
                    Set-Location $restorePath
                    $currentPath = $restorePath
                    $displayPath = Format-DisplayPath -Path $currentPath
                }
                if ($hasEza) {
                    Write-Host "`n$displayPath" -ForegroundColor Cyan
                    eza --icons --group-directories-first
                } else {
                    Write-Host "`n$displayPath" -ForegroundColor Cyan
                    Get-ChildItem -Force | Format-Table
                }
                return
            }

            Set-Content -Path $escFile -Value $now -Force -NoNewline
            Set-Content -Path $lastEscPathFile -Value $currentPath -Force -NoNewline
            $parent = Split-Path $currentPath -Parent
            if ($parent -and $parent -ne $currentPath) {
                Set-Location $parent
                continue
            } else {
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

        # Handle become outputs
        if ($selected -eq '__GOTO_HOME__') {
            Set-Location $env:USERPROFILE
            Set-Content -Path $escFile -Value '0' -Force -NoNewline
            continue
        }

        # Strip ★ prefix
        $cleanSelected = $selected -replace '^★ ', ''

        if ($rgMode) {
            # Modo rg: abrir archivo
            $fullPath = $cleanSelected
            if ($hasBat) {
                bat $fullPath
            } else {
                Get-Content $fullPath -TotalCount 50
            }
            Set-Content -Path $escFile -Value '0' -Force -NoNewline
            # No continue: vuelve a mostrar la lista
        } else {
            # Modo fd: cd into directory
            $targetPath = Join-Path $currentPath $cleanSelected
            Set-Location $targetPath
            Set-Content -Path $escFile -Value '0' -Force -NoNewline
        }
    }
}

# ============================
# Invoke-CdxSearch (antes -s, ahora -g)
# ============================
function Invoke-CdxSearch {
    param([string]$Query)

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

    # Phase 1: Content matches
    $contentMatches = @()
    foreach ($root in $priorityRoots) {
        if (Test-Path $root) {
            $contentMatches += & rg --files-with-matches --smart-case --hidden --max-depth $maxPriorityDepth $Query $root 2>$null
        }
    }
    $contentMatches += & rg --files-with-matches --smart-case --hidden --max-depth $maxSecondaryDepth `
        @excludeGlobs $Query $HOME 2>$null

    # Phase 2: File name matches
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

    # Phase 3: Directory name matches
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

    # Combine & deduplicate
    $allResults = @($contentMatches) + @($nameMatches) + @($dirMatches) |
        Where-Object { $_ } |
        Select-Object -Unique

    if ((-not $allResults) -or ($allResults.Count -eq 0)) {
        Write-Host "[i] No matches found for '$Query'" -ForegroundColor Yellow
        return
    }

    Write-Host "[i] Found $($allResults.Count) matches. Select with fzf..." -ForegroundColor Cyan

    $safeQuery = $Query -replace '"', '""'
    $env:FZF_DEFAULT_OPTS = "--height=60% --layout=reverse --border --preview-window=up:50%"
    $selected = $allResults | fzf `
        --header="cdx search: Enter=navigate, Esc=cancel" `
        --preview "rg --context=3 --color=always --max-columns=200 `"$safeQuery`" {} 2>nul"

    if (-not $selected) { return }

    Resolve-CdxDestination -Path $selected
}

# ============================
# Resolve-CdxDestination
# ============================
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
