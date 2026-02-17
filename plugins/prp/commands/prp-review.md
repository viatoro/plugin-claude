---
description: Comprehensive code review of recent commits - checks diff, patterns, runs validation
argument-hint: [commit-hash|range] (default: last commit)
---

# Commit Code Review (Trunk-Based)

**Input**: $ARGUMENTS (default: HEAD)

---

## Your Mission

Perform a thorough, senior-engineer-level review of recent commits on main:

1. **Understand** what the commits are trying to accomplish
2. **Check** the code against project patterns and constraints
3. **Run** all validation (type-check, lint, tests, build)
4. **Identify** issues by severity
5. **Report** findings as local review file

**Golden Rule**: Be constructive and actionable. Every issue should have a clear recommendation. Acknowledge good work too.

---

## Phase 1: FETCH - Get Commit Context

### 1.1 Parse Input

**Determine input type:**

| Input Format | Action |
|--------------|--------|
| Empty/blank | Review last commit: `HEAD` |
| Commit hash (`abc123f`) | Review that specific commit |
| Range (`HEAD~3..HEAD`) | Review multiple commits |
| Number (`3`) | Review last N commits: `HEAD~N..HEAD` |

```bash
# Default: last commit
COMMIT_RANGE="${ARGUMENTS:-HEAD}"
```

### 1.2 Get Commit Metadata

```bash
# Get commit details
git log ${COMMIT_RANGE} --pretty=format:"%H%n%an%n%ae%n%s%n%b" --name-status

# Get the diff
git diff ${COMMIT_RANGE}^..${COMMIT_RANGE}

# List changed files
git diff --name-only ${COMMIT_RANGE}^..${COMMIT_RANGE}

# Get commit stats
git diff --stat ${COMMIT_RANGE}^..${COMMIT_RANGE}
```

**Extract:**
- Commit hash(es)
- Author name and email
- Commit message(s)
- Files changed with line counts

### 1.3 Ensure on Main Branch

```bash
# Verify we're on main
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ]; then
  echo "⚠️  Not on main branch. Reviewing commits from: $CURRENT_BRANCH"
fi

# Ensure up to date
git fetch origin
```

### 1.4 Validate Commit Exists

```bash
# Check if commit is reachable
git rev-parse ${COMMIT_RANGE} >/dev/null 2>&1 || {
  echo "❌ Commit not found: ${COMMIT_RANGE}"
  exit 1
}
```

**PHASE_1_CHECKPOINT:**
- [ ] Commit range identified
- [ ] Commit metadata fetched
- [ ] On correct branch (or noted)
- [ ] Commits are reachable

---

## Phase 2: CONTEXT - Understand the Change

### 2.1 Read Project Rules

Read and internalize:

```bash
# Project conventions
cat CLAUDE.md

# Check for additional reference docs
ls -la .claude/docs/ 2>/dev/null
ls -la docs/ 2>/dev/null
```

**Extract key constraints:**
- Type safety requirements
- Code style rules
- Testing requirements
- Architecture patterns

### 2.2 Find Implementation Context

Look for implementation artifacts:

```bash
# Find implementation report by branch name
ls .claude/PRPs/reports/*{branch-name}*.md 2>/dev/null

# Find completed plans
ls .claude/PRPs/plans/completed/ 2>/dev/null

# Find issue investigations
ls .claude/PRPs/issues/completed/ 2>/dev/null
```

**If implementation report exists:**
1. Read the implementation report
2. Read the referenced plan
3. Note documented deviations - these are INTENTIONAL, not issues

**If no implementation report:**
- PR may not have been created via `/prp:prp-implement`
- Review normally without plan context
- Note in review that no implementation report was found

### 2.3 Understand PR Intent

From PR title, description, AND implementation report (if available):
- What problem does this solve?
- What approach was taken?
- Are there notes from the author?
- What deviations from plan were documented and why?

### 2.4 Analyze Changed Files

For each changed file, determine:
- What type of file? (service, handler, util, test, config)
- What existing patterns should it follow?
- Scope of change? (new file, modification, deletion)

**PHASE_2_CHECKPOINT:**
- [ ] Project rules read and understood
- [ ] Implementation artifacts located (if any)
- [ ] PR intent understood
- [ ] Changed files categorized

---

## Phase 3: REVIEW - Analyze the Code

### 3.1 Read Each Changed File

For each file in the diff:

1. **Read the full file** (not just diff) to understand context
2. **Read similar files** to understand expected patterns
3. **Check specific changes** against patterns

### 3.2 Review Checklist

**For EVERY changed file, check:**

#### Correctness
- [ ] Does the code do what the PR claims?
- [ ] Are there logic errors?
- [ ] Are edge cases handled?
- [ ] Is error handling appropriate?

