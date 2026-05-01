---
name: git-commit
description: >
  Execute git commit with automatic diff analysis, intelligent staging, 
  and conventional commit message generation.
  Use when user asks to commit changes or mentions "/commit".
tools: 
  bash: true
---

# Git Commit with Conventional Commits

## Overview

Create standardized, semantic git commits using the Conventional Commits specification. Analyze the actual diff to determine appropriate type, scope, and message.
- Never add "Co-Authored-By" or AI attribution to commits.

## Conventional Commit Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

## Commit Types

| Type       | Purpose                        |
| ---------- | ------------------------------ |
| `feat`     | New feature                    |
| `fix`      | Bug fix                        |
| `docs`     | Documentation only             |
| `style`    | Formatting/style (no logic)    |
| `refactor` | Code refactor (no feature/fix) |
| `perf`     | Performance improvement        |
| `test`     | Add/update tests               |
| `build`    | Build system/dependencies      |
| `ci`       | CI/config changes              |
| `chore`    | Maintenance/misc               |
| `revert`   | Revert commit                  |

## Breaking Changes

```
# Exclamation mark after type/scope
feat!: remove deprecated endpoint

# BREAKING CHANGE footer
feat: allow config to extend other configs

BREAKING CHANGE: `extends` key behavior changed
```

## Workflow

### 1. Analyze Diff

```bash
# If files are staged, use staged diff
git diff --staged

# If nothing staged, use working tree diff
git diff

# Also check status
git status --porcelain
```

### 2. Stage Files (if needed)

If nothing is staged or you want to group changes differently:

```bash
# Stage specific files
git add path/to/file1 path/to/file2

# Stage by pattern
git add *.test.*
git add src/components/*

# Interactive staging
git add -p
```

**Never commit secrets** (.env, credentials.json, private keys).

### 3. Generate Commit Message

Auto-detection: Analyze the diff to determine type, scope, and description
- **Type**: What kind of change is this?
- **Scope**: What area/module is affected?
- **Description**: One-line summary of what changed (present tense, imperative mood, <72 chars)

Optional: XML Template (for manual construction)
If you prefer manual construction, use this structure:
<commit-message>
    <type>feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert</type>
    <scope>(optional: area/module)</scope>
    <description>Short imperative summary</description>
    <body>(optional: detailed explanation)</body>
    <footer>(optional: BREAKING CHANGE, issue refs)</footer>
</commit-message>

Examples:
<example>feat(parser): add ability to parse arrays</example>
<example>fix(ui): correct button alignment</example>
<example>docs: update README with usage instructions</example>
<example>refactor: improve performance of data processing</example>
<example>chore: update dependencies</example>
<example>feat!: send email on registration (BREAKING CHANGE: email service required)</example>

### 4. Execute Commit

```bash
# Single line
git commit -m "<type>[scope]: <description>"

# Multi-line with body/footer
git commit -m "$(cat <<'EOF'
<type>[scope]: <description>

<optional body>

<optional footer>
EOF
)"
```

## Git Safety Protocol

- NEVER update git config
- NEVER run destructive commands (--force, hard reset) without explicit request
- NEVER skip hooks (--no-verify) unless user asks
- NEVER force push to main/master
- If commit fails due to hooks, fix and create NEW commit (don't amend)

## Best Practices

- One logical change per commit
- Present tense: "add" not "added"
- Imperative mood: "fix bug" not "fixes bug"
- Reference issues: `Closes #123`, `Refs #456`
- Keep description under 72 characters

---

Resources
- Conventional Commits Specification (https://www.conventionalcommits.org/en/v1.0.0/#specification)