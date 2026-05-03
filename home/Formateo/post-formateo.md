# Checklist Post-Formateo

## Paso 0: Pre-requisitos manuales
- [ ] Iniciar sesión en OneDrive (sincronizar)
- [ ] Iniciar sesión en Dropbox (si es necesario para accesos directos de startup)
- [ ] Si el repo de chezmoi es privado: iniciar sesión en GitHub CLI antes de continuar

## Paso 1: Cargar variables de entorno
Desde PowerShell 7:

```powershell
$envFile = "$HOME\OneDrive\Formateo\env.toml"
if (Test-Path $envFile) {
    # Leer API keys y exportarlas al sistema
    $content = Get-Content $envFile -Raw
    if ($content -match 'firecrawl\s*=\s*"([^"]+)"') {
        [System.Environment]::SetEnvironmentVariable("FIRECRAWL_API_KEY", $matches[1], "User")
    }
    Write-Host "Variables de entorno cargadas." -ForegroundColor Green
}
```

## Paso 2: Instalar chezmoi
```powershell
winget install --id twpayne.chezmoi -e --silent
```

## Paso 3: Clonar configuración (sin aplicar aún)
```powershell
chezmoi init https://github.com/Sovengar/dotfiles
```

## Paso 4: Previsualizar cambios (OBLIGATORIO)
> ⚠️ **Este paso es obligatorio.** Nunca apliques sin verificar primero.

```powershell
# Ver diferencias que chezmoi va a hacer
chezmoi diff

# Simular aplicación completa (incluyendo scripts run_once_)
chezmoi apply --dry-run
```

Revisa la salida. Si ves algo inesperado, corrígelo antes de continuar.

## Paso 5: Aplicar configuración
```powershell
# Solo si el --dry-run fue correcto
chezmoi apply
```

## Paso 6: Restaurar known_hosts para SSH (si aplica)
Si usas la configuración SSH de WezTerm, copia tu `known_hosts` de respaldo:

```powershell
$oneDriveSsh = "$HOME\OneDrive\Formateo\.ssh"
$localSsh = "$HOME\.ssh"
if (-not (Test-Path $localSsh)) { New-Item -ItemType Directory -Path $localSsh -Force | Out-Null }
if (Test-Path "$oneDriveSsh\known_hosts") {
    Copy-Item "$oneDriveSsh\known_hosts" "$localSsh\known_hosts" -Force
    Write-Host "known_hosts restaurado." -ForegroundColor Green
}
```

> **Nota:** El script `run_once_after_40-ssh-setup.ps1` de chezmoi también intentará hacer esto automáticamente. Este paso manual es solo si prefieres hacerlo antes del apply.

## Paso 7: Configurar SSH Server (solo en máquina remota)

Si esta máquina va a recibir conexiones SSH (VPS, PC de trabajo, etc.):

```powershell
.\windows\setup-ssh-server.ps1
```

> **En máquina local** que solo se conecta a servidores: no necesitas este script.
> La clave `~/.ssh/jon` se genera automáticamente en el primer `chezmoi apply`.

## Paso 8: Acciones manuales post-chezmoi
- [ ] **PowerToys**: Abrir app → Settings → General → Backup & Restore → RESTORE
- [ ] **Listary**: Re-introducir licencia si aplica (opcional)
- [ ] **GitHub CLI**: `gh auth login` si es repo privado
- [ ] **Agentes AI**: Re-autenticar si es necesario (opencode, codex, gemini, copilot)
- [ ] **WSL**: Si es la primera vez, `wsl --install` y reiniciar
- [ ] **Docker Desktop**: Iniciar, configurar y habilitar integración WSL2

## Paso 9: Verificaciones
- [ ] `starship --version` responde
- [ ] `lazygit --version` responde
- [ ] `gh auth status` muestra tu usuario
- [ ] `docker --version` responde
- [ ] `wsl --status` muestra WSL2 activo
- [ ] Windows Terminal abre con tu configuración
- [ ] PowerShell 7 tiene tu perfil
- [ ] SSH: `ssh -i ~/.ssh/jon buble@157.180.112.216` conecta (o `wezterm connect Jon`)

---

## Solución de problemas

### Si .env.toml no se encuentra
El archivo debe estar sincronizado en OneDrive. Verifica que `C:\Users\buble\OneDrive\Formateo\env.toml` existe.

### Si el email no se detecta
Puedes introducirlo manualmente cuando chezmoi te lo pida, o verificar que `env.toml` tiene la sección `[git]` con `email = "tu-email"`.

### Si Firecrawl no se configura
Verifica que la variable está exportada correctamente:
```powershell
$env:FIRECRAWL_API_KEY
```
Si está vacía, cópiala desde `env.toml` manualmente:
```powershell
[System.Environment]::SetEnvironmentVariable("FIRECRAWL_API_KEY", "fc-tu-key-aqui", "User")
```

### Si WezTerm no muestra la conexión SSH
1. Verifica que `env.toml` tiene la sección `[ssh]` completa:
   ```toml
   [ssh]
   host = "157.180.112.216"
   username = "buble"
   identity = "jon"
   ```
2. Ejecuta `chezmoi apply` para regenerar los templates
3. Verifica que `~/.ssh/jon` existe (se genera automáticamente en el primer `chezmoi apply`)
4. Si la clave es nueva, copia la pública al servidor remoto:
   ```powershell
   Get-Content ~/.ssh/jon.pub | Set-Clipboard
   # Pégalo en ~/.ssh/authorized_keys del servidor remoto
   ```

### Si known_hosts no se restaura
Asegúrate de que el archivo existe en OneDrive:
```powershell
Test-Path "$HOME\OneDrive\Formateo\.ssh\known_hosts"
```
Si no existe, se creará automáticamente al conectarte por primera vez. Acepta el fingerprint cuando SSH te lo pida, luego copia el archivo a OneDrive para futuros formateos:
```powershell
$oneDriveSsh = "$HOME\OneDrive\Formateo\.ssh"
if (-not (Test-Path $oneDriveSsh)) { New-Item -ItemType Directory -Path $oneDriveSsh -Force | Out-Null }
Copy-Item "$HOME\.ssh\known_hosts" "$oneDriveSsh\known_hosts" -Force
```

### Si PowerToys no restaura
PowerToys requiere importación manual desde GUI. No hay forma de automatizar esto.
1. Abre PowerToys
2. Ve a Settings → General → Backup & Restore
3. Busca tu archivo de backup en Documents\PowerToys\Backup
4. Pulsa RESTORE

---

## Notas adicionales

- Este archivo debe quedarse en OneDrive para no perderse tras el formateo
- NUNCA subas `env.toml` a Git aunque el repo sea público
- El archivo `.gitignore` del repo de chezmoi ignora `env.toml`
- Si tienes otras API keys, añádelas en `[api_keys]` de este archivo