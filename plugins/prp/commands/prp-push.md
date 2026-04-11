---
description: Validate and push to main - runs checks before pushing (trunk-based quality gate)
argument-hint: [--force to skip validation]
---

# Push to Main (with Validation)

**Args**: $ARGUMENTS

---

## Your Mission

Run validation checks, then push to main. This is the trunk-based replacement for PR review — the quality gate before code goes live.

**Golden Rule**: Never push broken code to main. If validation fails, fix it first.

---

## Phase 1: PRE-FLIGHT - Check State

### 1.1 Verify Branch and Status

```bash
git branch --show-current
git status --porcelain
git log origin/main..HEAD --oneline
```

**If not on main**: warn and suggest `git checkout main`
**If no unpushed commits**: report "Nothing to push" and stop
**If uncommitted changes**: warn and suggest committing first

### 1.2 Sync with Remote

```bash
git fetch origin
git merge origin/main
```

**If merge conflicts**: stop and help resolve

**PHASE_1_CHECKPOINT:**

- [ ] On main branch
- [ ] Has unpushed commits
- [ ] Synced with origin/main

---

## Phase 2: VALIDATE - Run Quality Checks

**Skip this phase if `--force` is passed.**

### 2.1 Detect Project Environment

Check for lockfiles/config to determine toolchain (same as prp-implement Phase 0).

### 2.2 Run Validation Suite

<!-- TODO: implement runValidation() — see guidance below -->

Run each available check and track results:

```bash
# Type checking (adapt to project)
{runner} run type-check

# Linting
{runner} run lint

# Tests
{runner} test

# Build
{runner} run build
```

**Track results for each:**

| Check | Status | Details |
|-------|--------|---------|
| Type check | ✅/❌ | {error count} |
| Lint | ✅/❌ | {error count} |
| Tests | ✅/❌ | {pass/fail count} |
| Build | ✅/❌ | {notes} |

### 2.3 Evaluate Results

**ALL GREEN**: Proceed to push
**ANY FAILURE**: Stop and report what failed

**PHASE_2_CHECKPOINT:**

- [ ] Type check passes
- [ ] Lint passes
- [ ] Tests pass
- [ ] Build succeeds

---

## Phase 3: PUSH - Ship It

### 3.1 Push to Main

```bash
git push origin main
```

### 3.2 Verify

```bash
git log origin/main..HEAD --oneline
# Should be empty
```

**PHASE_3_CHECKPOINT:**

- [ ] Pushed to origin/main
- [ ] No unpushed commits remain

---

## Phase 4: OUTPUT - Report

```markdown
## Pushed to Main

**Commits pushed**: {count}
**Branch**: main → origin/main

### Commits
{list of commit hashes and messages}

### Validation Results

| Check | Result |
|-------|--------|
| Type check | ✅ |
| Lint | ✅ |
| Tests | ✅ ({N} passed) |
| Build | ✅ |

### Next Steps

- Monitor for issues
- Run `/prp:prp-review-agents` for post-push review (optional)
```

---

## Handling Failures

### Validation fails

1. Report which check failed with details
2. Suggest fix approach
3. Do NOT push
4. User can re-run after fixing

### Push fails (remote ahead)

```bash
git pull origin main
# Resolve any conflicts
git push origin main
```

### Force push requested

If `--force` passed:
- Skip validation
- Push directly
- Warn: "Pushing without validation — use with caution"

---

## Success Criteria

- **STATE_CLEAN**: On main, synced with remote
- **VALIDATION_PASSED**: All checks green (unless --force)
- **PUSHED**: Commits on origin/main
- **REPORTED**: User knows what shipped
