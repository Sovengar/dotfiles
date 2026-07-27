---
name: debug
description: >
  Debugging methodology - investigate bugs, errors, test failures, and unexpected behavior.
  Find root cause before fixing. Includes error analysis, data flow tracing, 5 Whys analysis,
  binary search debugging, hypothesis testing, and systematic problem-solving patterns.
  Use before proposing any fix.
tags: [debugging, bug-fix, error-analysis, root-cause, troubleshooting, testing, investigation, 5-whys]
triggers: [bug, error, fail, fix, issue, problem, unexpected, debugging, reproduce, trace]
---

# Systematic Debugging

## Overview

Random fixes waste time and create new bugs. Quick patches mask underlying issues.

**Core principle:** ALWAYS find root cause before attempting fixes. Symptom fixes are failure.

**Violating the letter of this process is violating the spirit of debugging.**

## The Iron Law

```
NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST
```

If you haven't completed Phase 1, you cannot propose fixes.

## When to Use

Use for ANY technical issue:
- Test failures
- Bugs in production
- Unexpected behavior
- Performance problems
- Build failures
- Integration issues

**Use this ESPECIALLY when:**
- Under time pressure (emergencies make guessing tempting)
- "Just one quick fix" seems obvious
- You've already tried multiple fixes
- Previous fix didn't work
- You don't fully understand the issue

**Don't skip when:**
- Issue seems simple (simple bugs have root causes too)
- You're in a hurry (rushing guarantees rework)
- Manager wants it fixed NOW (systematic is faster than thrashing)

## Simple vs Complex Issue Decision

Before starting investigation, assess the issue complexity:

```
IF issue involves ANY of these:
  - Multi-component systems (CI → build → signing, API → service → database)
  - Race conditions or timing issues
  - Production errors requiring environment investigation
  - Intermittent/flaky behavior
  - Memory leaks
  - Performance bottlenecks
  - "Works locally, fails in production"

THEN → Use debugger subagent for deep investigation
ELSE  → Follow simple investigation steps below
```

**For Simple Issues (direct investigation):**
1. Gather information (error message, file, line)
2. Form hypotheses (ordered by likelihood)
3. Test systematically
4. Fix and prevent

**For Complex Issues (use subagent):**
- Delegate to debugger subagent with full context
- Provide: error message, reproduction steps, expected vs actual behavior

## The Four Phases

You MUST complete each phase before proceeding to the next.

### Phase 1: Root Cause Investigation

**BEFORE attempting ANY fix:**

1. **Read Error Messages Carefully**
   - Don't skip past errors or warnings
   - They often contain the exact solution
   - Read stack traces completely
   - Note line numbers, file paths, error codes

2. **Reproduce Consistently**
   - Can you trigger it reliably?
   - What are the exact steps?
   - Does it happen every time?
   - If not reproducible → gather more data, don't guess

3. **Check Recent Changes**
   - What changed that could cause this?
   - Git diff, recent commits
   - New dependencies, config changes
   - Environmental differences

4. **Gather Evidence in Multi-Component Systems**

   **WHEN system has multiple components (CI → build → signing, API → service → database):**

   **BEFORE proposing fixes, add diagnostic instrumentation:**
   ```
   For EACH component boundary:
     - Log what data enters component
     - Log what data exits component
     - Verify environment/config propagation
     - Check state at each layer

   Run once to gather evidence showing WHERE it breaks
   THEN analyze evidence to identify failing component
   THEN investigate that specific component
   ```

   **Example (multi-layer system):**
   ```bash
   # Layer 1: Workflow
   echo "=== Secrets available in workflow: ==="
   echo "IDENTITY: ${IDENTITY:+SET}${IDENTITY:-UNSET}"

   # Layer 2: Build script
   echo "=== Env vars in build script: ==="
   env | grep IDENTITY || echo "IDENTITY not in environment"

   # Layer 3: Signing script
   echo "=== Keychain state: ==="
   security list-keychains
   security find-identity -v

   # Layer 4: Actual signing
   codesign --sign "$IDENTITY" --verbose=4 "$APP"
   ```

   **This reveals:** Which layer fails (secrets → workflow ✓, workflow → build ✗)

5. **Trace Data Flow**

   **WHEN error is deep in call stack:**

   See `root-cause-tracing.md` in this directory for the complete backward tracing technique.

   **Quick version:**
   - Where does bad value originate?
   - What called this with bad value?
   - Keep tracing up until you find the source
   - Fix at source, not at symptom

6. **Apply 5 Whys Technique**

   **When to use:** Iteratively ask "WHY?" to drill down from symptom to actual root cause.

   ```
   WHY is the user seeing an error?
   → Because the API returns 500.

   WHY does the API return 500?
   → Because the database query fails.

   WHY does the query fail?
   → Because the table doesn't exist.

   WHY doesn't the table exist?
   → Because migration wasn't run.

   WHY wasn't migration run?
   → Because deployment script skips it. ← ROOT CAUSE
   ```

   **Key principle:** Stop when you reach something you can control/fix, not just another symptom.

