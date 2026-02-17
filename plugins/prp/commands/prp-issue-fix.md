---
description: Implement a fix from investigation artifact - code changes, PR, and self-review
argument-hint: <issue-number|artifact-path>
---

# Implement Issue

**Input**: $ARGUMENTS

---

## Your Mission

Execute the implementation plan from `/prp:prp-issue-investigate`:

1. Load and validate the artifact
2. Ensure git state is correct
3. Implement the changes exactly as specified
4. Run validation
5. Create PR linked to issue
6. Run self-review and post findings
7. Archive the artifact

**Golden Rule**: Follow the artifact. If something seems wrong, validate it first - don't silently deviate.

---

## Phase 1: LOAD - Get the Artifact

### 1.1 Determine Input Type

**If input looks like a number** (`123`, `#123`):

```bash
# Look for artifact
ls .claude/PRPs/issues/issue-{number}.md
```

**If input is a path**:

- Use the path directly

### 1.2 Load and Parse Artifact

```bash
cat {artifact-path}
```

**Extract from artifact:**

- Issue number and title
- Type (BUG/ENHANCEMENT/etc)
- Files to modify (with line numbers)
- Implementation steps
- Validation commands
- Test cases to add

### 1.3 Validate Artifact Exists

**If artifact not found:**

```
❌ Artifact not found at .claude/PRPs/issues/issue-{number}.md

Run `/prp:prp-issue-investigate {number}` first to create the implementation plan.
```

**PHASE_1_CHECKPOINT:**

- [ ] Artifact found and loaded
- [ ] Key sections parsed (files, steps, validation)
- [ ] Issue number extracted (if applicable)

---

## Phase 2: VALIDATE - Sanity Check

### 2.1 Verify Plan Accuracy

For each file mentioned in the artifact:

- Read the actual current code
- Compare to what artifact expects
- Check if the "current code" snippets match reality

**If significant drift detected:**

```
⚠️ Code has changed since investigation:

File: src/x.ts:45
- Artifact expected: {snippet}
- Actual code: {different snippet}

Options:
1. Re-run /prp:prp-issue-investigate to get fresh analysis
2. Proceed carefully with manual adjustments
```

### 2.2 Confirm Approach Makes Sense

Ask yourself:

- Does the proposed fix actually address the root cause?
- Are there obvious problems with the approach?
- Has something changed that invalidates the plan?

**If plan seems wrong:**

- STOP
- Explain what's wrong
- Suggest re-investigation

**PHASE_2_CHECKPOINT:**

- [ ] Artifact matches current codebase state
- [ ] Approach still makes sense
- [ ] No blocking issues identified

---

## Phase 3: GIT-CHECK - Ensure Correct State (Trunk-Based)

### 3.1 Check Current Git State

```bash
# What branch are we on? (should be main)
git branch --show-current

# Is working directory clean?
git status --porcelain

# Are we up to date with remote?
git fetch origin
git status
```

### 3.2 Decision Tree (Trunk-Based)

```
┌─ ON MAIN?
│  └─ Q: Working directory clean?
│     ├─ YES → Sync with remote: git pull origin main
│     └─ NO  → Commit WIP: git add . && git commit -m "WIP: checkpoint"
│              Then sync: git pull origin main
│
└─ ON OTHER BRANCH?
   └─ Switch to main: git checkout main && git pull origin main
```

### 3.3 Ensure Up-to-Date

```bash
# Sync with main using merge
git fetch origin
git merge origin/main
```

**If merge conflicts:**
1. Resolve conflicts in affected files
2. `git add .`
3. `git commit -m "merge: sync with origin/main"`

**PHASE_3_CHECKPOINT:**

- [ ] On main branch
- [ ] Merged latest origin/main
- [ ] No conflicts
- [ ] Working directory ready

---

## Phase 4: IMPLEMENT - Make Changes

### 4.1 Execute Each Step

For each step in the artifact's Implementation Plan:

