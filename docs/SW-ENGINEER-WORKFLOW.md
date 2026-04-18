Quizas investigador deberia usar project-analyzer o analyze-project-status en vez de sdd-explore

Aclarar la parte de como lintear (add skill) y como fixearlo, si meterlo en un comando fix-lint o en refactor o que...

Revisar que el skill-registry funcione bien, lo que hace es registrar todas las skills en engram y la IA ira ahi para saber si cargarla o no.
De esta forma me podria quitar lo de skills: en el frontmatter o en AGENTS.md, investigar......

Instalar opencode.nvim en lazyvim






Mover plannification-phase a swe-planner, quizas crear planner tmb, revisa el que tienes en PENDING...



Creo que no puedo hacer approval points dentro de un subAgent
Cuando termina swe-planner, me dice Inicia nueva sesión y dime que ejecute el plan withdrawal-daily-limit
*esto me lo deberia decir el orquestrador cuando apruebe lo que ha generado el swe-planner.

Creo que voy a quitar la decision matrix, que delege siempre a los subagentes y ahi implementas la logica, low work skip phase


Cuando le doy correciones despues de haber generado un plan, no vuelve a ejecutar sw-planner
No me pide approval del plan, me dice que apruebe un PRD que ni existe
Crear todo en docs/specs, no en .specs/
Si corrijo una tarea, no corrige el plan.




Refactor agent

Comando Usecase analyzer from endpoint
Comando /Onboarding 
Comando /prd

Hacer un test planner, esto es importante: Planea tareas pequeñas, cuanto mas pequeñas mas facil sera revisarlas.



Preguntarle por inspiracion intentional chasm kit
Preguntarle por inspiracion backlog.md








My two main agents are:

Tower - mission command, minimal tools, plans, coordinates, delegates. This is my "claude take the wheel!" hands-off agent.

Wingman - has IDE MCP and most code-y tools. Instructions to follow orders and stay close (never leave your wingman). That's more my tactical companion when we need to deal with specific crap. Responds to "talk to me, Goose"

Some of the subs:
webbot - drives browser stuff. Pretty straightforward.
reporter - handles memory and vector dbs and such. "what were we doing?" and "remember this". Annoying, pedantic, detail-oriented
researcher - has a perplexity mcp and a search engine and the like. Total nerd.
tester - job is to pick apart the work, find the flaws, write the tests for them. This guy is a dick.
ops - database, running processes, docker, make sure shit's working. He's a grumpy curmudgeon.








### Delegation Rules Matrix

| Action | Inline | Delegate |
|--------|--------|----------|
| Read to decide/verify (1-3 files) | ✅ | — |
| Read to explore/understand (4+ files) | — | ✅ |
| Read as preparation for writing | — | ✅ together with write |
| Write atomic (one file, mechanical) | ✅ | — |
| Write with analysis (multiple files, new logic) | — | ✅ |
| Bash for state (git status, git branch) | ✅ | — |
| Bash for execution (test, build) | — | ✅ |
| Approval point interaction | ✅ | — |
| Planning (new feature) | — | ✅ **task** to swe-planner (**MUST** after user confirms) |
| Planning (refine existing specs) | — | ✅ **task** to swe-planner |
| Planning refinement loop | — | ✅ **task** (sync) |
| Planning (execute existing specs) | ✅ | — |
| Investigate bug/error/problem | — | ✅ **task** to problem-finder |
| Implement spec | — | ✅ **task** to swe-executor (sync) |
| Code review (feature + quality) | — | ✅ **task** to swe-reviewer |
| Docs generation | — | ✅ **task** (sync) |

**DO NOT use rigid rules**. For trivial tasks, handle them directly using the delegation matrix above.

**CRITICAL Context-based rules:**
- User confirms a feature proposal → **swe-planner NOW** (do NOT write specs yourself)
- User says "ok proceed" or "me interesa" → **swe-planner NOW**
- User wants to plan/create specs → swe-planner
- User wants to refine/review specs → swe-planner
- User wants to execute feature → check specs, then decide
- User reporting bug/error/problem → problem-finder
- User asking about code quality → swe-reviewer
- User asking about implementation details → swe-executor
- User asking "does this work?" → verificar y responder directamente
- User needs help defining an idea → brainstormer
- Decide by context when unclear




## Stash Guard

Before delegating to any swe sub-agent (swe-planner, swe-executor, swe-reviewer, swe-closer), check git status:

