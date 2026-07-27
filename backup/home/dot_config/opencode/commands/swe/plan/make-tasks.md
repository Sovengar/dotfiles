---
description: Break an implementation plan into executable tasks
agent: task-decomposer
subtask: true
---

Follow the task-decomposer agent workflow for "$ARGUMENTS".

CONTEXT:
- Working directory: !`echo -n "$(pwd)"`
- Current project: !`echo -n "$(basename $(pwd))"`
- Target change: $ARGUMENTS

TASK:
Use the task-decomposer agent to produce `docs/planning/{NNNN}-{slug}/tasks.md`.
- Read the matching `impl-plan.md` and optional `spec.md`
- Map each acceptance criterion to phases and tasks
- Ensure every task is small and verifiable
- Do not write issue, plan, or PRD content here