1. **Read the target file** - understand current state
2. **Make the change** - exactly as specified
3. **Verify types compile** - run the project's type-check command

### 4.2 Implementation Rules

**DO:**

- Follow artifact steps in order
- Match existing code style exactly
- Copy patterns from "Patterns to Follow" section
- Add tests as specified

**DON'T:**

- Refactor unrelated code
- Add "improvements" not in the plan
- Change formatting of untouched lines
- Deviate from the artifact without noting it

### 4.3 Handle Each File Type

**For UPDATE files:**

- Read current content
- Find the exact lines mentioned
- Make the specified change
- Preserve surrounding code

**For CREATE files:**

- Use patterns from artifact
- Follow existing file structure conventions
- Include all specified content

**For test files:**

- Add test cases as specified
- Follow existing test patterns
- Ensure tests actually test the fix

### 4.4 Track Deviations

If you must deviate from the artifact:

- Note what changed and why
- Include in PR description

**PHASE_4_CHECKPOINT:**

- [ ] All steps from artifact executed
- [ ] Types compile after each change
- [ ] Tests added as specified
- [ ] Any deviations documented

---

## Phase 5: VERIFY - Run Validation

### 5.1 Run Artifact Validation Commands

Execute each command from the artifact's Validation section.

Common patterns (adapt to project's toolchain):
```bash
# Type check
{runner} run type-check  # or: mypy ., cargo check, go build ./...

# Tests
{runner} test {pattern-from-artifact}  # or: pytest, cargo test, go test

# Lint
{runner} run lint  # or: ruff check ., cargo clippy
```

### 5.2 Check Results

**All must pass before proceeding.**

If failures:

1. Analyze what's wrong
2. Fix the issue
3. Re-run validation
4. Note any fixes in PR description

### 5.3 Manual Verification (if specified)

Execute any manual verification steps from the artifact.

**PHASE_5_CHECKPOINT:**

- [ ] Type check passes
- [ ] Tests pass
- [ ] Lint passes
- [ ] Manual verification complete (if applicable)

---

## Phase 6: COMMIT - Save Changes

### 6.1 Stage Changes

```bash
git add -A
git status  # Review what's being committed
```

### 6.2 Write Commit Message

**Format:**

```
Fix: {brief description} (#{issue-number})

{Problem statement from artifact - 1-2 sentences}

Changes:
- {Change 1 from artifact}
- {Change 2 from artifact}
- Added test for {case}

Fixes #{issue-number}
```

**Commit:**

```bash
git commit -m "$(cat <<'EOF'
Fix: {title} (#{number})

{problem statement}

Changes:
- {change 1}
- {change 2}

Fixes #{number}
EOF
)"
```

**PHASE_6_CHECKPOINT:**

- [ ] All changes committed
- [ ] Commit message references issue

---

## Phase 7: COMMIT - Commit and Push to Main

### 7.1 Commit Changes

**Format:**

```
Fix: {brief description} (#{issue-number})

{Problem statement from artifact - 1-2 sentences}

Changes:
- {Change 1 from artifact}
- {Change 2 from artifact}
- Added test for {case}

Fixes #{issue-number}
```

**Commit:**

```bash
git add -A
git commit -m "$(cat <<'EOF'
Fix: {title} (#{number})

{problem statement}

Changes:
- {change 1}
- {change 2}

Fixes #{number}
EOF
)"
```

### 7.2 Push to Main

```bash
git push origin main
```

### 7.3 Verify Push

```bash
git log origin/main..HEAD
# Should be empty - all commits pushed
```

**PHASE_7_CHECKPOINT:**

- [ ] Changes committed to main
- [ ] Commit message references issue with "Fixes #{number}"
- [ ] Pushed to origin/main

---

## Phase 8: REVIEW - Self Code Review (Optional)

### 8.1 Run Code Review

Use Task tool with subagent_type="prp:code-reviewer" to review the changes:

```
Review the changes in the latest commit for issue #{number}.

Focus on:
1. Does the fix address the root cause from the investigation?
2. Code quality - matches codebase patterns?
3. Test coverage - are the new tests sufficient?
4. Edge cases - are they handled?
5. Security - any concerns?
6. Potential bugs - anything that could break?

Review only the diff, not the entire codebase.
```

### 8.2 Document Review Findings

Save review to `.claude/PRPs/reviews/issue-{number}-review.md`:

```markdown
## Code Review - Issue #{number}

**Commit**: {commit-hash}
**Date**: {date}

### Summary

{1-2 sentence assessment}

### Findings

#### ✅ Strengths
- {Good thing 1}
- {Good thing 2}

#### ⚠️ Suggestions
- `{file}:{line}` - {suggestion}
- {other suggestions}

#### 🔒 Security
- {Any concerns or "No security concerns identified"}

### Checklist

- [x] Fix addresses root cause from investigation
- [x] Code follows codebase patterns
- [x] Tests cover the change
- [x] No obvious bugs introduced
```

**PHASE_8_CHECKPOINT:**

- [ ] Code review completed (optional)
- [ ] Review documented if performed

---

## Phase 9: ARCHIVE - Clean Up

### 9.1 Move Artifact to Completed

```bash
mkdir -p .claude/PRPs/issues/completed
mv .claude/PRPs/issues/issue-{number}.md .claude/PRPs/issues/completed/
```

### 9.2 Commit and Push Archive

```bash
git add .claude/PRPs/issues/
git commit -m "Archive investigation for issue #{number}"
git push
```

**PHASE_9_CHECKPOINT:**

- [ ] Artifact moved to completed folder
- [ ] Archive committed and pushed

---

## Phase 10: REPORT - Output to User

```markdown
## Implementation Complete

**Issue**: #{number} - {title}
**Commit**: {commit-hash}
**Pushed to**: main

### Changes Made

| File            | Change        |
| --------------- | ------------- |
| `src/x.ts`      | {description} |
| `src/x.test.ts` | Added test    |

### Validation

| Check      | Result  |
| ---------- | ------- |
| Type check | ✅ Pass |
| Tests      | ✅ Pass |
| Lint       | ✅ Pass |

### Self-Review

{Summary of review findings}

### Artifact

📄 Archived to `.claude/PRPs/issues/completed/issue-{number}.md`

### Next Steps

- Changes are live on main
- Monitor for any issues
- Close GitHub issue if applicable: `gh issue close {number}`
```

---

## Handling Edge Cases

### Artifact is outdated

- Warn user about drift
- Suggest re-running `/prp:prp-issue-investigate`
- Can proceed with caution if changes are minor

### Tests fail after implementation

- Debug the failure
- Fix the code (not the test, unless test is wrong)
- Re-run validation
- Note the additional fix in PR

### Merge conflicts during sync

- Resolve conflicts in affected files
- `git add .`
- `git commit -m "merge: sync with origin/main"`
- Re-run full validation

### Push fails

- Check if remote is ahead: `git fetch && git status`
- Pull changes: `git pull origin main`
- Resolve any conflicts
- Push again: `git push origin main`

### Already have uncommitted changes

- Commit them as WIP: `git add . && git commit -m "WIP: checkpoint"`
- Continue with implementation
- Or stash if temporary: `git stash`

### Working on wrong branch

- Switch to main: `git checkout main`
- Pull latest: `git pull origin main`
- Continue with implementation

---

## Success Criteria

- **PLAN_EXECUTED**: All artifact steps completed
- **VALIDATION_PASSED**: All checks green
- **COMMITTED**: Changes committed to main with issue reference
- **PUSHED**: Commit pushed to origin/main
- **REVIEW_COMPLETED**: Self-review performed (optional)
- **ARTIFACT_ARCHIVED**: Moved to completed folder
- **AUDIT_TRAIL**: Full history in git log
