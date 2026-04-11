---
description: Execute an implementation plan with rigorous validation loops
argument-hint: <path/to/plan.md>
---

# Implement Plan

**Plan**: $ARGUMENTS

---

## Your Mission

Execute the plan end-to-end with rigorous self-validation. You are autonomous.

**Core Philosophy**: Validation loops catch mistakes early. Run checks after every change. Fix issues immediately. The goal is a working implementation, not just code that exists.

**Golden Rule**: If a validation fails, fix it before moving on. Never accumulate broken state.

---

## Phase 0: DETECT - Project Environment

### 0.1 Identify Package Manager

Check for these files to determine the project's toolchain:

| File Found | Package Manager | Runner |
|------------|-----------------|--------|
| `bun.lockb` | bun | `bun` / `bun run` |
| `pnpm-lock.yaml` | pnpm | `pnpm` / `pnpm run` |
| `yarn.lock` | yarn | `yarn` / `yarn run` |
| `package-lock.json` | npm | `npm run` |
| `pyproject.toml` | uv/pip | `uv run` / `python` |
| `Cargo.toml` | cargo | `cargo` |
| `go.mod` | go | `go` |

**Store the detected runner** - use it for all subsequent commands.

### 0.2 Identify Validation Scripts

Check `package.json` (or equivalent) for available scripts:
- Type checking: `type-check`, `typecheck`, `tsc`
- Linting: `lint`, `lint:fix`
- Testing: `test`, `test:unit`, `test:integration`
- Building: `build`, `compile`

**Use the plan's "Validation Commands" section** - it should specify exact commands for this project.

---

## Phase 1: LOAD - Read the Plan

### 1.1 Load Plan File

```bash
cat $ARGUMENTS
```

### 1.2 Extract Key Sections

Locate and understand:

- **Summary** - What we're building
- **Patterns to Mirror** - Code to copy from
- **Files to Change** - CREATE/UPDATE list
- **Step-by-Step Tasks** - Implementation order
- **Validation Commands** - How to verify (USE THESE, not hardcoded commands)
- **Acceptance Criteria** - Definition of done

### 1.3 Validate Plan Exists

**If plan not found:**

```
Error: Plan not found at $ARGUMENTS

Create a plan first: /prp:prp-plan "feature description"
```

**PHASE_1_CHECKPOINT:**

- [ ] Plan file loaded
- [ ] Key sections identified
- [ ] Tasks list extracted

---

## Phase 2: PREPARE - Git State (Trunk-Based)

### 2.1 Check Current State

```bash
git branch --show-current
git status --porcelain
```

### 2.2 Trunk-Based Strategy (Direct to Main)

**Philosophy**: Work directly on main, commit frequently, push often.

| Current State  | Action                                                          |
| -------------- | --------------------------------------------------------------- |
| On main, clean | Continue on main (no branch needed)                             |
| On main, dirty | Commit WIP: `git add . && git commit -m "WIP: checkpoint"`     |
| On any branch  | Switch to main: `git checkout main && git pull`                 |

**No branching**: All work happens on main with atomic commits.

### 2.3 Sync with Trunk

```bash
git fetch origin
git merge origin/main
```

**If merge conflicts:**
1. Resolve conflicts in affected files
2. `git add .`
3. `git commit -m "merge: sync with origin/main"`

### 2.4 Feature Flag Check (if applicable)

If implementing incomplete/experimental work:
- Check if project has feature flag system
- Plan to wrap new code in flags
- Document flag name in report

**PHASE_2_CHECKPOINT:**

- [ ] On main branch
- [ ] Merged latest origin/main
- [ ] No conflicts
- [ ] Feature flag strategy decided (if needed)

---

## Phase 3: EXECUTE - Implement Tasks

**For each task in the plan's Step-by-Step Tasks section:**

### 3.1 Read Context

1. Read the **MIRROR** file reference from the task
2. Understand the pattern to follow
3. Read any **IMPORTS** specified

### 3.2 Implement

1. Make the change exactly as specified
2. Follow the pattern from MIRROR reference
3. Handle any **GOTCHA** warnings

