---
name: lint
description: Discover and run the project linter, then output a prioritised report with action plans
---

You are a senior engineer performing a linting audit on this codebase. Follow these steps exactly.

## Step 1 — Discover how linting works in this project

Search for linting configuration and instructions in this order:
1. `AGENTS.md`, `CLAUDE.md`, `COPILOT-INSTRUCTIONS.md`, `.github/copilot-instructions.md`, or any file in `.opencode/` that describes project commands
2. `package.json` → look for `scripts.lint`, `scripts.check`, or similar
3. Config files: `.eslintrc*`, `eslint.config.*`, `sonar-project.properties`, `.pylintrc`, `pyproject.toml` (`[tool.ruff]`, `[tool.pylint]`), `golangci.yml`, `Makefile` targets named `lint`
4. `README.md` — search for a "Linting" or "Quality" section

From this, extract the exact command(s) needed to run the linter and note the output format.

## Step 2 — Run the linter

Execute the discovered lint command. Capture the full stdout and stderr.

- If the command fails to install or is not found, attempt the most common default for the detected stack:
  - JS/TS → `npx eslint .`
  - Python → `ruff check .` or `pylint **/*.py`
  - Go → `golangci-lint run`
  - Rust → `cargo clippy`
  - Java → `investigate if sonar or other options are configured`
- Do NOT fix any issues yet; only collect the raw output.

## Step 3 — Parse and classify issues

Read every issue from the linter output and classify each one into exactly one severity:

| Severity | Criteria |
|---|---|
| **CRITICAL** | Security vulnerabilities, cyclomatic complexity violations, null-dereference risks, data loss patterns, blocking async calls, or anything the linter rates as `error` / `blocker` |
| **HIGH** | Deprecated APIs, missing error handling, large function/file size violations, `warning`-level security rules |
| **MEDIUM** | Code duplication, magic numbers/strings, naming convention violations, missing type annotations |
| **LOW** | Style, formatting, minor readability issues |

Group identical rule violations together under a single entry (e.g. "no-unused-vars × 12 occurrences"). Sort groups within each severity by **occurrence count, descending**.

## Step 4 — Generate an action plan per issue group

For each group produce a concrete, actionable plan (one sentence). Examples:
- Cyclomatic complexity → "Decompose into smaller functions following the Single Responsibility Principle"
- Duplicated strings → "Extract to a named constant or enum at the module level"
- Missing error handling → "Wrap with try/catch and propagate or log the error with context"
- Unused variable → "Remove the declaration or prefix with `_` if intentional"
- Long function → "Split at natural abstraction boundaries; aim for ≤20 lines per function"

## Step 5 — Print the final report

Output the report in exactly this format and nothing else after the separator:

---

## Lint Report — `<project name>` · <date>
**Linter:** <tool and version>  **Command:** `<command run>`

---

### 🔴 CRITICAL — <N total issues>

**1. <Rule name> · <occurrences> occurrences**
Files: `path/to/file.ts:42`, `path/to/other.ts:17` *(+ N more)*
Plan: <action plan>

**2. ...**

---

### 🟠 HIGH — <N total issues>

...

---

### 🟡 MEDIUM — <N total issues>

...

---

### 🔵 LOW — <N total issues>

...

---

### Summary

| Severity | Groups | Issues |
|---|---|---|
| 🔴 Critical | N | N |
| 🟠 High | N | N |
| 🟡 Medium | N | N |
| 🔵 Low | N | N |
| **Total** | **N** | **N** |

**Suggested first fix:** <name of the single highest-impact issue to tackle first and why>

---

If the linter produces zero issues, print:
`✅ No lint issues found. Linter: <tool>. Command: <command>.`

Do not add commentary, explanations, or apologies outside the report format above.