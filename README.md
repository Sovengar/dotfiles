# Dotfiles

Gestionados con [chezmoi](https://www.chezmoi.io).

Dos flujos independientes:

| Flujo | ¿Cuándo? | ¿Cómo? |
|-------|----------|--------|
| **Dotfiles** `(1)` | Cualquier máquina | `chezmoi apply` |
| **Formateo** `(2)` | Solo máquina nueva tras formateo | Scripts manuales en `windows/` |

---

## (1) Flujo Dotfiles — máquina ya configurada

```powershell
chezmoi apply
```

Aplica dotfiles, instala herramientas vía winget, configura PATH y menús contextuales.

---

## (2) Flujo Formateo — máquina nueva

SecciOnado en tres fases: antes de chezmoi → chezmoi apply → después de chezmoi.

### Fase A: Pre-chezmoi

```powershell
# 0. Sincronizar OneDrive (necesario para env.toml)
# 1. Instalar chezmoi
winget install --id twpayne.chezmoi -e --silent

# 2. Clonar configuración
chezmoi init https://github.com/Sovengar/dotfiles

# 3. WSL2: habilitar virtualización (REQUIERE ADMIN + REINICIO)
# Ejecutar como Administrador:
.\windows\setup-wsl-pre-reboot.ps1
# ... reiniciar ...

# 4. WSL2: instalar Ubuntu (después del reinicio)
.\windows\setup-wsl-post-reboot.ps1
```

> **Nota:** Si WSL2 ya está instalado en esta máquina, saltar pasos 3-4.

### Fase B: chezmoi apply

```powershell
# 5. Previsualizar cambios (OBLIGATORIO)
chezmoi diff
chezmoi apply --dry-run --verbose

# Si necesitas más detalle para diagnosticar algo:
# chezmoi apply --dry-run --verbose --debug

# 6. Aplicar solo si la previsualización es correcta
chezmoi apply --verbose
```

> ⚠️ **NUNCA ejecutes `chezmoi apply` sin `--dry-run` primero.**
> Para troubleshooting, agrega `--debug`.

### Fase C: Post-apply (pasos manuales)

Ejecutar en orden:

```powershell
# 7. Autenticación en herramientas CLI
gh auth login
opencode login

# 8. Docker Desktop — configurar integración WSL2
.\windows\setup-docker-post-apply.ps1

# 9. PowerToys — restaurar configuración desde GUI
# Abrir PowerToys Settings → General → Backup & Restore → RESTORE

# 10. Listary — re-introducir licencia (opcional)
```

> Para un checklist más detallado, ver: `windows/POST-FORMATEO.md`

---

## Estructura del repositorio

- `.chezmoiscripts/` — Scripts **automáticos** del flujo dotfiles (instalan apps, configuran PATH, etc.)
- `home/` — Dotfiles gestionados por chezmoi (se sincronizan a `~`)
  - `dot_*/` — Dotfiles raíz (`~/.bashrc`, `~/.gitconfig`, etc.)
  - `dot_config/` — Configuraciones en `~/.config`
- `windows/` — Scripts **manuales** del flujo formateo (NO ejecutados por chezmoi)
  - `setup-wsl-pre-reboot.ps1` — Activa virtualización para WSL2
  - `setup-wsl-post-reboot.ps1` — Instala WSL2 + Ubuntu
  - `setup-docker-post-apply.ps1` — Configura Docker Desktop + WSL2
  - `registry/` — Menús contextuales (aplicados automáticamente por `before_30-registry.ps1`)

## Requisitos

- OneDrive sincronizado (para `env.toml` con API keys)
- PowerShell 7
- GitHub CLI (`gh auth login` si el repo es privado)