### 3.3 Validate Immediately

**After EVERY file change, run the type-check command from the plan's Validation Commands section.**

Common patterns:
- `{runner} run type-check` (JS/TS projects)
- `mypy .` (Python)
- `cargo check` (Rust)
- `go build ./...` (Go)

**If types fail:**

1. Read the error
2. Fix the issue
3. Re-run type-check
4. Only proceed when passing

### 3.4 Track Progress

Log each task as you complete it:

```
Task 1: CREATE src/features/x/models.ts ✅
Task 2: CREATE src/features/x/service.ts ✅
Task 3: UPDATE src/routes/index.ts ✅
```

**Deviation Handling:**
If you must deviate from the plan:

- Note WHAT changed
- Note WHY it changed
- Continue with the deviation documented

**PHASE_3_CHECKPOINT:**

- [ ] All tasks executed in order
- [ ] Each task passed type-check
- [ ] Deviations documented

---

## Phase 4: VALIDATE - Full Verification

### 4.1 Static Analysis

**Run the type-check and lint commands from the plan's Validation Commands section.**

Common patterns:
- JS/TS: `{runner} run type-check && {runner} run lint`
- Python: `ruff check . && mypy .`
- Rust: `cargo check && cargo clippy`
- Go: `go vet ./...`

**Must pass with zero errors.**

If lint errors:

1. Run the lint fix command (e.g., `{runner} run lint:fix`, `ruff check --fix .`)
2. Re-check
3. Manual fix remaining issues

### 4.2 Unit Tests

**You MUST write or update tests for new code.** This is not optional.

**Test requirements:**

1. Every new function/feature needs at least one test
2. Edge cases identified in the plan need tests
3. Update existing tests if behavior changed

**Write tests**, then run the test command from the plan.

Common patterns:
- JS/TS: `{runner} test` or `{runner} run test`
- Python: `pytest` or `uv run pytest`
- Rust: `cargo test`
- Go: `go test ./...`

**If tests fail:**

1. Read failure output
2. Determine: bug in implementation or bug in test?
3. Fix the actual issue
4. Re-run tests
5. Repeat until green

### 4.3 Build Check

**Run the build command from the plan's Validation Commands section.**

Common patterns:
- JS/TS: `{runner} run build`
- Python: N/A (interpreted) or `uv build`
- Rust: `cargo build --release`
- Go: `go build ./...`

**Must complete without errors.**

### 4.4 Integration Testing (if applicable)

**If the plan involves API/server changes, use the integration test commands from the plan.**

Example pattern:
```bash
# Start server in background (command varies by project)
{runner} run dev &
SERVER_PID=$!
sleep 3

# Test endpoints (adjust URL/port per project config)
curl -s http://localhost:{port}/health | jq

# Stop server
kill $SERVER_PID
```

### 4.5 Edge Case Testing

Run any edge case tests specified in the plan.

**PHASE_4_CHECKPOINT:**

- [ ] Type-check passes (command from plan)
- [ ] Lint passes (0 errors)
- [ ] Tests pass (all green)
- [ ] Build succeeds
- [ ] Integration tests pass (if applicable)

---

## Phase 5: VERIFY - Confirm Code Actually Works

After all static validation passes, verify the implementation works live.

### 5.1 Start Dev Server

```bash
{runner} run dev &
DEV_PID=$!
sleep 5

# Verify server started
curl -s -o /dev/null -w "%{http_code}" http://localhost:{port}
```

### 5.2 Backend Verification (if API changes)

For each new/modified endpoint:

```bash
# Test each endpoint from the plan
curl -s http://localhost:{port}/{endpoint} | jq .

# Check response status and shape
curl -s -w "\n%{http_code}" http://localhost:{port}/{endpoint}
```

| Endpoint | Method | Expected | Actual | Status |
|----------|--------|----------|--------|--------|
| {/api/resource} | GET | 200 + list | {actual} | ✅/❌ |
| {/api/resource} | POST | 201 + created | {actual} | ✅/❌ |
| {/api/resource/:id} | PUT | 200 + updated | {actual} | ✅/❌ |
| {/api/resource/:id} | DELETE | 204 | {actual} | ✅/❌ |

