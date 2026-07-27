---
description: Advanced codebase analysis, architecture mapping, and feasibility research
agent: codebase-explorer
subtask: true
---

# Explore Codebase Command

CONTEXT:
- Working directory: !`echo -n "$(pwd)"`
- Current project: !`echo -n "$(basename $(pwd))"`
- Arguments: $arguments

TASK:
Execute analysis based on $arguments. Use the codebase-explorer agent to explore the codebase according to the provided arguments:
- scope: Path to analyze (e.g., `src/`, `packages/api/`)
- --audit: Run audit mode (vulnerabilities, anti-patterns, code smells)
- --map: Run mapping mode (dependency maps, data flow)
- --feasible: Check feasibility of a feature
- --area: Focus area (`structure`, `dependencies`, `code-quality`, `config`)
- --depth: Analysis depth (`shallow`, `medium`, `deep`)
- --format: Output format (`text`, `json`, `markdown`, `html`)
- --severity: Filter by severity (`low`, `medium`, `high`)
- --security: Run security-focused audit
- --data-flow: Include data flow analysis

Follow the codebase-explorer agent workflow:
1. Scan - Explore directory structure and find entry points
2. Identify - Detect language, framework, and toolchain
3. Analyze - Review architecture, patterns, and dependencies
4. Report - Deliver structured findings with recommendations

ENGRAM PERSISTENCE (artifact store mode: engram):
Save exploration results:
  mem_save(title: "explore-codebase/$ARGUMENTS", topic_key: "explore-codebase/$ARGUMENTS", type: "architecture", project: "{project}", content: "{analysis result}")

Return structured analysis with: findings, recommendations, risks identified, and next steps.