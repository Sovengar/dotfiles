# ============================
# cdx2 - CD Interactivo (fzf directory/file browser)
# Browse:   cdx2              - Navegación + búsqueda recursiva
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

    if ($Query -and (Test-Path $Query) -and -not $Search) {
        Set-Location $Query
    }

    if ($Search) {
        if (-not (Get-Command Invoke-CdxSearch -ErrorAction SilentlyContinue)) {
            Write-Host "[!] Invoke-CdxSearch not found. Is Cdx.ps1 loaded?" -ForegroundColor Red
            return
        }
        Invoke-CdxSearch -Query $Query
        return
    }

    if ($Query -and -not (Test-Path $Query)) {
        $hasZoxide = Get-Command zoxide -ErrorAction SilentlyContinue
        if ($hasZoxide) {
            $result = zoxide query $Query 2>$null
            if ($result) {
                Set-Location $result
            } else {
                Write-Host "[i] no zoxide match for '$Query'. Starting browser..." -ForegroundColor Cyan
            }
        }
    }

    $maxDepth = 100
    $depth = 0

    while ($depth -lt $maxDepth) {
        $currentPath = (Get-Location).Path
        $hasFd = Get-Command fd -ErrorAction SilentlyContinue
        $hasRg = Get-Command rg -ErrorAction SilentlyContinue
        $hasBat = Get-Command bat -ErrorAction SilentlyContinue

        # Preview: full path, bat for files, dir for directories
        if ($hasBat) {
            $preview = "cmd /c bat --color=always --line-range :50 `"$currentPath\{}`" 2>nul || dir /b `"$currentPath\{}`" 2>nul"
        } else {
            $preview = "cmd /c type `"$currentPath\{}`" 2>nul || dir /b `"$currentPath\{}`" 2>nul"
        }

        # Recursive file/dir listing using best available tool
        $source = & {
            Write-Output '..'
            if ($hasFd) { fd --type f --type d --color never }
            elseif ($hasRg) { rg --files --color never }
            else { Get-ChildItem -Recurse -Name -ErrorAction SilentlyContinue }
        }

        $env:FZF_DEFAULT_OPTS = "--height=80% --layout=reverse --border --no-info"

        $selected = $source | fzf `
            --header "cdx2: $currentPath | Enter=open, Ctrl+H=~, Ctrl+U=up, Esc=exit" `
            --preview $preview `
            --preview-window 'right:60%,border-rounded' `
            --bind "ctrl-h:become(echo __HOME__)" `
            --bind "ctrl-u:become(echo __UP__)" `
            2>$null

        $env:FZF_DEFAULT_OPTS = ''

        if (-not $selected) { break }

        switch ($selected) {
            '__HOME__' { Set-Location $HOME; continue }
            '__UP__'   { Set-Location ..; continue }
            '..'       { Set-Location ..; $depth++; continue }
            default {
                $target = Join-Path $currentPath $selected
                if (Test-Path -PathType Container $target) {
                    Set-Location $target
                } else {
                    Set-Location (Get-Item $target).DirectoryName
                }
                $depth++
                continue
            }
        }
    }
}