### 5.3 UI Verification (if UI changes, via MCP)

Use Playwright MCP or Chrome DevTools MCP to walk through each new feature:

```
For each UI change in the plan:
  → browser_navigate url="{base-url}{page}"
  → browser_snapshot
  → CHECK: new elements render correctly
  → browser_click / browser_fill (interact with new feature)
  → browser_snapshot
  → CHECK: feature responds as expected
  → CHECK: no console errors (browser_console_messages)
```

| UI Feature | Action | Expected | Actual | Status |
|-----------|--------|----------|--------|--------|
| {new page/component} | Navigate | Renders | {actual} | ✅/❌ |
| {form/input} | Fill + submit | Success toast | {actual} | ✅/❌ |
| {list/table} | Load | Shows data | {actual} | ✅/❌ |

### 5.4 Error Handling Verification

Test that error paths work correctly:

```bash
# Test invalid input
curl -s -X POST http://localhost:{port}/{endpoint} -d '{}' | jq .
# Expected: 400 with validation error

# Test not found
curl -s http://localhost:{port}/{endpoint}/nonexistent | jq .
# Expected: 404 with error message

# Test unauthorized (if applicable)
curl -s http://localhost:{port}/{endpoint} -H "Authorization: invalid" | jq .
# Expected: 401/403
```

### 5.5 Cleanup

```bash
kill $DEV_PID 2>/dev/null
```

### 5.6 Verification Results

| Category | Checks | Passed | Status |
|----------|--------|--------|--------|
| Backend endpoints | {N} | {N} | ✅/❌ |
| UI features | {N} | {N} | ✅/❌/N/A |
| Error handling | {N} | {N} | ✅/❌ |
| Console errors | - | {count} | ✅/⚠️ |

**PHASE_5_CHECKPOINT:**

- [ ] Dev server starts without error
- [ ] All new endpoints respond correctly
- [ ] UI features render and interact properly (if applicable)
- [ ] Error paths return appropriate responses
- [ ] No console errors
- [ ] Server stopped cleanly

---

## Phase 6: REPORT - Create Implementation Report

### 6.1 Create Report Directory

```bash
mkdir -p .claude/PRPs/reports
```

### 6.2 Generate Report

**Path**: `.claude/PRPs/reports/{plan-name}-report.md`

```markdown
# Implementation Report

**Plan**: `$ARGUMENTS`
**Source Issue**: #{number} (if applicable)
**Date**: {YYYY-MM-DD}
**Status**: {COMPLETE | PARTIAL}

---

## Summary

{Brief description of what was implemented}

---

## Assessment vs Reality

Compare the original investigation's assessment with what actually happened:

| Metric     | Predicted   | Actual   | Reasoning                                                                      |
| ---------- | ----------- | -------- | ------------------------------------------------------------------------------ |
| Complexity | {from plan} | {actual} | {Why it matched or differed - e.g., "discovered additional integration point"} |
| Confidence | {from plan} | {actual} | {e.g., "root cause was correct" or "had to pivot because X"}                   |

**If implementation deviated from the plan, explain why:**

- {What changed and why - based on what you discovered during implementation}

---

## Tasks Completed

| #   | Task               | File       | Status |
| --- | ------------------ | ---------- | ------ |
| 1   | {task description} | `src/x.ts` | ✅     |
| 2   | {task description} | `src/y.ts` | ✅     |

---

## Validation Results

| Check       | Result | Details               |
| ----------- | ------ | --------------------- |
| Type check  | ✅     | No errors             |
| Lint        | ✅     | 0 errors, N warnings  |
| Unit tests  | ✅     | X passed, 0 failed    |
| Build       | ✅     | Compiled successfully |
| Integration | ✅/⏭️  | {result or "N/A"}     |

---

## Files Changed

| File       | Action | Lines     |
| ---------- | ------ | --------- |
| `src/x.ts` | CREATE | +{N}      |
| `src/y.ts` | UPDATE | +{N}/-{M} |

---

## Deviations from Plan

{List any deviations with rationale, or "None"}

---

## Issues Encountered

{List any issues and how they were resolved, or "None"}

---

## Tests Written

| Test File       | Test Cases               |
| --------------- | ------------------------ |
| `src/x.test.ts` | {list of test functions} |

---

## Next Steps

- [ ] Review implementation
- [ ] Push to main: `git push origin main`
```

