# Gotty - Compartir terminal via navegador

Herramienta para compartir sesiones de terminal a través de un navegador web.

## Instalacion

```powershell
# Windows (scoop)
scoop install gotty

# Windows (Go)
go install github.com/yudai/gotty@latest
```

## Uso

```powershell
gotty -w bash                    # Puerto 8080 por defecto
gotty -w -p 9000 bash         # Puerto personalizado
gotty --credential user:pass bash  # Auth basico
gotty --readonly bash           # Solo lectura (recomendado para demos)
gotty --title "Servidor Dev" htop
```

→ Acceder en `http://localhost:8080`

## Casos de uso

- **Demos remotas**: Muestra tu terminal en tiempo real a alguien en otra ubicacion
- **Acceso sin SSH**: Entra a un servidor desde el navegador sin necesidad de SSH
- **Debugging compartido**: Comparte una sesion de debugging con otro developer

## Seguridad

- NO expongas a internet sin credenciales
- Usa `--readonly` cuando no necesites interaccion
- Considera usar con VPN o tunnel local (localtunnel, ngrok)