#### Type Safety
- [ ] Are all types explicit (no implicit `any`)?
- [ ] Are return types declared?
- [ ] Are interfaces used appropriately?
- [ ] Are type guards used where needed?

#### Pattern Compliance
- [ ] Does it follow existing patterns in the codebase?
- [ ] Is naming consistent with project conventions?
- [ ] Is file organization correct?
- [ ] Are imports from the right places?

#### Security
- [ ] Any user input without validation?
- [ ] Any secrets that could be exposed?
- [ ] Any injection vulnerabilities (SQL, command, etc.)?
- [ ] Any unsafe operations?

#### Performance
- [ ] Any obvious N+1 queries or loops?
- [ ] Any unnecessary async/await?
- [ ] Any memory leaks (unclosed resources, growing arrays)?
- [ ] Any blocking operations in hot paths?

#### Completeness
- [ ] Are there tests for new code?
- [ ] Is documentation updated if needed?
- [ ] Are all TODOs addressed?
- [ ] Is error handling complete?

#### Maintainability
- [ ] Is the code readable?
- [ ] Is it over-engineered?
- [ ] Is it under-engineered (missing necessary abstractions)?
- [ ] Are there magic numbers/strings that should be constants?

### 3.3 Categorize Issues

**Important: Check implementation report first!**

If a deviation from expected patterns is documented in the implementation report with a valid reason, it is NOT an issue - it's an intentional decision. Only flag **undocumented** deviations.

**Issue Severity Levels:**

| Level | Icon | Criteria | Examples |
|-------|------|----------|----------|
| Critical | `RED` | Blocking - must fix | Security vulnerabilities, data loss potential, crashes |
| High | `ORANGE` | Should fix before merge | Type safety violations, missing error handling, logic errors |
| Medium | `YELLOW` | Should consider | Pattern inconsistencies, missing edge cases, undocumented deviations |
| Low | `BLUE` | Suggestions | Style preferences, minor optimizations, documentation |

**PHASE_3_CHECKPOINT:**
- [ ] All changed files reviewed
- [ ] Issues categorized by severity
- [ ] Implementation report deviations accounted for
- [ ] Positive aspects noted

---

## Phase 4: VALIDATE - Run Automated Checks

### 4.1 Run Validation Suite

```bash
# Type checking (adapt to project)
npm run type-check || bun run type-check || npx tsc --noEmit

# Linting
npm run lint || bun run lint

# Tests
npm test || bun test

# Build
npm run build || bun run build
```

**Capture for each:**
- Pass/fail status
- Error count
- Warning count
- Any specific failures

### 4.2 Specific Validation

Based on what changed:

| Change Type | Additional Validation |
|-------------|----------------------|
| New API endpoint | Test with curl/httpie |
| Database changes | Check migration exists |
| Config changes | Verify .env.example updated |
| New dependencies | Check package.json/lock file |

### 4.3 Regression Check

```bash
# Full test suite
npm test || bun test

# Specific tests for changed functionality
npm test -- {relevant-test-pattern}
```

**PHASE_4_CHECKPOINT:**
- [ ] Type check executed
- [ ] Lint executed
- [ ] Tests executed
- [ ] Build executed
- [ ] Results captured

---

## Phase 5: DECIDE - Form Recommendation

### 5.1 Decision Logic

**APPROVE** if:
- No critical or high issues
- All validation passes
- Code follows patterns
- Changes match PR intent

**REQUEST CHANGES** if:
- High priority issues exist
- Validation fails but is fixable
- Pattern violations that need addressing
- Missing tests for new functionality

**BLOCK** if:
- Critical security or data issues
- Fundamental approach is wrong
- Major architectural concerns
- Breaking changes without migration

### 5.2 Special Cases

| Situation | Handling |
|-----------|----------|
| Draft PR | Comment only, no approve/block |
| Large PR (>500 lines) | Note thoroughness limits, suggest splitting |
| Security-sensitive | Extra scrutiny, err on caution |
| Missing tests | Strong recommendation, may not block |

**PHASE_5_CHECKPOINT:**
- [ ] Recommendation determined
- [ ] Rationale clear

---

## Phase 6: REPORT - Generate Review

### 6.1 Create Report Directory

```bash
mkdir -p .claude/PRPs/reviews
```

### 6.2 Generate Report File

**Path**: `.claude/PRPs/reviews/pr-{NUMBER}-review.md`