### Phase 2: Pattern Analysis

**Find the pattern before fixing:**

1. **Find Working Examples**
   - Locate similar working code in same codebase
   - What works that's similar to what's broken?

2. **Compare Against References**
   - If implementing pattern, read reference implementation COMPLETELY
   - Don't skim - read every line
   - Understand the pattern fully before applying

3. **Identify Differences**
   - What's different between working and broken?
   - List every difference, however small
   - Don't assume "that can't matter"

4. **Understand Dependencies**
   - What other components does this need?
   - What settings, config, environment?
   - What assumptions does it make?

### Phase 3: Hypothesis and Testing

**Scientific method:**

1. **Form Single Hypothesis**
   - State clearly: "I think X is the root cause because Y"
   - Write it down
   - Be specific, not vague

2. **Test Minimally**
   - Make the SMALLEST possible change to test hypothesis
   - One variable at a time
   - Don't fix multiple things at once

3. **Verify Before Continuing**
   - Did it work? Yes → Phase 4
   - Didn't work? Form NEW hypothesis
   - DON'T add more fixes on top

4. **When You Don't Know**
   - Say "I don't understand X"
   - Don't pretend to know
   - Ask for help
   - Research more

5. **Binary Search Debugging**

   **When unsure WHERE the bug is:**
   - Find a point where it works
   - Find a point where it fails
   - Check the middle
   - Repeat until you find exact location

   ```
   ┌───────────────────────────────────────────────────────┐
   │  WORKING ───────────●────────────── FAILING          │
   │                          ↑                            │
   │                     Check here next                  │
   └───────────────────────────────────────────────────────┘
   ```

   **Example:** If 100 tests fail, run tests 1-50. If they fail → bug is in 1-50. If pass → bug is in 51-100. Repeat.

### Phase 4: Implementation

**Fix the root cause, not the symptom:**

1. **Create Failing Test Case**
   - Simplest possible reproduction
   - Automated test if possible
   - One-off test script if no framework
   - MUST have before fixing
   - Use the `superpowers:test-driven-development` skill for writing proper failing tests

2. **Implement Single Fix**
   - Address the root cause identified
   - ONE change at a time
   - No "while I'm here" improvements
   - No bundled refactoring

3. **Verify Fix**
   - Test passes now?
   - No other tests broken?
   - Issue actually resolved?

4. **If Fix Doesn't Work**
   - STOP
   - Count: How many fixes have you tried?
   - If < 3: Return to Phase 1, re-analyze with new information
   - **If ≥ 3: STOP and question the architecture (step 5 below)**
   - DON'T attempt Fix #4 without architectural discussion

5. **If 3+ Fixes Failed: Question Architecture**

   **Pattern indicating architectural problem:**
   - Each fix reveals new shared state/coupling/problem in different place
   - Fixes require "massive refactoring" to implement
   - Each fix creates new symptoms elsewhere

   **STOP and question fundamentals:**
   - Is this pattern fundamentally sound?
   - Are we "sticking with it through sheer inertia"?
   - Should we refactor architecture vs. continue fixing symptoms?

   **Discuss with your human partner before attempting more fixes**

   This is NOT a failed hypothesis - this is a wrong architecture.

## Bug Categories by Error Type

| Error Type | Investigation Approach |
|------------|----------------------|
| **Runtime Error** | Read stack trace, check types and nulls |
| **Logic Bug** | Trace data flow, compare expected vs actual |
| **Performance** | Profile first, then optimize |
| **Intermittent** | Look for race conditions, timing issues |
| **Memory Leak** | Check event listeners, closures, caches |
| **Works locally, fails in prod** | Environment diff, check configs |

## Symptom → First Steps Quick Reference

| Symptom | First Steps |
|---------|-------------|
| "It crashes" | Get stack trace, check error logs |
| "It's slow" | Profile, don't guess |
| "Sometimes works" | Race condition? Timing? External dependency? |
| "Wrong output" | Trace data flow step by step |
| "Works locally, fails in prod" | Environment diff, check configs |

## Tool Selection Reference

| Need | Tool |
|------|------|
| Search errors in code | grep |
| Read files | read |
| Execute commands | bash |
| Find files by name | glob |
| Research solutions | websearch |
| Debug browser issues | chrome-devtools |

## Anti-Patterns (What NOT to Do)

| Anti-Pattern | Correct Approach |
|--------------|------------------|
| Random changes hoping to fix | Systematic investigation |
| Ignoring stack traces | Read every line carefully |
| "Works on my machine" | Reproduce in same environment |
| Fixing symptoms only | Find and fix root cause |
| No regression test | Always add test for the bug |
| Multiple changes at once | One change, then verify |
| Skipping error messages | Read and understand all errors |
| Guessing the root cause | Apply 5 Whys or trace data flow |

## Red Flags - STOP and Follow Process

