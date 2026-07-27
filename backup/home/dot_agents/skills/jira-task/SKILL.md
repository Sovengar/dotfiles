---
name: jira-task
description: >
  Creates well-structured Jira tasks with proper decomposition for multi-component work.
  Trigger: When user asks to create a Jira task, ticket, issue, or decompose work into tasks.
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "1.1"
---

## When to Use

Use this skill when creating Jira tasks for:
- Bug reports
- Feature requests
- Refactoring tasks
- Documentation tasks
- Any work that needs to be tracked in Jira

## Multi-Component Work: Split into Multiple Tasks

**IMPORTANT:** When work requires changes in multiple components (API, UI, SDK), create **separate tasks for each component** instead of one big task.

### Why Split?
- Different developers can work in parallel
- Easier to review and test
- Better tracking of progress
- API needs to be done before UI (dependency)

### Bug vs Feature: Different Structures

#### For BUGS: Create separate sibling tasks
Bugs are typically urgent fixes, so create independent tasks per component:

**Task 1 - API:**
- Title: `[BUG] Add user authentication to API endpoint (API)`
- Must be done first (UI depends on it)

**Task 2 - UI:**
- Title: `[BUG] Add login form with OAuth buttons (UI)`
- Blocked by API task

#### For FEATURES: Create parent + child tasks
Features need business context for stakeholders, so use a parent-child structure:

**Parent Task (for PM/Stakeholders):**
- Title: `[FEATURE] Dark mode support`
- Contains: Feature overview, user story, acceptance criteria from USER perspective
- NO technical details
- Links to child tasks

**Child Task 1 - API:**
- Title: `[FEATURE] Dark mode support (API)`
- Contains: Technical details, API endpoints, backend-specific acceptance criteria
- Links to parent

**Child Task 2 - UI:**
- Title: `[FEATURE] Dark mode support (UI)`
- Contains: Technical details, component paths, UI-specific acceptance criteria
- Links to parent, blocked by API task

### Parent Task Template (Features Only)

```markdown
## Description

{User-facing description of the feature - what problem does it solve?}

## User Story

As a {user type}, I want to {action} so that {benefit}.

## Acceptance Criteria (User Perspective)

- [ ] User can {do something}
- [ ] User sees {something}
- {Behavior from user's point of view}

## Out of Scope

- {What this feature does NOT include}

## Design

- Figma: {link if available}
- Screenshots/mockups if available

## Child Tasks

- [ ] `[FEATURE] {Feature name} (API)` - Backend implementation
- [ ] `[FEATURE] {Feature name} (UI)` - Frontend implementation
- [ ] `[FEATURE] {Feature name} (SDK)` - SDK implementation (if applicable)

## Priority

{High/Medium/Low} ({business justification})
```

### Child Task Template (Features Only)

```markdown
## Description

Technical implementation of {feature name} for {component}.

## Parent Task

`[FEATURE] {Feature name}`

## Acceptance Criteria (Technical)

- [ ] {Technical requirement 1}
- [ ] {Technical requirement 2}

## Technical Notes

- Affected files:
  - `{file path 1}`
  - `{file path 2}`
- {Implementation hints}

## Testing

- [ ] {Test case 1}
- [ ] {Test case 2}

## Related Tasks

- Parent: `[FEATURE] {Feature name}`
- Blocked by: {if any}
- Blocks: {if any}
```

### Bug Task Template

```markdown
## Description

{Brief explanation of the bug}

**Current State:**
- {What's happening / What's broken}
- {Impact on users}

**Expected State:**
- {What should happen}
- {Desired behavior}

## Steps to Reproduce

1. {Step 1}
2. {Step 2}
3. {Step 3}

## Acceptance Criteria

- [ ] {Specific, testable requirement}
- [ ] {Another requirement}

## Technical Notes

- Affected files:
  - `{file path 1}`
  - `{file path 2}`
- {Implementation hints}

## Testing

- [ ] {Test case 1}
- [ ] {Test case 2}
- [ ] Regression: {What to verify still works}

## Priority

{High/Medium/Low} ({justification})
```

### Linking Tasks

In each task description, add:
```markdown
## Related Tasks
- Parent: [Parent task title/link] (for child tasks)
- Blocked by: [API task title/link]
- Blocks: [UI task title/link]
```

## Task Title Conventions

Format: `[TYPE] Brief description (components)`