```markdown
---
pr: {NUMBER}
title: "{TITLE}"
author: "{AUTHOR}"
reviewed: {ISO_TIMESTAMP}
recommendation: {approve|request-changes|block}
---

# PR Review: #{NUMBER} - {TITLE}

**Author**: @{author}
**Branch**: {head} -> {base}
**Files Changed**: {count} (+{additions}/-{deletions})

---

## Summary

{2-3 sentences: What this PR does and overall assessment}

---

## Implementation Context

| Artifact | Path |
|----------|------|
| Implementation Report | `{path}` or "Not found" |
| Original Plan | `{path}` or "Not found" |
| Documented Deviations | {count} or "N/A" |

{If implementation report exists: Brief note about deviation documentation quality}

---

## Changes Overview

| File | Changes | Assessment |
|------|---------|------------|
| `{path/to/file.ts}` | +{N}/-{M} | {PASS/WARN/FAIL} |

---

## Issues Found

### Critical
{If none: "No critical issues found."}

- **`{file.ts}:{line}`** - {Issue description}
  - **Why**: {Explanation of the problem}
  - **Fix**: {Specific recommendation}

### High Priority
{Issues that should be fixed before merge}

### Medium Priority
{Issues worth addressing but not blocking}

### Suggestions
{Nice-to-haves and future improvements}

---

## Validation Results

| Check | Status | Details |
|-------|--------|---------|
| Type Check | {PASS/FAIL} | {notes} |
| Lint | {PASS/WARN} | {count} warnings |
| Tests | {PASS/FAIL} | {count} passed |
| Build | {PASS/FAIL} | {notes} |

---

## Pattern Compliance

- [{x}] Follows existing code structure
- [{x}] Type safety maintained
- [{x}] Naming conventions followed
- [{x}] Tests added for new code
- [{x}] Documentation updated

---

## What's Good

{Acknowledge positive aspects - good patterns, clean code, thorough tests, etc.}

---

## Recommendation

**{APPROVE/REQUEST CHANGES/BLOCK}**

{Clear explanation of recommendation and what needs to happen next}

---

*Reviewed by Claude*
*Report: `.claude/PRPs/reviews/pr-{NUMBER}-review.md`*
```

**PHASE_6_CHECKPOINT:**
- [ ] Report file created
- [ ] All sections populated

---

## Phase 7: PUBLISH - Post to GitHub

### 7.1 Determine Review Action

Review file is already saved locally. Optional actions:

```bash
# Display review summary
cat .claude/PRPs/reviews/commit-{HASH}-review.md | head -50

# Email review to team (if configured)
# mail -s "Code Review: {commit-message}" team@example.com < .claude/PRPs/reviews/commit-{HASH}-review.md
```

### 7.2 Archive Review

```bash
# Reviews are saved in .claude/PRPs/reviews/
# They serve as historical record and learning material
ls -la .claude/PRPs/reviews/
```

**PHASE_7_CHECKPOINT:**
- [ ] Review saved locally
- [ ] Review file path confirmed

---

## Phase 8: OUTPUT - Report to User

```markdown
## Commit Review Complete

**Commit(s)**: {COMMIT_HASH}
**Message**: {COMMIT_MESSAGE}
**Author**: {AUTHOR_NAME}
**Assessment**: {GOOD/NEEDS FIXES/CRITICAL ISSUES}

### Issues Found

| Severity | Count |
|----------|-------|
| Critical | {N} |
| High | {N} |
| Medium | {N} |
| Suggestions | {N} |

### Validation

| Check | Result |
|-------|--------|
| Type Check | {PASS/FAIL} |
| Lint | {PASS/FAIL} |
| Tests | {PASS/FAIL} |
| Build | {PASS/FAIL} |

### Artifacts

- Report: `.claude/PRPs/reviews/commit-{SHORT_HASH}-review.md`

### Next Steps

{Based on assessment:}
- GOOD: "Commits meet project standards"
- NEEDS FIXES: "Consider addressing {N} issues in follow-up commits"
- CRITICAL ISSUES: "Recommend reverting and fixing critical issues"
```

---

## Critical Reminders

1. **Understand before judging.** Read full context, not just the diff.

2. **Be specific.** "This could be better" is useless. "Use `execFile` instead of `exec` to prevent command injection at line 45" is helpful.

3. **Prioritize.** Not everything is critical. Use severity levels honestly.

4. **Be constructive.** Offer solutions, not just problems.

5. **Acknowledge good work.** If something is done well, say so.

6. **Run validation.** Don't skip automated checks.

7. **Check patterns.** Read existing similar code to understand expectations.

8. **Think about edge cases.** What happens with null, empty, very large, concurrent?

9. **Check implementation report.** Documented deviations are intentional, not issues.

---

## Success Criteria

- **CONTEXT_GATHERED**: PR metadata, diff, and implementation artifacts reviewed
- **CODE_REVIEWED**: All changed files analyzed against checklist
- **VALIDATION_RUN**: All automated checks executed
- **ISSUES_CATEGORIZED**: Findings organized by severity
- **REPORT_GENERATED**: Comprehensive review saved locally
- **PR_UPDATED**: Review/comment posted to GitHub
- **RECOMMENDATION_CLEAR**: Approve/request-changes/block with rationale
