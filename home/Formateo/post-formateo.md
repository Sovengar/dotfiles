# Checklist Post-Formateo

## Paso 0: Pre-requisitos manuales
- [ ] Iniciar sesion en OneDrive si necesitas la base KeePassXC `BBDD.kdbx`
- [ ] Iniciar sesion en Dropbox si es necesario para accesos directos de startup
- [ ] Si el repo de chezmoi es privado: iniciar sesion en GitHub CLI antes de continuar

## Paso 1: Instalar herramientas base
Desde PowerShell 7:

```powershell
winget install --id twpayne.chezmoi -e --silent
winget install --id KeePassXCTeam.KeePassXC -e --silent
winget install --id FiloSottile.age -e --silent
winget install --id Mozilla.SOPS -e --silent
```

## Paso 2: Restaurar la clave age
La clave privada vive en KeePassXC:

```text
Database/SO/chezmoi age identity
```

La key debe estar en Notes/Anotaciones. `chezmoi apply` ejecuta `run_before_00-restore-age-key.*` y la restaura en:

```text
~/.config/sops/age/keys.txt
```

Si quieres hacerlo manualmente antes del apply, crea ese archivo con el contenido completo de la nota y permisos privados.

## Paso 3: Clonar configuracion sin aplicar aun

```powershell
chezmoi init https://github.com/Sovengar/dotfiles
```

## Paso 4: Previsualizar cambios
Este paso es obligatorio. Nunca apliques sin verificar primero.

```powershell
chezmoi diff
chezmoi apply --dry-run
```

Revisa la salida. Si ves algo inesperado, corrigelo antes de continuar.

## Paso 5: Aplicar configuracion

```powershell
chezmoi apply
```

## Paso 6: SSH client
`windows/setup/personal/ssh-client-setup.ps1` genera `~/.ssh/jon` si no existe.
Si `secrets/dotfiles.sops.yaml` contiene `[ssh].host`, el script genera `known_hosts` con `ssh-keyscan`.

## Paso 7: Configurar SSH Server
Solo en una maquina que va a recibir conexiones SSH:

```powershell
.\windows\setup-ssh-server.ps1
```

En una maquina local que solo se conecta a servidores, no necesitas este script.

## Paso 8: Acciones manuales post-chezmoi
- [ ] PowerToys: abrir app, Settings, General, Backup & Restore, RESTORE
- [ ] Listary: re-introducir licencia si aplica
- [ ] GitHub CLI: `gh auth login` si es repo privado
- [ ] Agentes AI: re-autenticar si es necesario (opencode, codex, gemini, copilot)
- [ ] WSL: si es la primera vez, `wsl --install` y reiniciar
- [ ] Docker Desktop: iniciar, configurar y habilitar integracion WSL2

## Paso 9: Verificaciones
- [ ] `starship --version` responde
- [ ] `lazygit --version` responde
- [ ] `gh auth status` muestra tu usuario
- [ ] `docker --version` responde
- [ ] `wsl --status` muestra WSL2 activo
- [ ] Windows Terminal abre con tu configuracion
- [ ] PowerShell 7 tiene tu perfil
- [ ] SSH: `ssh -i ~/.ssh/jon usuario@host` conecta, o `wezterm connect Jon`

---

## Solucion de problemas

### Si SOPS no descifra
Verifica que existe la clave age:

```powershell
Test-Path "$HOME\.config\sops\age\keys.txt"
```

Si no existe, abre KeePassXC y revisa la entrada `SO/chezmoi age identity`.

### Si el email no se detecta
Edita el secreto cifrado:

```powershell
sops secrets\dotfiles.sops.yaml
```

Debe existir:

```yaml
git:
  email: tu-email@example.com
```

### Si Firecrawl no se configura
Verifica que el secret cifrado contiene:

```yaml
api_keys:
  firecrawl: fc-tu-key-aqui
```

Despues resetea el script si ya corrio una vez:

```powershell
chezmoi state delete-bucket --bucket=scriptState
chezmoi apply
```

### Si WezTerm no muestra la conexion SSH
Verifica que `secrets/dotfiles.sops.yaml` contiene la seccion `[ssh]`/`ssh` completa:

```yaml
ssh:
  host: 157.180.112.216
  username: buble
  identity: jon
```

Luego ejecuta `chezmoi apply` para regenerar templates.

### Si known_hosts no se genera
Verifica que `sops`, `ssh-keyscan` y `ssh.host` funcionan:

```powershell
sops --decrypt --output-type json secrets\dotfiles.sops.yaml
ssh-keyscan tu-host
```

### Si PowerToys no restaura
PowerToys requiere importacion manual desde GUI.

---

## Notas adicionales
- Este archivo debe quedarse en OneDrive para no perderse tras el formateo.
- Nunca subas `~/.config/sops/age/keys.txt` a Git.
- `secrets/dotfiles.sops.yaml` si se sube a Git porque esta cifrado.
- Tras `opencode login`, actualiza `opencode.config` con `sops secrets/dotfiles.sops.yaml`.
