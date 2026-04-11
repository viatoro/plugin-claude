---
description: Comprehensive commit review using specialized agents - comments, tests, errors, types, code quality, docs, and simplification
argument-hint: "[commit-hash|range] [aspects: comments|tests|errors|types|code|docs|simplify|all]"
---

# Comprehensive Commit Review with Specialized Agents (Trunk-Based)

Run a multi-agent review on recent commits, with each agent focusing on a specific aspect of code quality.

**Target**: $ARGUMENTS (default: HEAD)

## Pre-Review Setup

Before running reviews:

1. **Identify the Commit(s)**
   - If commit hash provided: `git show <hash>`
   - If range provided: `git diff <range>`
   - If no input: review HEAD (last commit)

2. **Ensure Up to Date**
   - Fetch latest: `git fetch origin`
   - Check status: `git status`

3. **Get Changed Files**
   ```bash
   git diff --name-only ${COMMIT_RANGE}^..${COMMIT_RANGE}
   ```

## Review Aspects

| Aspect | Agent | When to Run |
|--------|-------|-------------|
| `code` | code-reviewer | Always - general quality and guidelines |
| `docs` | docs-impact-agent | Almost always - updates stale docs |
| `tests` | test-analyzer | When test files or tested code changed |
| `comments` | comment-analyzer | When comments/docstrings added |
| `errors` | silent-failure-hunter | When error handling changed |
| `types` | type-design-analyzer | When types added/modified |
| `simplify` | code-simplifier | After passing review - polish |
| `all` | All applicable | Default if no aspects specified |

## Aspect Selection Logic

**Always run**:
- `code-reviewer` - Core quality check

**Almost always run** (skip only for trivial commits):
- `docs-impact-agent` - Updates project docs

**Skip docs-impact-agent only when**:
- Typo-only fixes (comments, strings)
- Test-only changes (no production code)
- Documentation-only changes
- Config tweaks (CI, linting)

**Run based on changes**:
- Test files changed → `test-analyzer`
- Comments/docstrings added → `comment-analyzer`
- Try-catch or error handling → `silent-failure-hunter`
- New types or type modifications → `type-design-analyzer`

**Run last**:
- `code-simplifier` - After other reviews pass

## Execution

### Sequential (Default)

Run agents one at a time for clear, actionable feedback:

1. `code-reviewer` - Guidelines and bugs
2. `docs-impact-agent` - Fix stale docs (commits directly to main)
3. Applicable specialist agents based on changes
4. `code-simplifier` - Final polish (if requested or all reviews pass)

### Parallel (When Requested)

If user specifies "parallel", launch all applicable agents simultaneously using multiple Task tool calls in one message.

## Agent Instructions

When launching each agent via Task tool:

**code-reviewer**:
> Review commit(s) `<hash|range>` for project guideline compliance, bugs, and quality issues. Focus on the diff. Report only high-confidence issues (80+).

**docs-impact-agent**:
> Review commit(s) `<hash|range>` and update any documentation that's affected by these changes. Fix stale docs in CLAUDE.md, README.md, and docs/. If you make updates, commit and push to main.

**test-analyzer**:
> Analyze test coverage for commit(s) `<hash|range>`. Focus on behavioral coverage, identify critical gaps, rate recommendations by criticality.

**comment-analyzer**:
> Analyze code comments in commit(s) `<hash|range>` for accuracy, completeness, and long-term value. Verify comments match actual code behavior.

**silent-failure-hunter**:
> Hunt for silent failures in commit(s) `<hash|range>`. Check all error handling for proper logging, user feedback, and specific catch blocks.

**type-design-analyzer**:
> Analyze type design in commit(s) `<hash|range>`. Rate encapsulation, invariant expression, usefulness, and enforcement. Focus on new or modified types.

**code-simplifier**:
> Simplify code in commit(s) `<hash|range>` for clarity while preserving functionality. No nested ternaries, prefer explicit over clever. Commit and push improvements to main.

## Result Aggregation

After all agents complete, aggregate findings:

### Categories

| Category | Description | Action |
|----------|-------------|--------|
| **Critical** | Must fix immediately | Revert or fix in follow-up commit |
| **Important** | Should fix soon | Address in follow-up commit |
| **Suggestions** | Nice to have | Consider |
| **Strengths** | What's good | Acknowledge |

### Summary Format

```markdown
## Commit Review Summary

### Critical Issues (X found)
| Agent | Issue | Location |
|-------|-------|----------|
| code-reviewer | Description | `file.ts:line` |

### Important Issues (X found)
| Agent | Issue | Location |
|-------|-------|----------|
| silent-failure-hunter | Description | `file.ts:line` |

### Suggestions (X found)
| Agent | Suggestion | Location |
|-------|------------|----------|
| type-design-analyzer | Description | `file.ts:line` |

### Strengths
- Well-structured error handling
- Good test coverage for critical paths

### Documentation Updates
- `CLAUDE.md` - Added new command reference
- `README.md` - Updated configuration section

### Verdict
[CLEAN / NEEDS FOLLOW-UP / CRITICAL ISSUES]

### Recommended Actions
1. Fix critical issues in follow-up commit
2. Address important issues
3. Consider suggestions
4. Re-run review after fixes
```

## Usage Examples

```bash
# Full review of last commit
/prp:prp-review-agents

# Review specific commit
/prp:prp-review-agents abc123f

# Review last 3 commits
/prp:prp-review-agents 3

# Review only specific aspects
/prp:prp-review-agents abc123f tests errors

# Only code and docs review
/prp:prp-review-agents HEAD code docs

# All reviews in parallel
/prp:prp-review-agents HEAD~3..HEAD all parallel

# Just simplify after passing review
/prp:prp-review-agents HEAD simplify
```

## Workflow Integration

**Before pushing to main**:
1. Run `/prp:prp-review-agents` on recent commits
2. Fix critical and important issues
3. Re-run to verify
4. Push to main

**After pushing**:
1. Run `/prp:prp-review-agents <commit-hash>`
2. Address findings in follow-up commits
3. Re-run targeted aspects

**After making fixes**:
1. Run specific aspects: `/prp:prp-review-agents HEAD tests code`
2. Verify issues resolved
3. Push to main

## Notes

- Agents analyze git diff by default (changed files only)
- Each agent returns detailed report with file:line references
- docs-impact-agent commits doc updates directly to main
- code-simplifier commits improvements directly to main
- Review reports saved to `.claude/PRPs/reviews/`
