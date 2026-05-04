function cdx2 {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, ValueFromRemainingArguments = $true)]
        [string[]]$QueryParts,
        [Alias('s')]
        [switch]$Search
    )

    $Query = $QueryParts -join ' '

    if ($Query -and (Test-Path $Query) -and -not $Search) {
        Set-Location $Query
    }

    if ($Search) {
        if (-not (Get-Command Invoke-CdxSearch -ErrorAction SilentlyContinue)) {
            Write-Host '[!] Invoke-CdxSearch not found. Is Cdx.ps1 loaded?' -ForegroundColor Red
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
        $hasBat = Get-Command bat -ErrorAction SilentlyContinue

        $dirs = Get-ChildItem -Directory | Sort-Object Name
        $files = Get-ChildItem -File | Sort-Object Name

        $lines = [System.Collections.Generic.List[string]]::new()
        $lines.Add("..`t..")

        foreach ($d in $dirs) {
            $n = $d.Name
            $lines.Add("`e[34m$n`e[0m`t$n")
        }

        if ($dirs.Count -gt 0 -or $files.Count -gt 0) {
            $lines.Add("`e[90m─`e[0m`t")
        }

        $showCount = 4
        $shown = 0
        foreach ($f in $files) {
            if ($shown -ge $showCount) { break }
            $n = $f.Name
            $lines.Add("$n`t$n")
            $shown++
        }

        $remaining = $files.Count - $shown
        if ($remaining -gt 0) {
            $lines.Add("`e[90m⋯ ($remaining more)`e[0m`t")
        }

        $source = $lines -join "`n"
        $env:FZF_DEFAULT_OPTS = "--height=80% --layout=reverse --border --no-info --ansi"

        if ($hasBat) {
            $preview = 'bat --color=always --line-range :50 "__CDX_PATH__\{2}" 2>nul || dir /b "__CDX_PATH__\{2}" 2>nul'
        } else {
            $preview = 'type "__CDX_PATH__\{2}" 2>nul || dir /b "__CDX_PATH__\{2}" 2>nul'
        }
        $preview = $preview.Replace('__CDX_PATH__', $currentPath)

        $selected = $source | fzf `
            --delimiter "`t" `
            --with-nth 1 `
            --nth 2 `
            --header "cdx2: $currentPath | Enter=open, Ctrl+H=~, Ctrl+U=up, Esc=exit" `
            --preview $preview `
            --preview-window 'right:60%,border-rounded' `
            --bind "ctrl-h:become(echo __HOME__)" `
            --bind "ctrl-u:become(echo __UP__)" `
            2>$null

        $env:FZF_DEFAULT_OPTS = ''

        if (-not $selected) { break }

        $parts = $selected -split "`t"
        $value = $parts[-1]

        if (-not $value) { continue }

        switch ($value) {
            '__HOME__' { Set-Location $HOME; continue }
            '__UP__'   { Set-Location ..; continue }
            '..'       { Set-Location ..; $depth++; continue }
            default {
                $target = Join-Path $currentPath $value
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