If you catch yourself thinking:
- "Quick fix for now, investigate later"
- "Just try changing X and see if it works"
- "Add multiple changes, run tests"
- "Skip the test, I'll manually verify"
- "It's probably X, let me fix that"
- "I don't fully understand but this might work"
- "Pattern says X but I'll adapt it differently"
- "Here are the main problems: [lists fixes without investigation]"
- Proposing solutions before tracing data flow
- **"One more fix attempt" (when already tried 2+)**
- **Each fix reveals new problem in different place**

**ALL of these mean: STOP. Return to Phase 1.**

**If 3+ fixes failed:** Question the architecture (see Phase 4.5)

## your human partner's Signals You're Doing It Wrong

**Watch for these redirections:**
- "Is that not happening?" - You assumed without verifying
- "Will it show us...?" - You should have added evidence gathering
- "Stop guessing" - You're proposing fixes without understanding
- "Ultrathink this" - Question fundamentals, not just symptoms
- "We're stuck?" (frustrated) - Your approach isn't working

**When you see these:** STOP. Return to Phase 1.

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "Issue is simple, don't need process" | Simple issues have root causes too. Process is fast for simple bugs. |
| "Emergency, no time for process" | Systematic debugging is FASTER than guess-and-check thrashing. |
| "Just try this first, then investigate" | First fix sets the pattern. Do it right from the start. |
| "I'll write test after confirming fix works" | Untested fixes don't stick. Test first proves it. |
| "Multiple fixes at once saves time" | Can't isolate what worked. Causes new bugs. |
| "Reference too long, I'll adapt the pattern" | Partial understanding guarantees bugs. Read it completely. |
| "I see the problem, let me fix it" | Seeing symptoms ≠ understanding root cause. |
| "One more fix attempt" (after 2+ failures) | 3+ failures = architectural problem. Question pattern, don't fix again. |

## Quick Reference

| Phase | Key Activities | Success Criteria |
|-------|---------------|------------------|
| **1. Root Cause** | Read errors, reproduce, check changes, gather evidence, **5 Whys** | Understand WHAT and WHY |
| **2. Pattern** | Find working examples, compare | Identify differences |
| **3. Hypothesis** | Form theory, test minimally, **binary search** | Confirmed or new hypothesis |
| **4. Implementation** | Create test, fix, verify | Bug resolved, tests pass |

## When Process Reveals "No Root Cause"

If systematic investigation reveals issue is truly environmental, timing-dependent, or external:

1. You've completed the process
2. Document what you investigated
3. Implement appropriate handling (retry, timeout, error message)
4. Add monitoring/logging for future investigation

**But:** 95% of "no root cause" cases are incomplete investigation.

## Supporting Techniques

These techniques are part of systematic debugging and available in this directory:

- **`root-cause-tracing.md`** - Trace bugs backward through call stack to find original trigger
- **`defense-in-depth.md`** - Add validation at multiple layers after finding root cause
- **`condition-based-waiting.md`** - Replace arbitrary timeouts with condition polling

**Related skills:**
- **superpowers:test-driven-development** - For creating failing test case (Phase 4, Step 1)
- **superpowers:verification-before-completion** - Verify fix worked before claiming success

## Investigation Output Format

Use this template when reporting investigation results. If a section doesn't apply, skip it.

```markdown
## 🔍 Investigate: [Issue Title]

### Symptom
[What's happening - describe the bug/error/unexpected behavior]

### Information Gathered
- Error: `[error message or code]`
- File: `[filepath]`
- Line: [line number]
- [Any other relevant context: environment, version, etc.]

### Hypotheses
1. ❓ [Most likely cause]
2. ❓ [Second possibility]
3. ❓ [Less likely cause]

### Investigation

**Testing hypothesis 1:**
[What I checked] → [Result]

**Testing hypothesis 2:**
[What I checked] → [Result]

### Root Cause
🎯 **[Explanation of why this happened - apply 5 Whys if needed]**

### Fix
```[language]
// Before
[broken code]

// After
[fixed code]
```

### Prevention
🛡️ [How to prevent this: add tests, validation, comments, monitoring, etc.]
```

### Example Outputs

```
## 🔍 Investigate: API returns 500 when calling /users

### Symptom
Endpoint /users returns HTTP 500 error

### Information Gathered
- Error: "relation 'users' does not exist"
- File: src/api/users.ts
- Line: 42

### Hypotheses
1. ❓ Database table not migrated
2. ❓ Wrong database connection string
3. ❓ Query syntax error

### Investigation
**Testing hypothesis 1:**
Checked migration status → Found users table NOT in database ← ROOT CAUSE

### Root Cause
🎯 Migration was not run after last deployment

### Fix
```sql
-- Run pending migrations
npm run db:migrate
```

### Prevention
🛡️ Add migration check to CI/CD pipeline
```

## Real-World Impact

From debugging sessions:
- Systematic approach: 15-30 minutes to fix
- Random fixes approach: 2-3 hours of thrashing
- First-time fix rate: 95% vs 40%
- New bugs introduced: Near zero vs common
