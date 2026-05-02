# run_once_before_01-install-packages.ps1
# Installs all apps via winget, npm, and go

$ErrorActionPreference = "Continue"
$wingetApps = @(
    "RARLab.WinRAR",
    "Bopsoft.Listary",
    "Skillbrains.Lightshot",
    "Discord.Discord",
    "Microsoft.PowerToys",
    "Microsoft.WindowsTerminal",
    "wez.wezterm",
    "VideoLAN.VLC",
    "AIMP.AIMP",
    "Plex.Plex",
    "Guru3D.Afterburner",
    "BitSum.ProcessLasso",
    "Reshade.Setup.AddonsSupport",
    "Guru3D.RTSS",
    "Valve.SteamLink",
    "Valve.Steam",
    "Dropbox.Dropbox",
    "Google.GoogleDrive",
    "Microsoft.OneDrive",
    "Microsoft.PowerShell",
    "DEVCOM.JetBrainsMonoNerdFont",
    "Canonical.Ubuntu",
    "flux.flux",
    "Malwarebytes.Malwarebytes",
    "AutoHotkey.AutoHotkey",
    "BartelsMedia.MacroRecorder",
    "Git.Git",
    "Microsoft.VisualStudioCode",
    "JetBrains.IntelliJIDEA",
    "Starship.Starship",
    "CoreyButler.NVMforWindows",
    "EclipseAdoptium.Temurin.21.JDK",
    "Docker.DockerDesktop",
    "PuTTY.PuTTY",
    "GitHub.cli",
    "JesseDuffield.lazygit",
    "cjpais.Handy",
    "OpenAI.Codex"
)

foreach ($app in $wingetApps) {
    Write-Host "Installing: $app" -ForegroundColor Cyan
    $proc = Start-Process "winget.exe" -ArgumentList "install -e --id $app --silent --accept-package-agreements --accept-source-agreements" -NoNewWindow -PassThru -Wait
    if ($proc.ExitCode -eq 0 -or $proc.ExitCode -eq -1978335189) {
        Write-Host "  [OK] $app" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] $app (ExitCode: $($proc.ExitCode))" -ForegroundColor Red
    }
}

# Maven
winget install Apache.Maven
$mavenPath = "$env:USERPROFILE\Dropbox\DEV\tools\Maven"
[System.Environment]::SetEnvironmentVariable("MAVEN_HOME", $mavenPath, "User")
# NOTA: No añadimos %MAVEN_HOME%\bin al PATH porque los bins se consolidan en ~/.local/bin via symlinks

# Node.js via NVM
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
try {
    nvm install 20.19.0
    nvm use 20.19.0
    Write-Host "[OK] Node.js installed via NVM" -ForegroundColor Green
} catch {
    Write-Host "[FAIL] Node.js via NVM" -ForegroundColor Red
}

# Go
winget install --id=GoLang.Go -e
# NOTA: No añadimos ~/go/bin al PATH porque los bins se consolidan en ~/.local/bin via symlinks

# Global npm packages
npm install -g opencode-ai @openai/codex backlog.md @devcontainers/cli

# Go tools
go install github.com/edouard-claude/snip/cmd/snip@latest
go install github.com/sorenisanerd/gotty@latest

# Firecrawl CLI
npx -y firecrawl-cli@latest init --all

Write-Host "Package installation complete." -ForegroundColor Green
