# LinuxAliases.ps1
# Comandos tipo Linux para PowerShell
# Ubicacion: $env:USERPROFILE\Documents\PowerShell\LinuxAliases.ps1

# Detectar herramientas disponibles
$script:HasRg = [bool](Get-Command rg -ErrorAction SilentlyContinue)
$script:HasFd = [bool](Get-Command fd -ErrorAction SilentlyContinue)
$script:HasBtm = [bool](Get-Command btm -ErrorAction SilentlyContinue)

# ============================================
# ls - Listar archivos (con flags tipo Unix)
# ============================================
Remove-Item alias:ls -ErrorAction SilentlyContinue

function ls {
    param(
        [switch]$a,
        [switch]$l,
        [switch]$la,
        [switch]$al,
        [switch]$lah,
        [switch]$h,
        [Parameter(ValueFromRemainingArguments=$true)]
        $RemainingArgs
    )

    $showHidden = $a -or $la -or $al -or $lah
    $longFormat = $l -or $la -or $al -or $lah
    $humanReadable = $h -or $lah

    $gciArgs = @{}
    if ($showHidden) { $gciArgs['Force'] = $true }

    $paths = $RemainingArgs | Where-Object { $_ -notmatch '^-' }
    $extraGciArgs = $RemainingArgs | Where-Object { $_ -match '^-' -and $_ -notin @('-a','-l','-la','-al','-lah','-h') } | ForEach-Object { $_ -replace '^-' }

    if (-not $paths) { $paths = '.' }

    foreach ($path in $paths) {
        $items = Get-ChildItem @gciArgs -Path $path @extraGciArgs -ErrorAction SilentlyContinue

        if ($items.Count -gt 1 -and $paths.Count -gt 1) {
            Write-Host "$path`:" -ForegroundColor Cyan
        }

        if (-not $items) { continue }

        if ($longFormat) {
            foreach ($item in $items) {
                $mode = ''
                if ($item.PSIsContainer) { $mode += 'd' } else { $mode += '-' }
                $mode += if ($item.Mode -match 'r') { 'r' } else { '-' }
                $mode += if ($item.Mode -match 'w') { 'w' } else { '-' }
                $mode += if ($item.Mode -match 'x') { 'x' } else { '-' }
                $mode += 'r--r--'

                $size = $item.Length
                if ($humanReadable -and $size -ge 0) {
                    if ($size -ge 1GB) { $sizeStr = '{0:N1}G' -f ($size / 1GB) }
                    elseif ($size -ge 1MB) { $sizeStr = '{0:N1}M' -f ($size / 1MB) }
                    elseif ($size -ge 1KB) { $sizeStr = '{0:N1}K' -f ($size / 1KB) }
                    else { $sizeStr = $size }
                } else {
                    $sizeStr = $size
                }

                $date = $item.LastWriteTime.ToString('MMM dd HH:mm')
                $name = $item.Name

                if ($item.PSIsContainer) {
                    Write-Host "$mode  1 buble buble  $($sizeStr.ToString().PadLeft(8))  $date  " -NoNewline
                    Write-Host $name -ForegroundColor Blue
                } else {
                    Write-Host "$mode  1 buble buble  $($sizeStr.ToString().PadLeft(8))  $date  $name"
                }
            }
        } else {
            $maxPerLine = 7
            $names = $items | Select-Object -ExpandProperty Name
            $i = 0
            foreach ($name in $names) {
                if (++$i -gt $maxPerLine) { Write-Host; $i = 1 }
                if ($i -eq 1) { Write-Host -NoNewline $name } else { Write-Host -NoNewline " $name" }
            }
            if ($i -gt 0) { Write-Host }
        }
    }
}

# Alias tipo Linux para ls
function ll { ls -l @args }
function la { ls -a @args }
function lla { ls -la @args }
function lah { ls -lah @args }

# ============================================
# touch - Crear archivo vacio
# ============================================
function touch {
    param([Parameter(Mandatory=$true)]$Path)
    if (Test-Path $Path) {
        (Get-Item $Path).LastWriteTime = Get-Date
    } else {
        New-Item -ItemType File -Path $Path -Force | Out-Null
    }
}

