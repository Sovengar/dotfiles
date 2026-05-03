#!/usr/bin/env pwsh
param(
    [Parameter(ValueFromRemainingArguments = $true)]
    $Args
)

# Ruta absoluta del binario de OpenCode dentro de WSL2
$opencodePath = "/home/jon/.opencode/bin/opencode"

# Construir el comando final
$command = "$opencodePath $Args"

# Ejecutar dentro de WSL2 usando bash -lc para cargar entorno
wsl bash -lc "$command"