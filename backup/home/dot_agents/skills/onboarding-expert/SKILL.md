---
name: onboarding-expert
description: >
  Human-first project onboarding skill. Reconstructs real functional flows from code,
  organizes them by domain, and explains methods, validations, data, DB checks,
  external integrations, critical flags, and learning paths in a way a new human
  teammate can follow. Trigger: When the user asks for onboarding, project understanding,
  functional flow mapping, domain walkthroughs, entry-point tracing, or wants
  documentation for new developers based on real code behavior.
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "1.0"
---

## When to Use

- Cuando el usuario pide onboarding de un proyecto para personas nuevas
- Cuando hay que explicar "qué pasa realmente" en un endpoint, flujo, job o pantalla
- Cuando se necesita reconstruir flujos desde el código
- Cuando el stack importa menos que el comportamiento del sistema
- Cuando hay que mapear dominios y flujos en un modular monolith
- Cuando se quiere una ruta de aprendizaje para developers nuevos

## Critical Patterns

### 1. Human-first, code-backed
- Explica para humanos, no para agentes
- El código manda
- No infieras comportamiento sin evidencia
- Separa siempre:
  - **Evidencia confirmada**
  - **Hipótesis**

### 2. Flow over structure
NO hagas esto:
- "hay controllers, services y repositories"

SÍ haz esto:
- "el flujo entra por `X`, valida `A/B`, consulta `Y`, llama a `Z`, y devuelve `R`"

### 3. Domain-oriented organization
Si el repositorio parece modular monolith:
1. detecta dominios por paquetes/módulos
2. organiza por dominio
3. dentro de cada dominio, documenta flujos
4. dentro de cada flujo, baja a trazabilidad técnica

### 4. Dual naming
Cada flujo debe llevar:
- **Nombre funcional**: entendible por negocio/humano
- **Referencia técnica**: endpoint, clase, método, evento o pantalla

Ejemplo:
- Nombre funcional: `Depositar dinero`
- Referencia técnica: `PUT /{accountNumber}/deposit/{amount}/{currency}` → `DepositHttpController.deposit()` → `Deposit.handle()`

### 5. What must be extracted
En cada flujo, intenta identificar:

| Área | Qué extraer |
|------|-------------|
| Entrada | endpoint, handler, evento, job, UI |
| Métodos | controladores, serviços, use cases, helpers relevantes |
| Datos | DTOs, entities, requests, responses, flags |
| Validaciones | checks explícitos e implícitos |
| BD | tablas, columnas, condiciones, propósito |
| Integraciones | APIs, motores de reglas, colas, terceros |
| Decisiones | bifurcaciones de negocio |
| Conversión de valores | `true/false`, `1/0`, enums, nullables |
| Riesgos | gotchas, puntos de ruptura, diferencias entre nombre y comportamiento |

### 6. Pedagogy before exhaustiveness
Primero:
- qué hace el flujo
- cuándo se usa
- qué decide

Después:
- trazabilidad técnica exacta
- clases, métodos, campos, columnas, valores

### 7. Output discipline
La salida SIEMPRE debe ser Markdown navegable con tres niveles:
1. onboarding general del proyecto
2. onboarding por dominio
3. fichas detalladas por flujo

## Output Template

### Project Level

```md
# Onboarding del Proyecto

## Visión general
## Dominios detectados
## Puntos de entrada principales
## Dependencias críticas
## Ruta de aprendizaje recomendada
```

### Domain Level

```md
## Dominio: {name}

### Responsabilidad
### Entradas principales
### Objetos clave
### Flujos principales
### Integraciones
### Riesgos / gotchas
```

### Flow Level

```md
## Flujo: {functional_name}

### Referencia técnica
- Endpoint/UI/Evento:
- Clase:
- Método:

### Qué hace este flujo
### Cuándo se usa
### Punto de entrada
### Recorrido paso a paso
### Métodos involucrados
### Objetos y datos importantes
### Validaciones
### Consultas a BD
### Llamadas externas
### Decisiones de negocio
### Conversiones / equivalencias
### Puntos de ruptura / gotchas
### Evidencia confirmada
### Hipótesis
### Qué mirar primero
```

## Investigation Heuristics

### Señales de flujo
Busca:
- `Controller`, `Route`, `Handler`, `Endpoint`
- `UseCase`, `Service`, `ApplicationService`
- `Listener`, `Consumer`, `Job`, `Scheduler`
- `Repository`, `DAO`, queries inline
- clientes externos (`Client`, `Gateway`, `Adapter`)
- validaciones (`validate`, `check`, guards, conditionals)
- transformaciones DTO ↔ entity ↔ request externo

### Señales de datos críticos
Busca:
- booleans
- enums
- status codes
- columnas `enabled`, `active`, `flag`, `state`
- conversiones `0/1`, `Y/N`, `T/F`
- nulos con semántica
- defaults ocultos

### Señales de gotchas
Busca:
- nombres engañosos
- comportamiento distribuido en varios métodos
- validaciones no centralizadas
- datos del request comparados con BD
- integración externa condicionada por flags
- side effects no obvios

## Commands

```powershell
# Buscar puntos de entrada típicos
rg "Controller|Handler|Route|Endpoint|UseCase|Service|Listener|Job" .

# Buscar validaciones y guards
rg "validate|check|guard|if\s*\(|throw|assert" .

# Buscar repositorios, queries o acceso a datos
rg "Repository|DAO|select|insert|update|findBy|getBy|query" .

# Buscar integraciones externas
rg "Client|Gateway|Adapter|Corticon|Feign|RestTemplate|WebClient|Http" .

# Buscar flags/estados críticos
rg "enabled|active|flag|status|state|1|0|Y|N|true|false" .
```