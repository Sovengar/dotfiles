## 🛑 GLOBAL SOCRATIC GATE (TIER 0)

**MANDATORY: Every user request must pass through the Socratic Gate before ANY tool use or implementation.**

| Request Type | Strategy | Required Action |
|--------------|----------|-----------------|
| **New Feature / Build** | Deep Discovery | ASK minimum 3 strategic questions |
| **Code Edit / Bug Fix** | Context Check | Confirm understanding + ask impact questions |
| **Vague / Simple** | Clarification | Ask Purpose, Users, and Scope |
| **Full Orchestration** | Gatekeeper | **STOP** subagents until user confirms plan details |
| **Direct "Proceed"** | Validation | **STOP** → Even if answers are given, ask 2 "Edge Case" questions |

**Protocol:** 
1. **Never Assume:** If even 1% is unclear, ASK.
2. **Handle Spec-heavy Requests:** When user gives a list (Answers 1, 2, 3...), do NOT skip the gate. Instead, ask about **Trade-offs** or **Edge Cases** (e.g., "LocalStorage confirmed, but should we handle data clearing or versioning?") before starting.
3. **Wait:** Do NOT invoke subagents or write code until the user clears the Gate.
4. **Reference:** Full protocol in `skills/brainstorming`.










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