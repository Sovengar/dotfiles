$script:SetupLogFile = "$env:TEMP\dotfiles-setup-summary.txt"

function Add-SetupLog {
    param([string]$Message)
    $line = "[$(Get-Date -Format HH:mm:ss)] $Message"
    Add-Content -Path $script:SetupLogFile -Value $line -Encoding UTF8
}

function Show-SetupLog {
    if (Test-Path $script:SetupLogFile) {
        Start-Process notepad -ArgumentList $script:SetupLogFile
    }
}

function Reset-SetupLog {
    if (Test-Path $script:SetupLogFile) {
        Remove-Item $script:SetupLogFile -Force
    }
}

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

function Get-StableWingetVersion {
    param([string]$AppId)
    $versions = winget show $AppId --versions 2>&1 | Select-String -Pattern "^\d+\.\d+\.\d+" | ForEach-Object { $_.Line.Trim() }
    if (-not $versions) { return $null }
    if ($versions.Count -le 1) { return $versions[0] }

    $groups = @{}
    foreach ($v in $versions) {
        $parts = $v -split '\.'
        $key = "$($parts[0]).$($parts[1])"
        if (-not $groups.ContainsKey($key)) { $groups[$key] = @() }
        $groups[$key] += $v
    }

    $sortedKeys = $groups.Keys | Sort-Object -Descending { [version]"$($_).0.0" }
    if ($sortedKeys.Count -ge 2) {
        return ($groups[$sortedKeys[1]] | Sort-Object -Descending)[0]
    }
    return $versions[0]
}

function Install-WingetApp {
    param([string]$AppId, [string]$Version)
    if ($Version) {
        Write-Host "    (installing version $Version...)" -ForegroundColor DarkGray
        winget install -e --id $AppId --version $Version --source winget --silent --accept-package-agreements --accept-source-agreements
    } else {
        Write-Host "    (attempting silent install...)" -ForegroundColor DarkGray
        winget install -e --id $AppId --source winget --silent --accept-package-agreements --accept-source-agreements
    }
    if ($LASTEXITCODE -eq 0 -or $LASTEXITCODE -eq -1978335189) {
        Write-Host "    [OK] $AppId" -ForegroundColor Green
        return $true
    }
    Write-Host "    (silent failed, retrying without --silent...)" -ForegroundColor DarkGray
    if ($Version) {
        winget install -e --id $AppId --version $Version --source winget --accept-package-agreements --accept-source-agreements
    } else {
        winget install -e --id $AppId --source winget --accept-package-agreements --accept-source-agreements
    }
    if ($LASTEXITCODE -eq 0 -or $LASTEXITCODE -eq -1978335189) {
        Write-Host "    [OK] $AppId" -ForegroundColor Green
        return $true
    }
    Add-SetupLog -Message "[FAIL] $AppId"
    Write-Host "    [FAIL] $AppId (ExitCode: $LASTEXITCODE)" -ForegroundColor Red
    return $false
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
            $stable = $false
        } else {
            $appId = $item.id
            $interactive = if ($item.interactive) { $true } else { $false }
            $stable = $item.version_strategy -eq "stable"
        }

        Write-Host "  Installing: $appId" -ForegroundColor Cyan
        if ($stable) { Write-Host "    (using latest stable version)" -ForegroundColor DarkGray }

        if ($interactive) {
            $response = Read-Host "  Install $appId? [Y/n]"
            if ($response -eq 'n' -or $response -eq 'N') {
                Add-SetupLog -Message "[SKIP] $appId"
                Write-Host "    [SKIP] $appId" -ForegroundColor Yellow
                $skipped++
                continue
            }
        }

        if ($stable) {
            $version = Get-StableWingetVersion -AppId $appId
            if ($version) {
                if (Install-WingetApp -AppId $appId -Version $version) { $success++ } else { $fail++ }
            } else {
                $fail++
            }
        } else {
            if (Install-WingetApp -AppId $appId) { $success++ } else { $fail++ }
        }
    }
    $parts = @("$success OK")
    if ($fail -gt 0) { $parts += "$fail FAIL" }
    if ($skipped -gt 0) { $parts += "$skipped SKIPPED" }
    Write-Host "  [$($parts -join ', ')]" -ForegroundColor Green
    if ($fail -gt 0 -or $skipped -gt 0) {
        Add-SetupLog -Message ">>> Result: $($parts -join ', ')"
    }
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
        return
    }

    $libPath = Join-Path $PSScriptRoot "lib.ps1"
    $initScript = [ScriptBlock]::Create(". '$libPath'")
    $jobs = @()

    foreach ($dl in $Downloads) {
        Write-Host "  [DOWNLOAD] $($dl.name)..." -ForegroundColor Cyan
        $jobs += Start-Job -Name $dl.name -InitializationScript $initScript -ScriptBlock {
            param($Name, $Url, $Dest, $IsArchive)
            $ErrorActionPreference = "Continue"
            $result = Invoke-ManualDownload -Name $Name -Url $Url -Dest $Dest -IsArchive $IsArchive
            if ($result) { "[OK] $Name" } else { "[FAIL] $Name" }
        } -ArgumentList $dl.name, $dl.url, $dl.dest, ($dl.archive -eq $true)
    }

    foreach ($job in $jobs) {
        $null = Wait-Job $job -Timeout 120
        $output = Receive-Job $job
        if ($job.State -eq 'Completed' -and $output -match '\[OK\]') {
            Write-Host "    $output" -ForegroundColor Green
        } else {
            Write-Host "    $output" -ForegroundColor Red
            Add-SetupLog -Message "[FAIL] Download: $($job.Name)"
        }
        Remove-Job $job -Force
    }
}
