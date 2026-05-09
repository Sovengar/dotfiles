# OpenSSH Server en Windows

## Server (esta máquina)

```powershell
# Como Administrador
.\setup\personal\setup-ssh-server.ps1
```

Esto instala OpenSSH Server, abre el firewall, genera clave SSH (`~/.ssh/jon`), y configura `authorized_keys` (incluyendo `administrators_authorized_keys` si el usuario es admin).

## Cliente (máquina que se conecta)

Copiar del server al cliente:

```
~/.ssh/jon       # privada (sin passphrase)
~/.ssh/jon.pub   # pública
```

En el `wezterm.lua` del cliente:

```lua
config.ssh_domains = {
  {
    name = '<alias>',
    remote_address = '<ip-del-server>',
    username = '<usuario>',
    ssh_option = {
      identityfile = wezterm.home_dir .. '/.ssh/jon',
    }
  },
}
```

Conectar:

```powershell
wezterm connect <alias>
```

## Troubleshooting

| Síntoma | Causa |
|---|---|
| Pide password | Public key no está en `authorized_keys` o el usuario es admin y falta `administrators_authorized_keys` |
| Pide passphrase | La clave privada tiene frase de paso. Quitarla: `ssh-keygen -p -f ~/.ssh/jon` |
| Connection refused | OpenSSH Server no instalado, sshd caído, o firewall bloquea puerto 22 |