1. Run: `git status --porcelain`
2. If clean → proceed normally
3. If NOT clean → 
   a. NOTIFY user: "Tienes cambios sin commit. Voy a hacer stash y cambiar a la rama de feature."
   b. Run: `git stash push -m "wip: $(date +%Y%m%d-%H%M%S) - swe-workflow"`
   c. Run: `git checkout feat/{feature-name}` (or switch to the branch for this workflow)

This ensures uncommitted changes are safely stored before starting work.

---




## 15. Plan de Implementación (Checklist)

- [ ] **Fase 1**: Crear `agents/sw-engineer.md` (instrucciones del orquestador).
- [ ] **Fase 2**: Crear `agents/implementation-agent.md`.
- [ ] **Fase 3**: Crear `agents/feature-reviewer.md`.
- [ ] **Fase 4**: Crear `agents/docs-agent.md`.
- [ ] **Fase 5**: Crear `agents/closer-agent.md`.
- [ ] **Fase 6**: Testing completo (end-to-end) con un feature simple.
- [ ] **Fase 7**: Actualizar `AGENTS.md` con trigger para `sw-engineer`.






## Phase 1: Planning

```
1. ORCHESTRATOR → SDD-INIT (if needed)

2. ORCHESTRATOR → codebase-explorer (1 time)
                  ↓
3. ORCHESTRATOR → swe-planner (coordina)
    ├── brainstormer (invoked by swe-planner)
    └── architect (invoked by swe-planner)
    ↓
    💡 Ask user: "¿Este spec cubre lo que necesitas?"
    ↓ (if user approves)
4. ORCHESTRATOR → task-decomposer (1 time)
    ↓
    💡 Ask user: "¿Estas tareas son las correctas?"
    ↓ (if user approves)
5. End → `.specs/` files generated
6. Commit without push
7. Output: "Inicia nueva sesión (/new) y dime que ejecute el plan <slug>"
```

1. **init**: `sdd-init` (silent, if needed).
2. **explore**: Orchestrator invokes `codebase-explorer` (1 time, sync).
3. **Plan (external loop)**:
   - Orchestrator invokes `swe-planner`, which works with `brainstormer` + `architect` as needed
   - Planner returns result to Orchestrator
   - Orchestrator decides if there are more iterations (based on user feedback)
   - Ask user: "¿Este spec cubre lo que necesitas?"
   - If rejects → loop again.
4. **tasks (1 time, sync)**: Orchestrator invokes `task-decomposer`
   - Ask user: "¿Estas tareas son las correctas?"
   - If rejects → return to Phase 3
5. **End**: Files generated in `.specs/`
6. **Commit**: `git add .specs/ && git commit -m "chore: add <feature-name> plan"`
7. **Output**: "Inicia nueva sesión (/new) y dime que ejecute el plan <slug>"


## Phase 2: Execution
```
1. READ .specs/{slug}.md + .specs/{slug}-tasks.md + .specs/{slug}-prd.md
2. CREATE branch: feat/<feature-name>

🚨 REGLA: NO borrar tests — si es necesario, reiniciar tarea

Loop per task:
├── TestSubAgent → write test (RED)
│   💡 Ask user: "¿El test prueba lo que necesitamos?"
│   Skip: DUPLICATE, NOT_APPLICABLE
├── CodeSubAgent → write code → test passes (GREEN)
│   💡 Ask user: "¿El código hace lo que el test dice?"
│   Skip: DUPLICATE
├── Optional refactor
│   💡 Ask user: "¿El código está limpio?"
│   Skip: NOT_APPLICABLE, USER_WAIVED
└── Commit on GREEN
```

## Phase 4: Review
```
OrchestratorAgent (coordina el review)

├── feature-reviewer (PARALELO)
│   ├── Verify functionality (Does it do what spec says?)
│   ├── Verify tests pass
│   ├── Verify commits follow conventional commits
│   ├── Verify standards (naming, structure, architecture)
│   └── Verify scope: logic, functionality, architecture

├── code-reviewer (PARALELO)
│   ├── Static analysis (lint, sonar, etc.)
│   ├── Security scan
│   ├── Performance hotspots
│   ├── Code style y patrones
│   └── Verify scope: quality, performance, security, style
```




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

Cuando el CloserAgent termina, el OrchestratorAgent devuelve un resumen estructurado en markdown:

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