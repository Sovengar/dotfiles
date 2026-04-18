---
description: Sincroniza documentación del proyecto — crea y actualiza PRD, diagrams y README técnico
model: opencode/minimax-m2.5-free
subtask: true
---

# /sync-docs — Sincronizador de Documentación

$ARGUMENTS

## Propósito

Crea o actualiza documentación técnica del proyecto:
- Analiza el proyecto (codebase-explorer)
- Genera diagramas Mermaid en `docs/diagrams/mermaid/`
- Genera PRDs en `docs/prd/`
- Genera README en `docs/tech/`

## Pipeline

1. **codebase-explorer** → Análisis del proyecto
2. **technical-writer** → Genera diagrams, PRDs y README

## Opciones

| Comando | Descripción |
|---------|-------------|
| `/sync-docs` | Sincroniza toda la documentación |
| `/sync-docs --scope=prd` | Solo PRDs |
| `/sync-docs --scope=readme` | Solo README técnico |
| `/sync-docs --scope=diagrams` | Solo diagrams |

## Estado

Cada ejecución guarda manifest en `logs/pipeline_manifest.json` para recuperación.