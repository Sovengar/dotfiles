function Read-Packages {
    $json = chezmoi execute-template "{{ toJson .packages }}" 2>$null
    if (-not $json) {
        $yamlPath = Join-Path $PSScriptRoot "..\..\home\.chezmoidata\packages.yaml"
        if (-not (Test-Path $yamlPath)) {
            $yamlPath = Join-Path $env:USERPROFILE ".local\share\chezmoi\home\.chezmoidata\packages.yaml"
        }
        if (Test-Path $yamlPath) {
            $json = chezmoi execute-template "{{ toJson .packages }}" --source "$yamlPath" 2>$null
        }
    }
    if ($json) {
        return ($json | ConvertFrom-Json)
    }
    Write-Host "[ERROR] Cannot read packages.yaml. Is chezmoi installed and the repo cloned?" -ForegroundColor Red
    return $null
}

function Install-WingetApp {
    param([string]$AppId)
    Write-Host "  Installing: $AppId" -ForegroundColor Cyan
    $proc = Start-Process "winget.exe" -ArgumentList "install -e --id $AppId --source winget --silent --accept-package-agreements --accept-source-agreements" -NoNewWindow -PassThru -Wait
    if ($proc.ExitCode -eq 0 -or $proc.ExitCode -eq -1978335189) {
        Write-Host "    [OK] $AppId" -ForegroundColor Green
        return $true
    } else {
        Write-Host "    [FAIL] $AppId (ExitCode: $($proc.ExitCode))" -ForegroundColor Red
        return $false
    }
}

function Reset-WingetSources {
    Write-Host "  Resetting winget sources..." -ForegroundColor Yellow
    winget source reset --force 2>&1 | Out-Null
    Write-Host "  [OK] Sources reset" -ForegroundColor Green
}

function Install-WingetList {
    param([array]$AppIds)
    $success = 0; $fail = 0; $skipped = 0
    foreach ($item in $AppIds) {
        if ($item -is [string]) {
            $appId = $item
            $interactive = $false
        } else {
            $appId = $item.id
            $interactive = if ($item.interactive) { $true } else { $false }
        }

        if ($interactive) {
            $response = Read-Host "  Install $appId? [Y/n]"
            if ($response -eq 'n' -or $response -eq 'N') {
                Write-Host "    [SKIP] $appId" -ForegroundColor Yellow
                $skipped++
                continue
            }
        }

        if (Install-WingetApp -AppId $appId) { $success++ } else { $fail++ }
    }
    $parts = @("$success OK")
    if ($fail -gt 0) { $parts += "$fail FAIL" }
    if ($skipped -gt 0) { $parts += "$skipped SKIPPED" }
    Write-Host "  [$($parts -join ', ')]" -ForegroundColor Green
}

function Invoke-ManualDownload {
    param(
        [string]$Name,
        [string]$Url,
        [string]$Dest,
        [bool]$IsArchive
    )
    $toolingPath = "$env:USERPROFILE\dev\tooling"
    $destPath = if ($Dest) { Join-Path $env:USERPROFILE $Dest } else { "$env:TEMP\$Name" }

    if (Test-Path $destPath) {
        return $true
    }

    try {
        $temp = "$env:TEMP\${Name}-download"
        Invoke-WebRequest -Uri $Url -OutFile $temp -UseBasicParsing

        if ($IsArchive) {
            $extractDir = Split-Path $destPath -Parent
            New-Item -ItemType Directory -Path $extractDir -Force | Out-Null
            Expand-Archive -Path $temp -DestinationPath $extractDir -Force
            Rename-ExtractedDir -ExtractDir $extractDir -Name $Name -DestPath $destPath
        } else {
            $parentDir = Split-Path $destPath -Parent
            New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
            Move-Item -Path $temp -Destination $destPath -Force
        }
        Remove-Item $temp -Force -ErrorAction SilentlyContinue
        return $true
    } catch {
        return $false
    }
}

function Rename-ExtractedDir {
    param($ExtractDir, $Name, $DestPath)
    $extracted = Get-ChildItem -Path $ExtractDir -Directory | Select-Object -First 1
    if ($extracted -and (Split-Path $DestPath -Leaf) -ne $extracted.Name) {
        if (Test-Path $DestPath) { Remove-Item $DestPath -Recurse -Force }
        Rename-Item -Path $extracted.FullName -NewName (Split-Path $DestPath -Leaf) -Force
    }
}

function Start-BackgroundDownloads {
    param([array]$Downloads)

    if (-not $Downloads -or $Downloads.Count -eq 0) {
        return @()
    }

    $libPath = Join-Path $PSScriptRoot "lib.ps1"
    $initScript = [ScriptBlock]::Create(". '$libPath'")
    $jobs = @()

    foreach ($dl in $Downloads) {
        Write-Host "  [BACKGROUND] $($dl.name)..." -ForegroundColor Cyan
        $job = Start-Job -Name $dl.name -InitializationScript $initScript -ScriptBlock {
            param($Name, $Url, $Dest, $IsArchive)
            $ErrorActionPreference = "Continue"
            $result = Invoke-ManualDownload -Name $Name -Url $Url -Dest $Dest -IsArchive $IsArchive
            if ($result) { Write-Host "[OK] $Name" } else { Write-Host "[FAIL] $Name" }
            return $result
        } -ArgumentList $dl.name, $dl.url, $dl.dest, ($dl.archive -eq $true)
        $jobs += $job
    }

    while ($running = ($jobs | Where-Object { $_.State -eq 'Running' }).Count) {
        $completed = $jobs.Count - $running
        $pct = if ($jobs.Count -gt 0) { [math]::Round($completed / $jobs.Count * 100) } else { 0 }
        Write-Progress -Activity "Downloads" -Status "$completed/$($jobs.Count)" -PercentComplete $pct
        Start-Sleep -Milliseconds 500
    }
    Write-Progress -Activity "Downloads" -Completed

    $results = @()
    foreach ($job in $jobs) {
        $success = $false
        $output = $null
        try {
            $output = Receive-Job -Job $job -ErrorAction Stop
            if ($output -eq $true) { $success = $true }
        } catch {}
        $results += [PSCustomObject]@{ Name = $job.Name; Success = $success }
        Remove-Job -Job $job
    }

    return $results
}
