# ============================
# cdx2 - CD Interactivo (fzf directory browser)
# Browse:   cdx2              - Navegación fzf del directorio actual
# Browse:   cdx2 <path>       - cd al path + navegación interactiva
# Search:   cdx2 -s <query>   - Búsqueda rg+fzf (reusa cdx)
# ============================

function cdx2 {
    [CmdletBinding(DefaultParameterSetName = 'Browse')]
    param(
        [Parameter(Position = 0, ValueFromRemainingArguments = $true)]
        [string[]]$QueryParts,

        [Parameter(ParameterSetName = 'Search')]
        [Alias('s')]
        [switch]$Search
    )

    $Query = $QueryParts -join ' '

    # 1. Direct path: cd there first, then browse
    if ($Query -and (Test-Path $Query) -and -not $Search) {
        Set-Location $Query
    }

    # 2. Search mode: delegate to cdx search engine
    if ($Search) {
        if (-not (Get-Command Invoke-CdxSearch -ErrorAction SilentlyContinue)) {
            Write-Host "[!] Invoke-CdxSearch not found. Is Cdx.ps1 loaded?" -ForegroundColor Red
            return
        }
        Invoke-CdxSearch -Query $Query
        return
    }

    # 3. Query that is not a path: try zoxide, then browse
    if ($Query -and -not (Test-Path $Query)) {
        $hasZoxide = Get-Command zoxide -ErrorAction SilentlyContinue
        if ($hasZoxide) {
            $result = zoxide query $Query 2>$null
            if ($result) {
                Set-Location $result
            } else {
                Write-Host "[i] zoxide no match for '$Query'. Entering browse mode..." -ForegroundColor Cyan
            }
        }
    }

    # --- Browse mode: fzf interactive directory navigation ---
    $hasBat = Get-Command bat -ErrorAction SilentlyContinue
    if ($hasBat) {
        $previewCmd = 'bat --color=always --line-range :50 "{}" 2>nul || dir /b "{}" 2>nul'
    } else {
        $previewCmd = 'if exist "{}\." (dir /b "{}" 2>nul) else (type "{}" 2>nul)'
    }

    $env:FZF_DEFAULT_OPTS = "--height=80% --layout=reverse --border --no-info"

    $maxDepth = 100
    $depth = 0

    while ($depth -lt $maxDepth) {
        $currentPath = (Get-Location).Path
        $items = @(Get-ChildItem -Force -ErrorAction SilentlyContinue)

        $fzfInput = [System.Collections.Generic.List[string]]::new()
        $fzfInput.Add('..')
        foreach ($item in $items) {
            $fzfInput.Add($item.Name)
        }

        $selected = $fzfInput | fzf `
            --header="cdx2: $currentPath | Enter=cd, Esc=exit" `
            --preview $previewCmd `
            --preview-window='right:60%,border-rounded' `
            2>$null

        if (-not $selected) { break }

        if ($selected -eq '..') {
            Set-Location ..
            $depth++
            continue
        }

        $target = Join-Path $currentPath $selected
        if (Test-Path -PathType Container $target) {
            Set-Location $target
            $depth++
        } else {
            break
        }
    }

    $env:FZF_DEFAULT_OPTS = ''
}