### 6.3 Update Source PRD (if applicable)

**Check if plan was generated from a PRD:**
- Look in the plan file for `Source PRD:` reference
- Or check if plan filename matches a phase pattern

**If PRD source exists:**

1. Read the PRD file
2. Find the phase row in the Implementation Phases table
3. Update the phase:
   - Change Status from `in-progress` to `complete`
4. Save the PRD

### 6.4 Archive Plan

```bash
mkdir -p .claude/PRPs/plans/completed
mv $ARGUMENTS .claude/PRPs/plans/completed/
```

**PHASE_6_CHECKPOINT:**

- [ ] Report created at `.claude/PRPs/reports/`
- [ ] PRD updated (if applicable) - phase marked complete
- [ ] Plan moved to completed folder

---

## Phase 7: OUTPUT - Report to User

```markdown
## Implementation Complete

**Plan**: `$ARGUMENTS`
**Source Issue**: #{number} (if applicable)
**Status**: ✅ Complete

### Validation Summary

| Check      | Result          |
| ---------- | --------------- |
| Type check | ✅              |
| Lint       | ✅              |
| Tests      | ✅ ({N} passed) |
| Build      | ✅              |

### Live Verification

| Check | Result |
|-------|--------|
| Backend endpoints | ✅ {N}/{total} |
| UI features | ✅ {N}/{total} / N/A |
| Error handling | ✅ {N}/{total} |
| Console errors | {count} |

### Files Changed

- {N} files created
- {M} files updated
- {K} tests written

### Deviations

{If none: "Implementation matched the plan."}
{If any: Brief summary of what changed and why}

### Artifacts

- Report: `.claude/PRPs/reports/{name}-report.md`
- Plan archived to: `.claude/PRPs/plans/completed/`

{If from PRD:}
### PRD Progress

**PRD**: `{prd-file-path}`
**Phase Completed**: #{number} - {phase name}

| # | Phase | Status |
|---|-------|--------|
{Updated phases table showing progress}

**Next Phase**: {next pending phase, or "All phases complete!"}
{If next phase can parallel: "Note: Phase {X} can also start now (parallel)"}

To continue: `/prp:prp-plan {prd-path}`

### Next Steps

1. Review the report (especially if deviations noted)
2. Push to main: `git push origin main`
{If more phases: "3. Continue with next phase: `/prp:prp-plan {prd-path}`"}
```

---

## Handling Failures

### Type Check Fails

1. Read error message carefully
2. Fix the type issue
3. Re-run the type-check command
4. Don't proceed until passing

### Tests Fail

1. Identify which test failed
2. Determine: implementation bug or test bug?
3. Fix the root cause (usually implementation)
4. Re-run tests
5. Repeat until green

### Lint Fails

1. Run the lint fix command for auto-fixable issues
2. Manually fix remaining issues
3. Re-run lint
4. Proceed when clean

### Build Fails

1. Usually a type or import issue
2. Check the error output
3. Fix and re-run

### Integration Test Fails

1. Check if server started correctly
2. Verify endpoint exists
3. Check request format
4. Fix implementation and retry

---

## Success Criteria

- **TASKS_COMPLETE**: All plan tasks executed
- **TYPES_PASS**: Type-check command exits 0
- **LINT_PASS**: Lint command exits 0 (warnings OK)
- **TESTS_PASS**: Test command all green
- **BUILD_PASS**: Build command succeeds
- **REPORT_CREATED**: Implementation report exists
- **PLAN_ARCHIVED**: Original plan moved to completed
