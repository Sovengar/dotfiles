Quizas investigador deberia usar project-analyzer o analyze-project-status en vez de sdd-explore

Aclarar la parte de como lintear (add skill) y como fixearlo, si meterlo en un comando fix-lint o en refactor o que...

Revisar que el skill-registry funcione bien, lo que hace es registrar todas las skills en engram y la IA ira ahi para saber si cargarla o no.
De esta forma me podria quitar lo de skills: en el frontmatter o en AGENTS.md, investigar......

Instalar opencode.nvim en lazyvim



Creo que no puedo hacer approval points dentro de un subAgent
Cuando termina swe-planner, me dice Inicia nueva sesión y dime que ejecute el plan withdrawal-daily-limit
*esto me lo deberia decir el orquestrador cuando apruebe lo que ha generado el swe-planner.

Cuando le doy correciones despues de haber generado un plan, no vuelve a ejecutar sw-planner
No me pide approval del plan, me dice que apruebe un PRD que ni existe
Crear todo en docs/specs, no en .specs/
Si corrijo una tarea, no corrige el plan.

Primero va el PRD, luego el implementation plan


Refactor agent

Hacer un test planner, esto es importante: Planea tareas pequeñas, cuanto mas pequeñas mas facil sera revisarlas.



Preguntarle por inspiracion intentional chasm kit
Preguntarle por inspiracion backlog.md


Tienes que poner un punto de control y empezar a hacer un mapa de herramientas a tu disposicion, pq tienes muchas y muchas deben ser llamadas solo desde otras.












My two main agents are:

Tower - mission command, minimal tools, plans, coordinates, delegates. This is my "claude take the wheel!" hands-off agent.

Wingman - has IDE MCP and most code-y tools. Instructions to follow orders and stay close (never leave your wingman). That's more my tactical companion when we need to deal with specific crap. Responds to "talk to me, Goose"

Some of the subs:
webbot - drives browser stuff. Pretty straightforward.
reporter - handles memory and vector dbs and such. "what were we doing?" and "remember this". Annoying, pedantic, detail-oriented
researcher - has a perplexity mcp and a search engine and the like. Total nerd.
tester - job is to pick apart the work, find the flaws, write the tests for them. This guy is a dick.
ops - database, running processes, docker, make sure shit's working. He's a grumpy curmudgeon.













## Fast Path

<!-- 
⚠️ **PENDIENTE DE IMPLEMENTAR**

La heurística actual es insuficiente: la complejidad real de una feature solo 
se revela durante la implementación. A priori puede parecer un simple "añadir 
un if" pero durante la ejecución se descubre que requiere:

- Polimorfismo
- Nuevas abstracciones
- Cambios que se propagan por todo el sistema (acoplamiento)
- Deuda técnica latente

**Heurística necesaria**:
- [ ] Definir métricas pre-ejecución (núm archivos, dependencias, scope)
- [ ] Definir métricas durante-ejecución (cambios en más de X archivos, refactors > Y)
- [ ] Threshold dinámico: si Task N requiere cambios en > X archivos no relacionados → Fast Path = false

**Habilitar cuando exista esta heurística robusta.**
-->

> No implementado actualmente. Futuro: para tareas triviales (log, rename, fix) se podrían reducir approvals.












## Resumen Final

### Fase 1: Planificación
```
Usuario: "quiero añadir soporte para impuestos variables por categoría"

1. Orchestrator → codebase-explorer (1 vez)
   → Explora código relacionado, identifica dependencias

2. Orchestrator → planner (loop)
   → Planner coordina brainstormer + architect (loop interno)
   → Planner genera .specs/variable-tax-by-category.md + .specs/variable-tax-by-category-prd.md
   → 💡 APPROVAL 1: Usuario aprueba PRD
   → Si no aprueba → iterar más

3. Orchestrator → task-decomposer (1 vez)
   → Genera .specs/variable-tax-by-category-tasks.md
   → 💡 APPROVAL 2: Usuario aprueba Tasks
   → Si no aprueba → regenerar

💡 Usuario approve
→ Commit: git add -A + git commit -m "chore: add <feature-name> plan"
→ "Inicia una nueva sesión para que el contexto esté limpio (/new en opencode, /clear en claude code, ...) y dime que ejecute el plan xxx"
```

### Fase 2: Ejecución

Indicar el archivo específico (escribir en el prompt):

```
"Ejecuta el plan variable-tax-by-category"
```

LEER spec + tasks + prd

Task 1: TestSubAgent → CodeSubAgent → Approval (×3)
Task 2: TestSubAgent → CodeSubAgent → Approval (×3)
Task 3: TestSubAgent → CodeSubAgent → Approval (×3)

RefactorAgent → Approval (×N)

feature-reviewer → Approval (PARALELO con code-reviewer)
code-reviewer → Approval
DocsAgent → Approval

push

CloserAgent → CHANGELOG + Rename to IMPLEMENTED
```

---

## Commits Esperados

```
feat(pricing): add TaxCategory enum with rate per category
feat(pricing): calculate total price with tax by category
feat(pricing): integrate tax calculation into PricingService
refactor(pricing): improve naming consistency
refactor(pricing): clean up test setup and assertions
chore(variable-tax-by-category): changelog, docs, code quality
```

### Output Visible (Markdown)

Cuando el CloserAgent termina, el OrchestratorAgent devuelve este output visible:

```markdown
═══════════════════════════════════════════════════════════════
                    WORKFLOW COMPLETED
═══════════════════════════════════════════════════════════════

Feature: nombre-de-la-feature
Status: ✅ SUCCESS / ⚠️ COMPLETED WITH ISSUES
Duration: XX minutes

───────────────────────────────────────────────────────────────
                       SUMMARY
───────────────────────────────────────────────────────────────

📋 Tasks: X/Y completed
  • Task 1: ✅ Completed
  • Task 2: ✅ Completed (IMPLEMENTED)
  • Task 3: 🔲 Pending (depends on: #2)

📁 Files:
  • Created: X files
  • Modified: X files

📝 Commits: X commits
  1. feat(<scope>): <mensaje>
  2. feat(<scope>): <mensaje>
  3. refactor(<scope>): <mensaje>
  ...

🧪 Tests:
  • Unit Tests: X added
  • System Tests: ✅ PASSED / ❌ FAILED

📖 Documentation:
  • Changelog: ✅ Updated
  • Docs: X files
  • ADR: ✅ Created / ❌ Not required

───────────────────────────────────────────────────────────────
                    CODE REVIEW SUMMARY
───────────────────────────────────────────────────────────────

🔴 Critical: X issues
🟠 High: X issues
🟡 Medium: X issues

User Decision: Approved / Asked to fix

Issues Found (if approved to continue):
- [CRITICAL] <issue>
- [HIGH] <issue>

───────────────────────────────────────────────────────────────
                    APPROVAL POINTS
───────────────────────────────────────────────────────────────

Total: X | Completed: X | Skipped: X

───────────────────────────────────────────────────────────────
                       NEXT STEP
───────────────────────────────────────────────────────────────

Feature lista para code review / PR

═══════════════════════════════════════════════════════════════
```