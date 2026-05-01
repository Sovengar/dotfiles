---
description: Generate the SWE implementation plan
agent: planner
subtask: true
---

Follow the planner agent workflow for "$ARGUMENTS".

CONTEXT:
- Working directory: !`echo -n "$(pwd)"`
- Current project: !`echo -n "$(basename $(pwd))"`
- Change target: $ARGUMENTS

TASK:
Use the planner agent to produce `docs/planning/{NNNN}-{slug}/impl-plan.md` for the current change.
- Read the relevant issue/spec context from `docs/planning/{NNNN}-{slug}/`
- Synthesize the implementation plan in the repo's standard structure
- Keep scope, tradeoffs, and risks explicit
- Do not write tasks or PRD content here