# ============================================
# grep - Buscar texto
# ============================================
function grep {
    param(
        [switch]$r,
        [Parameter(Mandatory=$true, Position=0)]$Pattern,
        [Parameter(ValueFromRemainingArguments=$true)]$Paths
    )
    if (-not $Paths) { $Paths = '.' }
    
    if ($script:HasRg) {
        $args = @($Pattern) + $Paths
        if ($r) { $args = @('--recursive') + $args }
        & rg @args --color=always
    } else {
        $slsArgs = @{ Pattern = $Pattern; Path = $Paths }
        if ($r) { $slsArgs['Recurse'] = $true }
        Select-String @slsArgs | ForEach-Object {
            $parts = $_ -split ':', 3
            if ($parts.Count -ge 3) {
                Write-Host "$($parts[0]):" -NoNewline -ForegroundColor Cyan
                Write-Host "$($parts[1]):" -NoNewline -ForegroundColor Yellow
                Write-Host $parts[2]
            } else {
                Write-Host $_
            }
        }
    }
}

# ============================================
# head - Primeras N lineas
# ============================================
function head {
    param(
        [Parameter(Mandatory=$true, Position=0)]$Path,
        [int]$n = 10
    )
    Get-Content -Path $Path -TotalCount $n
}

# ============================================
# tail - Ultimas N lineas
# ============================================
function tail {
    param(
        [Parameter(Mandatory=$true, Position=0)]$Path,
        [int]$n = 10,
        [switch]$f
    )
    if ($f) {
        Get-Content -Path $Path -Wait -Tail $n
    } else {
        Get-Content -Path $Path -Tail $n
    }
}

# ============================================
# which - Ubicacion de ejecutable
# ============================================
function which {
    param([Parameter(Mandatory=$true)]$Name)
    $cmd = Get-Command $Name -ErrorAction SilentlyContinue
    if ($cmd) {
        $cmd | Select-Object -ExpandProperty Source
    } else {
        Write-Host "not found" -ForegroundColor Red
    }
}

# ============================================
# df -h - Espacio en disco
# ============================================
function df {
    param([switch]$h)
    Get-Volume | Where-Object { $_.DriveLetter -or $_.Path } | ForEach-Object {
        $total = $_.Size
        $free = $_.SizeRemaining
        $used = $total - $free
        $percent = if ($total -gt 0) { [math]::Round(($used / $total) * 100, 1) } else { 0 }
        
        if ($h) {
            $totalStr = if ($total -ge 1TB) { "{0:N1}T" -f ($total/1TB) } elseif ($total -ge 1GB) { "{0:N1}G" -f ($total/1GB) } elseif ($total -ge 1MB) { "{0:N1}M" -f ($total/1MB) } else { "{0:N1}K" -f ($total/1KB) }
            $usedStr = if ($used -ge 1TB) { "{0:N1}T" -f ($used/1TB) } elseif ($used -ge 1GB) { "{0:N1}G" -f ($used/1GB) } elseif ($used -ge 1MB) { "{0:N1}M" -f ($used/1MB) } else { "{0:N1}K" -f ($used/1KB) }
            $freeStr = if ($free -ge 1TB) { "{0:N1}T" -f ($free/1TB) } elseif ($free -ge 1GB) { "{0:N1}G" -f ($free/1GB) } elseif ($free -ge 1MB) { "{0:N1}M" -f ($free/1MB) } else { "{0:N1}K" -f ($free/1KB) }
        } else {
            $totalStr = $total
            $usedStr = $used
            $freeStr = $free
        }
        
        $drive = if ($_.DriveLetter) { "$($_.DriveLetter):" } else { $_.Path }
        $percentStr = "{0,5}%" -f $percent
        
        Write-Host "$($drive.PadRight(12)) " -NoNewline
        Write-Host "$($totalStr.PadLeft(8)) " -NoNewline
        Write-Host "$($usedStr.PadLeft(8)) " -NoNewline
        Write-Host "$($freeStr.PadLeft(8)) " -NoNewline
        if ($percent -gt 90) { Write-Host $percentStr -ForegroundColor Red }
        elseif ($percent -gt 70) { Write-Host $percentStr -ForegroundColor Yellow }
        else { Write-Host $percentStr -ForegroundColor Green }
    }
}

