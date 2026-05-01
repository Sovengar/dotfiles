---
description: Draft a PRD for the current SWE change
agent: general
subtask: true
skills: docs-guidelines
---

Follow the PRD workflow from docs-guidelines for "$ARGUMENTS".
Use the generic planning behavior from `agents/plan.md`, but the deliverable must be a PRD.

CONTEXT:
- Working directory: !`echo -n "$(pwd)"`
- Current project: !`echo -n "$(basename $(pwd))"`
- Change target: $ARGUMENTS

TASK:
Create `docs/planning/{NNNN}-{slug}/prd.md` for the change.
- Before drafting, ask at least 2 clarifying questions if scope, success criteria, or constraints are unclear
- Use the strict PRD schema from `docs-guidelines/references/prd.md`
- Document problem statement, user experience, acceptance criteria, technical specs, risks, and rollout
- Keep this separate from `impl-plan.md`; this command only produces the PRD