**Types:**
- `[BUG]` - Something broken that worked before
- `[FEATURE]` - New functionality
- `[ENHANCEMENT]` - Improvement to existing feature
- `[REFACTOR]` - Code restructure without behavior change
- `[DOCS]` - Documentation only
- `[CHORE]` - Maintenance, dependencies, CI/CD

**Components (when multiple affected):**
- `(API)` - Backend only
- `(UI)` - Frontend only
- `(SDK)` - SDK/Library only
- `(API + UI)` - Both backend and frontend
- `(SDK + API)` - SDK and backend
- `(Full Stack)` - All components
- `(Docs)` - Documentation only

**Examples:**
- `[BUG] User authentication fails with OAuth provider (API)`
- `[FEATURE] Add dark mode toggle (UI)`
- `[REFACTOR] Migrate tests to Page Object Model (UI)`
- `[ENHANCEMENT] Improve response time for large datasets (API)`
- `[CHORE] Update dependencies to latest versions (Full Stack)`

## Priority Guidelines

| Priority | Criteria |
|----------|----------|
| **Critical** | Production down, data loss, security vulnerability |
| **High** | Blocks users, no workaround, affects paid features |
| **Medium** | Has workaround, affects subset of users |
| **Low** | Nice to have, cosmetic, internal tooling |

## Affected Files Section

Always include full paths when known:

```markdown
## Technical Notes

- Affected files:
  - `backend/src/api/routes/users.ts`
  - `frontend/components/auth/login-form.tsx`
  - `shared/types/auth.ts`
```

## Component-Specific Guidelines

### API Tasks
Include:
- Endpoint changes
- Database schema/migration requirements
- Authentication/authorization changes
- API contract changes (OpenAPI/Swagger)

### UI Tasks
Include:
- Component paths
- Form validation changes
- State management impact
- Responsive design considerations
- Design system changes

### SDK Tasks
Include:
- Library/package affected
- Public API changes
- Breaking changes considerations
- Version bump required

## Checklist Before Submitting

1. ✅ Title follows `[TYPE] description (components)` format
2. ✅ Description has Current/Expected State (for bugs)
3. ✅ Description has User Story (for features)
4. ✅ Acceptance Criteria are specific and testable
5. ✅ Technical Notes include file paths (or "TBD" if unknown)
6. ✅ Testing section covers happy path + edge cases
7. ✅ Priority has justification
8. ✅ **Multi-component work is split into separate tasks**
9. ✅ **For features: Parent task links to children, children link to parent**
10. ✅ **For bugs with multiple components: Independent sibling tasks**

## Output Format

### For BUGS with single component:

```markdown
## Recommended Task

### [BUG] {Description} ({Component})
{task content}
```

### For BUGS with multiple components (sibling tasks):

```markdown
## Recommended Tasks

### Task 1: [BUG] {Description} (API)
{task content}

---

### Task 2: [BUG] {Description} (UI)
{task content}
```

### For FEATURES with single component:

```markdown
## Recommended Task

### [FEATURE] {Feature name} ({Component})
{child task content with parent reference}
```

### For FEATURES with multiple components (parent + children):

```markdown
## Recommended Tasks

### Parent Task: [FEATURE] {Feature name}
{user-facing content, NO technical details}

---

### Child Task 1: [FEATURE] {Feature name} (API)
{technical content for API team}

---

### Child Task 2: [FEATURE] {Feature name} (UI)
{technical content for UI team}
```

## Formatting Rules

**CRITICAL:** All output MUST be in Markdown format, ready to paste into Jira.

- Use `##` for main sections (Description, Acceptance Criteria, etc.)
- Use `**bold**` for emphasis
- Use `- [ ]` for checkboxes
- Use ``` for code blocks with language hints
- Use `backticks` for file paths, commands, and code references
- Use tables where appropriate
- Use `---` to separate multiple tasks

## Jira-Specific Tips

- Keep descriptions concise but complete
- Use checklists for acceptance criteria (they become Jira's native checklists)
- Add relevant labels: `frontend`, `backend`, `sdk`, `bug`, `feature`
- Link related tasks using "Blocks" / "Is blocked by" relationships
- For features, use Epics to group related child tasks

## Keywords

jira, task, ticket, issue, bug, feature, enhancement, refactor, docs, chore, decompose, breakdown, user story, acceptance criteria