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
        $lines.Add('..')
        foreach ($d in $dirs) { $lines.Add($d.Name) }
        if ($dirs.Count -gt 0 -or $files.Count -gt 0) { $lines.Add('───') }

        $maxFiles = 4
        $count = 0
        foreach ($f in $files) {
            if ($count -ge $maxFiles) { break }
            $lines.Add($f.Name)
            $count++
        }

        if ($files.Count -gt $maxFiles) {
            $more = $files.Count - $maxFiles
            $lines.Add("··· ($more more)")
        }

        $source = $lines -join "`n"
        $env:FZF_DEFAULT_OPTS = '--height=80% --layout=reverse --border --no-info'

        if ($hasBat) {
            $preview = 'bat --color=always --line-range :50 "__CDX_PATH__\{}" 2>nul || dir /b "__CDX_PATH__\{}" 2>nul'
        } else {
            $preview = 'type "__CDX_PATH__\{}" 2>nul || dir /b "__CDX_PATH__\{}" 2>nul'
        }
        $preview = $preview.Replace('__CDX_PATH__', $currentPath)

        $selected = $source | fzf `
            --header "cdx2: $currentPath | Enter=open, Ctrl+H=~, Ctrl+U=up, Esc=exit" `
            --preview $preview `
            --preview-window 'right:60%,border-rounded' `
            --bind "ctrl-h:become(echo __HOME__)" `
            --bind "ctrl-u:become(echo __UP__)" `
            2>$null

        $env:FZF_DEFAULT_OPTS = ''

        if (-not $selected) { break }

        switch -Wildcard ($selected) {
            '__HOME__' { Set-Location $HOME; continue }
            '__UP__'   { Set-Location ..; continue }
            '..'       { Set-Location ..; $depth++; continue }
            '───'      { continue }
            '···*'     { continue }
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
