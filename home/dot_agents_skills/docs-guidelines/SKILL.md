---
name: docs-guidelines
description: >
  Documentation guidelines and templates. README structure, API docs, Changelog, ADR, PRD, Specification, AI-friendly documentation.
  Focus on documenting the WHY, not the WHAT.
tags: [documentation, docs, guidelines, adr, readme, prd, specification]
triggers: [docs-guidelines, documentation, readme, adr, changelog, api-docs, specification, prd]
---

# Documentation Guidelines

> Focus on documenting the WHY, not the WHAT.

---

## 1. README Structure

### Essential Sections (Priority Order)

| Section | Purpose |
|---------|---------|
| **Title + One-liner** | What is this? |
| **Quick Start** | Running in <5 min |
| **Features** | What can I do? |
| **Configuration** | How to customize |
| **API Reference** | Link to detailed docs |
| **Contributing** | How to help |
| **License** | Legal |

### README Template

```markdown
# Project Name

Brief one-line description.

## Quick Start

[Minimum steps to run]

## Features

- Feature 1
- Feature 2

## Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| PORT | Server port | 3000 |

## Documentation

- [API Reference](./docs/api.md)
- [Architecture](./docs/architecture.md)

## License

MIT
```

### Role & Process

See `references/readme.md` for:
- Role (senior expert software engineer)
- Task (6 steps to create a README)
- Examples (links to real READMEs for inspiration)
- Guidelines (formatting, emojis, admonitions)

---

## 2. API Documentation Structure

### Per-Endpoint Template

```markdown
## GET /users/:id

Get a user by ID.

**Parameters:**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| id | string | Yes | User ID |

**Response:**
- 200: User object
- 404: User not found

**Example:**
[Request and response example]
```

---

## 3. Changelog Template (Keep a Changelog)

```markdown
# Changelog

## [Unreleased]
### Added
- New feature

## [1.0.0] - 2025-01-01
### Added
- Initial release
### Changed
- Updated dependency
### Fixed
- Bug fix
```

---

## 4. Architecture Decision Record (ADR)

```markdown
# ADR-001: [Title]

## Status
Accepted / Deprecated / Superseded

## Context
Why are we making this decision?

## Decision
What did we decide?

## Consequences
What are the trade-offs?
```

---

## 5. Code Documentation Principles

> **Core rule:** Document the WHY, not the WHAT.

### When to Comment

| ✅ Do Comment | ❌ Don't Comment |
|--------------|-----------------|
| WHY: Reason behind the design decision | WHAT: Obvious code behavior |
| Business logic or domain rules | HOW: Implementation details |
| Non-obvious workarounds or hacks | EVERY function/method |
| Complex algorithms (with ADR ref) | Self-explanatory code |
| API contracts | "Fixes bug" without context |

### The WHY Pattern

```typescript
// ✅ GOOD: Explains WHY
// Using setTimeout instead of immediate execution to debounce rapid
// form changes. See ADR-023 for alternatives considered.
// 
// Alternative considered: useDeferredValue (too complex for this use case)
const handleChange = debounce(onChange, 300);

// ❌ BAD: Explains WHAT
// Debounces the onChange handler by 300ms
const handleChange = debounce(onChange, 300);
```

### Long Comments → Reference ADR

| Comment Length | Action |
|----------------|--------|
| < 3 lines | Inline comment |
| > 3 lines | Create ADR and reference it |
| Complex decision | Full ADR with alternatives considered |

### ADR References in Code

```typescript
// Implementation based on ADR-023: Debounce Strategy Selection
// - Chose custom debounce for fine-grained control
// - Rejected: lodash debounce (bundle size), useDeferredValue (React 19 only)
```

---

## 6. AI-Friendly Documentation (llms.txt)

### llms.txt Template

For AI crawlers and agents:

```markdown
# Project Name
> One-line objective.

## Core Files
- [src/index.ts]: Main entry
- [src/api/]: API routes
- [docs/]: Documentation

## Key Concepts
- Concept 1: Brief explanation
- Concept 2: Brief explanation
```

### MCP-Ready Documentation

For RAG indexing:
- Clear H1-H3 hierarchy
- JSON/YAML examples for data structures
- Mermaid diagrams for flows
- Self-contained sections

---

## 7. Structure Principles

| Principle | Why |
|-----------|-----|
| **Scannable** | Headers, lists, tables |
| **Examples first** | Show, don't just tell |
| **Progressive detail** | Simple → Complex |
| **Up to date** | Outdated = misleading |

---

## 8. Specification

> Best practices for creating AI-ready specifications.

See `references/specification.md` for:
- AI-Ready Specification Principles
- Specification Template
- Requirement Naming Convention
- File Naming Convention

---

## 9. Product Requirements Document (PRD)

> Best practices for creating PRDs.

See `references/prd.md` for:
- When to Use a PRD
- PRD Workflow (Discovery → Analysis → Draft)
- Quality Standards
- PRD Schema
- Implementation Guidelines

---

## 10. Mermaid Diagrams

> Best practices for creating Mermaid diagrams.

See `references/mermaid.md` for:
- Diagram Types Reference
- Workflow (Scan → Identify → Generate → Document)
- Output Guidelines
- Best Practices

---

> **Remember:** Templates are starting points. Adapt to your project's needs.
