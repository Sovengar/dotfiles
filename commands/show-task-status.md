---
name: show-task-status
description: >
  Muestra el estado de ejecución de la tarea activa: progreso por subtarea,
  qué agente está corriendo, qué está bloqueado y si la tarea puede darse
  por completada. Foco en estado runtime accionable, no en config estática.
agent: general
skills: session-manager, auto-preview
---

## Cuándo Usar

- Al retomar una sesión y necesitás saber dónde quedó la ejecución
- Cuando querés identificar qué agente está bloqueando el progreso
- Como checkpoint antes de decidir si intervenir, esperar o redirigir
- Para saber si la tarea puede darse por completada

## Flujo de Ejecución

### Paso 1: Obtener estado de ejecución

```bash
python session_manager.py status
python auto_preview.py status
```

### Paso 2: Reconstruir el árbol de la tarea

Identificar:
- Cuál es la **tarea raíz** (el objetivo que originó la sesión)
- Qué **subtareas** se derivaron y a qué agente se asignaron
- El **estado actual** de cada subtarea: completada, en progreso, bloqueada o pendiente
- Las **dependencias** entre subtareas (quién bloquea a quién)

### Paso 3: Calcular progreso y completabilidad

Con el árbol construido:
- Calcular progreso general como proporción de subtareas completadas
- Identificar el **cuello de botella actual** si existe
- Determinar si la tarea raíz puede completarse en el estado actual o está bloqueada









### Paso 2: Mostrar solo lo accionable

Formato de salida:

=== Tarea: [nombre de la tarea raíz] ===
Progreso: ████████░░ 75%

✅ [agente]  → [subtarea completada]
✅ [agente]  → [subtarea completada]
🔄 [agente]  → [subtarea en progreso] (60%) ← cuello de botella
⏳ [agente]  → bloqueado por [agente anterior]

Estado: EN PROGRESO — no completable hasta que [agente] termine

=== Preview ===
🌐 http://localhost:3000   → 💚 OK
                           → ❌ CAÍDO — ejecutar: preview-restart

#### Ejemplo:

=== Tarea: Módulo de Checkout ===
Progreso: ████████░░ 75%

✅ database-architect  → esquema de orders
✅ backend-specialist  → endpoints de pago
🔄 frontend-specialist → UI del carrito (60%) ← cuello de botella actual
⏳ test-engineer       → bloqueado por frontend

Estado: EN PROGRESO — no completable hasta que frontend termine

=== Preview ===
🌐 http://localhost:3000 → 💚 OK
                        → ❌ CAÍDO [comando para reiniciar]

### Paso 5: Sugerir acción si hay problemas

| Situación | Sugerencia |
|---|---|
| Agente estancado sin avance | `restart-agent {nombre}` |
| Preview caído | `preview-restart` o mostrar error |
| Todas las subtareas completas | Indicar que la tarea está lista para validación |
| Dependencia bloqueada | Mostrar qué necesita resolverse primero |

---

## Lo que este command NO muestra

- Tech stack ni configuración del proyecto (no cambia mid-ejecución)
- Path o nombre del proyecto (contexto que ya tenés)
- Cantidad de archivos creados o modificados (métrica sin valor decisional)
- Historial de sesiones anteriores (historia, no estado actual)

---

## Notas

- Si `session_manager.py` no está disponible, indicarlo con claridad en lugar de output vacío
- El output debe ser proporcional: si todo corre bien, 5 líneas alcanzan
- Si hay problemas, expandir solo la sección afectada con contexto y acción concreta
- El estado **"completable / no completable"** es la respuesta más importante que da este command