---
description: Clarify a request and draft the SWE issue
agent: idea-refiner
subtask: true
---

Follow the idea-refiner agent workflow for "$ARGUMENTS".

CONTEXT:
- Working directory: !`echo -n "$(pwd)"`
- Current project: !`echo -n "$(basename $(pwd))"`
- Change request: $ARGUMENTS

TASK:
Use the idea-refiner agent to produce `docs/planning/{NNNN}-{type}-{slug}/issue.md`.
- Resolve ambiguity first
- Identify the change type and bounded context
- Draft the issue in user-story format
- Do not write the implementation plan, tasks, or PRD here