# ============================================
# du -sh - Tamano de directorio
# ============================================
function du {
    param(
        [Parameter(ValueFromRemainingArguments=$true)]$Paths,
        [switch]$s,
        [switch]$h
    )
    if (-not $Paths) { $Paths = '.' }
    foreach ($path in $Paths) {
        if (Test-Path $path) {
            $size = (Get-ChildItem -Recurse -ErrorAction SilentlyContinue $path | Measure-Object -Property Length -Sum).Sum
            if ($h) {
                $sizeStr = if ($size -ge 1TB) { "{0:N1}T" -f ($size/1TB) } elseif ($size -ge 1GB) { "{0:N1}G" -f ($size/1GB) } elseif ($size -ge 1MB) { "{0:N1}M" -f ($size/1MB) } elseif ($size -ge 1KB) { "{0:N1}K" -f ($size/1KB) } else { "$size" }
            } else {
                $sizeStr = $size
            }
            if ($s) {
                Write-Host "$sizeStr`t$path"
            } else {
                Get-ChildItem $path | ForEach-Object {
                    $itemSize = if ($_.PSIsContainer) { (Get-ChildItem -Recurse -ErrorAction SilentlyContinue $_ | Measure-Object -Property Length -Sum).Sum } else { $_.Length }
                    if ($h) {
                        $itemSizeStr = if ($itemSize -ge 1TB) { "{0:N1}T" -f ($itemSize/1TB) } elseif ($itemSize -ge 1GB) { "{0:N1}G" -f ($itemSize/1GB) } elseif ($itemSize -ge 1MB) { "{0:N1}M" -f ($itemSize/1MB) } elseif ($itemSize -ge 1KB) { "{0:N1}K" -f ($itemSize/1KB) } else { "$itemSize" }
                    } else {
                        $itemSizeStr = $itemSize
                    }
                    Write-Host "$($itemSizeStr.PadLeft(10))`t$($_.Name)"
                }
            }
        }
    }
}

# ============================================
# uptime - Tiempo encendido
# ============================================
function uptime {
    $boot = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
    $uptime = (Get-Date) - $boot
    $days = $uptime.Days
    $hours = $uptime.Hours
    $minutes = $uptime.Minutes
    Write-Host "up " -NoNewline
    if ($days -gt 0) { Write-Host "$days days, " -NoNewline }
    Write-Host "$hours hours, $minutes minutes" -NoNewline
    Write-Host "  (since $($boot.ToString('yyyy-MM-dd HH:mm:ss')))" -ForegroundColor DarkGray
}

# ============================================
# ps aux - Procesos (lanza btm)
# ============================================
function ps {
    param([string]$aux)
    if ($aux -eq 'aux') {
        if ($script:HasBtm) {
            & btm
        } else {
            Get-Process | Select-Object Id, ProcessName, CPU, WorkingSet, Path | Format-Table -AutoSize
        }
    } else {
        Get-Process @args
    }
}

# ============================================
# wc -l - Contar lineas
# ============================================
function wc {
    param(
        [Parameter(ValueFromRemainingArguments=$true)]$Paths,
        [switch]$l
    )
    if (-not $Paths) { return }
    foreach ($path in $Paths) {
        $count = (Get-Content $path -ErrorAction SilentlyContinue).Count
        Write-Host "$count $path"
    }
}

# ============================================
# find - Buscar archivos
# ============================================
function find {
    param(
        [Parameter(Position=0)]$Path = '.',
        [switch]$name,
        [switch]$type,
        [Parameter(ValueFromRemainingArguments=$true)]$RemainingArgs
    )
    if ($script:HasFd) {
        $fdArgs = @($Path)
        if ($name) { $fdArgs += '--name' }
        if ($type) { $fdArgs += '--type', $RemainingArgs[0]; $RemainingArgs = $RemainingArgs[1..$RemainingArgs.Count] }
        $fdArgs += $RemainingArgs
        & fd @fdArgs
    } else {
        $gciArgs = @{ Path = $Path; Recurse = $true }
        if ($name) { $gciArgs['Filter'] = $RemainingArgs[0] }
        if ($type) {
            if ($RemainingArgs[0] -eq 'd') { $gciArgs['Directory'] = $true }
            elseif ($RemainingArgs[0] -eq 'f') { $gciArgs['File'] = $true }
        }
        Get-ChildItem @gciArgs -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
    }
}

# ============================================
# rm -rf - Borrar sin confirmacion
# ============================================
function rm {
    param(
        [Parameter(ValueFromRemainingArguments=$true)]$Paths,
        [switch]$r,
        [switch]$f
    )
    if (-not $Paths) { return }
    $riArgs = @{ }
    if ($r) { $riArgs['Recurse'] = $true }
    if ($f) { $riArgs['Force'] = $true }
    foreach ($path in $Paths) {
        Remove-Item -Path $path @riArgs -ErrorAction SilentlyContinue
    }
}

# ============================================
# btm - Wrapper para bottom
# ============================================
function btm {
    if ($script:HasBtm) {
        & $script:HasBtm.Source @args
    } else {
        Write-Host "bottom (btm) not installed. Install with: winget install Clement.bottom" -ForegroundColor Red
    }
}